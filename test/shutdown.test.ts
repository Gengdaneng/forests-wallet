import assert from "node:assert/strict";
import { createServer } from "node:http";
import { test } from "node:test";
import { closeServerThenPool } from "../src/shutdown.js";

test("shutdown waits for in-flight requests before ending the pool", async () => {
  let started = false;
  let requestFinished = false;
  let poolEndedAtRequest = false;
  const server = createServer((_req, res) => {
    started = true;
    setTimeout(() => {
      requestFinished = true;
      res.writeHead(200, { "content-type": "text/plain" });
      res.end("ok");
    }, 80);
  });
  await new Promise<void>((resolve) => {
    server.listen(0, "127.0.0.1", () => resolve());
  });
  const address = server.address();
  if (!address || typeof address === "string") {
    throw new Error("failed to bind");
  }
  const pool = {
    end: async () => {
      poolEndedAtRequest = requestFinished;
    },
  };
  const response = fetch(`http://127.0.0.1:${address.port}/`, {
    headers: { connection: "close" },
  });
  const waitStart = Date.now();
  while (!started && Date.now() - waitStart < 1_000) {
    await new Promise((resolve) => setTimeout(resolve, 5));
  }
  assert.equal(started, true);
  await closeServerThenPool(server, pool, 2_000);
  const body = await (await response).text();
  assert.equal(body, "ok");
  assert.equal(requestFinished, true);
  assert.equal(poolEndedAtRequest, true);
});
