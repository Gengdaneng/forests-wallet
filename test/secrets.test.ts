import assert from "node:assert/strict";
import { after, before, test } from "node:test";
import { sha256Buffer } from "../src/crypto.js";
import { openBootstrap } from "../src/operators.js";
import {
  api,
  asObject,
  captureLogs,
  startEnv,
  stopSharedContainer,
  type TestEnv,
} from "./harness.js";

let env: TestEnv;

before(async () => {
  env = await startEnv();
});

after(async () => {
  await env?.stop();
  await stopSharedContainer();
});

test("tokens and pairing codes are never stored raw or logged", async () => {
  const { result, logs } = await captureLogs(async () => {
    await openBootstrap(env.pool);
    const parentRes = await api(env.baseUrl, {
      method: "POST",
      path: "/v1/bootstrap",
      body: { device_label: "secret-parent" },
      ip: "192.0.2.10",
    });
    assert.equal(parentRes.status, 201, parentRes.text);
    const parent = asObject(parentRes.json);
    const token = parent.token as string;
    const pairingRes = await api(env.baseUrl, {
      method: "POST",
      path: "/v1/pairings",
      token,
      body: { device_label: "secret-child" },
    });
    assert.equal(pairingRes.status, 201, pairingRes.text);
    const code = asObject(pairingRes.json).code as string;
    const claim = await api(env.baseUrl, {
      method: "POST",
      path: "/v1/pairings/claim",
      body: { code },
      ip: "192.0.2.11",
    });
    assert.equal(claim.status, 201, claim.text);
    const childToken = asObject(claim.json).token as string;
    return { token, code, childToken };
  });

  const escapeRe = (value: string) => value.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
  assert.doesNotMatch(logs, new RegExp(escapeRe(result.token)));
  assert.doesNotMatch(logs, new RegExp(escapeRe(result.childToken)));
  assert.doesNotMatch(logs, /Bearer\s+[A-Za-z0-9_-]{20,}/);
  assert.doesNotMatch(logs, new RegExp(`"code"\\s*:\\s*"${result.code}"`));

  const dump = await env.migratorPool.query<{ blob: string }>(
    `SELECT string_agg(blob, ' ') AS blob FROM (
        SELECT devices::text AS blob FROM devices
        UNION ALL SELECT settings::text FROM settings
        UNION ALL SELECT children::text FROM children
        UNION ALL SELECT idempotency_keys::text FROM idempotency_keys
      ) s`,
  );
  const blob = dump.rows[0]?.blob ?? "";
  assert.ok(!blob.includes(result.token));
  assert.ok(!blob.includes(result.childToken));

  const hashes = await env.pool.query<{
    token_hash: Buffer;
    pairing_code_hash: Buffer | null;
    role: string;
    status: string;
  }>("SELECT role, status, token_hash, pairing_code_hash FROM devices");
  for (const row of hashes.rows) {
    if (row.token_hash) {
      const hex = row.token_hash.toString("hex");
      assert.notEqual(hex, Buffer.from(result.token).toString("hex"));
      assert.notEqual(hex, Buffer.from(result.childToken).toString("hex"));
    }
    assert.equal(row.pairing_code_hash, null);
  }
  const parentHash = hashes.rows.find((row) => row.role === "parent" && row.status === "active");
  const childHash = hashes.rows.find((row) => row.role === "child" && row.status === "active");
  assert.equal(
    parentHash?.token_hash.toString("hex"),
    sha256Buffer(result.token).toString("hex"),
  );
  assert.equal(
    childHash?.token_hash.toString("hex"),
    sha256Buffer(result.childToken).toString("hex"),
  );
});
