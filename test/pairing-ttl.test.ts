import assert from "node:assert/strict";
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
  env = await startEnv({ extraEnv: { PAIRING_TTL_MS: "5000" } });
});

after(async () => {
  await env?.stop();
  await stopSharedContainer();
});

test("pairing expiry uses configured pairingTtlMs, not a hardcoded 10 minutes", async () => {
  assert.equal(env.config.pairingTtlMs, 5_000);
  await openBootstrap(env.pool);
  const parentRes = await api(env.baseUrl, {
    method: "POST",
    path: "/v1/bootstrap",
    body: { device_label: "ttl-parent" },
    ip: "203.0.113.40",
  });
  assert.equal(parentRes.status, 201, parentRes.text);
  const token = asObject(parentRes.json).token as string;
  const pairing = await api(env.baseUrl, {
    method: "POST",
    path: "/v1/pairings",
    token,
    body: {},
  });
  assert.equal(pairing.status, 201, pairing.text);
  assert.equal(asObject(pairing.json).expires_in_seconds, 5);
  const row = await env.pool.query<{ ttl_ms: string }>(
    `SELECT round(extract(epoch from (pairing_expires_at - created_at)) * 1000) AS ttl_ms
       FROM devices
      WHERE pairing_code_hash IS NOT NULL
        AND revoked_at IS NULL`,
  );
  assert.equal(Number(row.rows[0]?.ttl_ms), 5_000);
});
