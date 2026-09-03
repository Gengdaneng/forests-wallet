import assert from "node:assert/strict";
import { execFile as execFileCb } from "node:child_process";
import { after, before, beforeEach, test } from "node:test";
import { promisify } from "node:util";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";
import { sha256Buffer } from "../src/crypto.js";
import { mutatingAuthenticatedRoutes } from "../src/app.js";
import { asObject, api, startEnv, stopSharedContainer, type TestEnv } from "./harness.js";
import { resetThrottlesForTests } from "../src/throttle.js";

const execFile = promisify(execFileCb);
const root = join(dirname(fileURLToPath(import.meta.url)), "..");

let env: TestEnv;

before(async () => {
  env = await startEnv({ testRoutes: true });
});

after(async () => {
  await env?.stop();
  await stopSharedContainer();
});

beforeEach(() => {
  resetThrottlesForTests();
});

async function cli(command: string): Promise<{ stdout: string; stderr: string; code: number }> {
  try {
    const { stdout, stderr } = await execFile(
      process.execPath,
      ["--import", "tsx", join(root, "src/cli.ts"), command],
      {
        env: { ...process.env, DATABASE_URL: env.runtimeUrl },
        encoding: "utf8",
      },
    );
    return { stdout, stderr, code: 0 };
  } catch (err) {
    const failure = err as {
      stdout?: string;
      stderr?: string;
      code?: number;
    };
    return {
      stdout: failure.stdout ?? "",
      stderr: failure.stderr ?? "",
      code: failure.code ?? 1,
    };
  }
}

async function registerParent(label = "papa-iphone"): Promise<{
  token: string;
  device_id: string;
}> {
  const opened = await cli("open-bootstrap");
  assert.equal(opened.code, 0, opened.stderr);
  const res = await api(env.baseUrl, {
    method: "POST",
    path: "/v1/bootstrap",
    body: { device_label: label },
    ip: "203.0.113.10",
  });
  assert.equal(res.status, 201, res.text);
  const body = asObject(res.json);
  assert.equal(typeof body.token, "string");
  assert.equal(body.role, "parent");
  return { token: body.token as string, device_id: body.device_id as string };
}

test("bootstrap is closed by default and refuses while an active parent exists", async () => {
  const closed = await api(env.baseUrl, {
    method: "POST",
    path: "/v1/bootstrap",
    body: { device_label: "too-soon" },
    ip: "203.0.113.11",
  });
  assert.equal(closed.status, 403);
  assert.deepEqual(closed.json, { error: "forbidden" });

  const parent = await registerParent();
  const againOpen = await cli("open-bootstrap");
  assert.equal(againOpen.code, 1);
  assert.match(againOpen.stderr, /revoke parent devices first/);

  const second = await api(env.baseUrl, {
    method: "POST",
    path: "/v1/bootstrap",
    body: { device_label: "second" },
    ip: "203.0.113.12",
  });
  assert.equal(second.status, 403);

  await env.pool.query(
    "UPDATE settings SET bootstrap_open_until = now() + interval '30 minutes'",
  );
  const conflicted = await api(env.baseUrl, {
    method: "POST",
    path: "/v1/bootstrap",
    body: { device_label: "second" },
    ip: "203.0.113.13",
  });
  assert.equal(conflicted.status, 409);

  const revoked = await cli("revoke-all-parent-devices");
  assert.equal(revoked.code, 0);
  const stale = await api(env.baseUrl, {
    method: "GET",
    path: "/v1/devices",
    token: parent.token,
  });
  assert.equal(stale.status, 401);

  const reopened = await cli("open-bootstrap");
  assert.equal(reopened.code, 0);
  const replacement = await registerParent("new-phone");
  assert.notEqual(replacement.token, parent.token);

  const closedAgain = await api(env.baseUrl, {
    method: "POST",
    path: "/v1/bootstrap",
    body: { device_label: "late" },
    ip: "203.0.113.14",
  });
  assert.equal(closedAgain.status, 403);
});

test("pairing expiry, five-strike, throttle, replacement, parent-only, revoke, child 403", async () => {
  const listedBefore = await api(env.baseUrl, { method: "GET", path: "/v1/devices" });
  assert.equal(listedBefore.status, 401);

  const existing = await env.pool.query(
    `SELECT 1 FROM devices
      WHERE role = 'parent' AND revoked_at IS NULL AND token_hash IS NOT NULL`,
  );
  if ((existing.rowCount ?? 0) > 0) {
    await cli("revoke-all-parent-devices");
  }
  const parentSession = await registerParent("pairing-parent");

  const pairing = await api(env.baseUrl, {
    method: "POST",
    path: "/v1/pairings",
    token: parentSession.token,
    body: { device_label: "ipad" },
  });
  assert.equal(pairing.status, 201, pairing.text);
  const code = asObject(pairing.json).code as string;
  assert.match(code, /^\d{6}$/);

  const stored = await env.pool.query<{ pairing_code_hash: Buffer }>(
    `SELECT pairing_code_hash FROM devices
      WHERE pairing_code_hash IS NOT NULL AND revoked_at IS NULL`,
  );
  assert.equal(stored.rowCount, 1);
  assert.equal(
    stored.rows[0]!.pairing_code_hash.toString("hex"),
    sha256Buffer(code).toString("hex"),
  );

  await env.pool.query(
    `UPDATE devices
        SET pairing_expires_at = now() - interval '1 second'
      WHERE pairing_code_hash IS NOT NULL AND revoked_at IS NULL`,
  );
  const expired = await api(env.baseUrl, {
    method: "POST",
    path: "/v1/pairings/claim",
    body: { code },
    ip: "198.51.100.1",
  });
  assert.equal(expired.status, 401);
  assert.deepEqual(expired.json, { error: "unauthorized" });

  const live = await api(env.baseUrl, {
    method: "POST",
    path: "/v1/pairings",
    token: parentSession.token,
    body: {},
  });
  const liveCode = asObject(live.json).code as string;

  for (let i = 0; i < 4; i += 1) {
    const miss = await api(env.baseUrl, {
      method: "POST",
      path: "/v1/pairings/claim",
      body: { code: "000000" === liveCode ? "000001" : "000000" },
      ip: `198.51.100.${10 + i}`,
    });
    assert.equal(miss.status, 401);
    assert.deepEqual(miss.json, { error: "unauthorized" });
  }
  const fifth = await api(env.baseUrl, {
    method: "POST",
    path: "/v1/pairings/claim",
    body: { code: liveCode === "000000" ? "000001" : "000000" },
    ip: "198.51.100.20",
  });
  assert.equal(fifth.status, 401);
  const afterStrike = await api(env.baseUrl, {
    method: "POST",
    path: "/v1/pairings/claim",
    body: { code: liveCode },
    ip: "198.51.100.21",
  });
  assert.equal(afterStrike.status, 401);

  const retry = await api(env.baseUrl, {
    method: "POST",
    path: "/v1/pairings",
    token: parentSession.token,
    body: {},
  });
  const retryCode = asObject(retry.json).code as string;
  const throttleIp = "198.51.100.50";
  for (let i = 0; i < 5; i += 1) {
    const miss = await api(env.baseUrl, {
      method: "POST",
      path: "/v1/pairings/claim",
      body: { code: "999999" === retryCode ? "999998" : "999999" },
      ip: throttleIp,
    });
    assert.equal(miss.status, 401);
  }
  const throttled = await api(env.baseUrl, {
    method: "POST",
    path: "/v1/pairings/claim",
    body: { code: retryCode },
    ip: throttleIp,
  });
  assert.equal(throttled.status, 429);

  const childPair = await api(env.baseUrl, {
    method: "POST",
    path: "/v1/pairings",
    token: parentSession.token,
    body: { device_label: "forrest-ipad" },
  });
  const childCode = asObject(childPair.json).code as string;
  const claimed = await api(env.baseUrl, {
    method: "POST",
    path: "/v1/pairings/claim",
    body: { code: childCode },
    ip: "198.51.100.80",
  });
  assert.equal(claimed.status, 201, claimed.text);
  const childToken = asObject(claimed.json).token as string;
  const childId = asObject(claimed.json).device_id as string;
  assert.equal(asObject(claimed.json).role, "child");

  const reuse = await api(env.baseUrl, {
    method: "POST",
    path: "/v1/pairings/claim",
    body: { code: childCode },
    ip: "198.51.100.81",
  });
  assert.equal(reuse.status, 401);

  const replacementPair = await api(env.baseUrl, {
    method: "POST",
    path: "/v1/pairings",
    token: parentSession.token,
    body: { device_label: "new-ipad" },
  });
  const replacementCode = asObject(replacementPair.json).code as string;
  const replacement = await api(env.baseUrl, {
    method: "POST",
    path: "/v1/pairings/claim",
    body: { code: replacementCode },
    ip: "198.51.100.82",
  });
  assert.equal(replacement.status, 201);
  const newChildToken = asObject(replacement.json).token as string;
  assert.notEqual(newChildToken, childToken);

  const oldChild = await api(env.baseUrl, {
    method: "GET",
    path: "/v1/devices",
    token: childToken,
  });
  assert.equal(oldChild.status, 401);

  const childList = await api(env.baseUrl, {
    method: "GET",
    path: "/v1/devices",
    token: newChildToken,
  });
  assert.equal(childList.status, 403);

  const childRevoke = await api(env.baseUrl, {
    method: "POST",
    path: `/v1/devices/${parentSession.device_id}/revoke`,
    token: newChildToken,
    body: {},
  });
  assert.equal(childRevoke.status, 403);

  for (const route of mutatingAuthenticatedRoutes(env.app.routes)) {
    const path = route.pattern.includes(":id")
      ? route.pattern.replace(":id", parentSession.device_id)
      : route.pattern;
    const res = await api(env.baseUrl, {
      method: route.method,
      path,
      token: newChildToken,
      body: {},
      headers: { "idempotency-key": "00000000-0000-4000-8000-000000000001" },
    });
    assert.equal(res.status, 403, `${route.method} ${path}`);
    assert.deepEqual(res.json, { error: "forbidden" });
  }

  const listed = await api(env.baseUrl, {
    method: "GET",
    path: "/v1/devices",
    token: parentSession.token,
  });
  assert.equal(listed.status, 200);
  const devices = asObject(listed.json).devices as Array<Record<string, unknown>>;
  assert.ok(devices.some((row) => row.id === childId && row.status === "revoked"));
  const dump = JSON.stringify(listed.json);
  assert.doesNotMatch(dump, /token_hash|pairing_code_hash/);

  const revokeChild = await api(env.baseUrl, {
    method: "POST",
    path: `/v1/devices/${asObject(replacement.json).device_id as string}/revoke`,
    token: parentSession.token,
    body: {},
  });
  assert.equal(revokeChild.status, 200);
  const afterRevoke = await api(env.baseUrl, {
    method: "GET",
    path: "/v1/devices",
    token: newChildToken,
  });
  assert.equal(afterRevoke.status, 401);
});
