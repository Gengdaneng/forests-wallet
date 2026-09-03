import assert from "node:assert/strict";
import { test } from "node:test";
import { checkHealth, connectWithTimeout } from "../src/health.js";

test("connectWithTimeout releases a client that arrives after the deadline", async () => {
  let releases = 0;
  let finishConnect!: (client: {
    query: () => Promise<unknown>;
    release: () => void;
  }) => void;
  const pending = new Promise<{
    query: () => Promise<unknown>;
    release: () => void;
  }>((resolve) => {
    finishConnect = resolve;
  });
  const fakeClient = {
    query: async () => ({ rows: [] }),
    release() {
      releases += 1;
    },
  };
  const pool = { connect: () => pending };
  const attempt = connectWithTimeout(pool, 30);
  await assert.rejects(attempt, /health connect timeout/);
  assert.equal(releases, 0);
  finishConnect(fakeClient);
  await pending;
  await new Promise((resolve) => setTimeout(resolve, 20));
  assert.equal(releases, 1);
});

test("checkHealth does not leak a late pool client after connect timeout", async () => {
  let releases = 0;
  let finishConnect!: (client: {
    query: () => Promise<unknown>;
    release: () => void;
  }) => void;
  const pending = new Promise<{
    query: () => Promise<unknown>;
    release: () => void;
  }>((resolve) => {
    finishConnect = resolve;
  });
  const fakeClient = {
    query: async () => {
      throw new Error("should not query after timeout");
    },
    release() {
      releases += 1;
    },
  };
  const pool = { connect: () => pending };
  const ok = await checkHealth(pool as never, 30);
  assert.equal(ok, false);
  assert.equal(releases, 0);
  finishConnect(fakeClient);
  await pending;
  await new Promise((resolve) => setTimeout(resolve, 20));
  assert.equal(releases, 1);
});
