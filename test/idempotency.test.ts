import assert from "node:assert/strict";
import { randomUUID } from "node:crypto";
import { after, before, test } from "node:test";
import { openBootstrap } from "../src/operators.js";
import {
  api,
  asObject,
  startEnv,
  stopSharedContainer,
  type TestEnv,
} from "./harness.js";

let env: TestEnv;

before(async () => {
  env = await startEnv({ testRoutes: true });
});

after(async () => {
  await env?.stop();
  await stopSharedContainer();
});

async function parentToken(): Promise<string> {
  await openBootstrap(env.pool);
  const res = await api(env.baseUrl, {
    method: "POST",
    path: "/v1/bootstrap",
    body: { device_label: "idem-parent" },
    ip: "203.0.113.90",
  });
  assert.equal(res.status, 201, res.text);
  return asObject(res.json).token as string;
}

test("same key and hash replay the original result; mismatch is 409; concurrent safe", async () => {
  const token = await parentToken();
  const key = randomUUID();
  const body = { n: 1, note: "first" };

  const first = await api(env.baseUrl, {
    method: "POST",
    path: "/v1/_test/idempotent-echo",
    token,
    body,
    headers: { "idempotency-key": key },
  });
  assert.equal(first.status, 200, first.text);
  const firstBody = asObject(first.json);
  assert.equal(firstBody.ok, true);
  assert.equal(typeof firstBody.nonce, "string");

  const replay = await api(env.baseUrl, {
    method: "POST",
    path: "/v1/_test/idempotent-echo",
    token,
    body,
    headers: { "idempotency-key": key },
  });
  assert.equal(replay.status, 200);
  assert.deepEqual(replay.json, first.json);

  const mismatch = await api(env.baseUrl, {
    method: "POST",
    path: "/v1/_test/idempotent-echo",
    token,
    body: { n: 2, note: "different" },
    headers: { "idempotency-key": key },
  });
  assert.equal(mismatch.status, 409);
  assert.deepEqual(mismatch.json, { error: "conflict" });

  const concurrentKey = randomUUID();
  const concurrentBody = { n: 3 };
  const concurrent = await Promise.all(
    Array.from({ length: 20 }, () =>
      api(env.baseUrl, {
        method: "POST",
        path: "/v1/_test/idempotent-echo",
        token,
        body: concurrentBody,
        headers: { "idempotency-key": concurrentKey },
      }),
    ),
  );
  assert.ok(concurrent.every((res) => res.status === 200));
  const unique = new Set(concurrent.map((res) => res.text));
  assert.equal(unique.size, 1);

  const raceKey = randomUUID();
  const raced = await Promise.all([
    api(env.baseUrl, {
      method: "POST",
      path: "/v1/_test/idempotent-echo",
      token,
      body: { side: "a" },
      headers: { "idempotency-key": raceKey },
    }),
    api(env.baseUrl, {
      method: "POST",
      path: "/v1/_test/idempotent-echo",
      token,
      body: { side: "b" },
      headers: { "idempotency-key": raceKey },
    }),
  ]);
  const statuses = raced.map((res) => res.status).sort();
  assert.deepEqual(statuses, [200, 409]);
});
