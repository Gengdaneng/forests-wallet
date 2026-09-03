import assert from "node:assert/strict";
import { after, before, test } from "node:test";
import { createApp } from "../src/app.js";
import { createPool } from "../src/db.js";
import { createServer } from "node:http";
import { expectedMigrationHead } from "../src/migrate.js";
import { api, asObject, startEnv, stopSharedContainer, type TestEnv } from "./harness.js";

let env: TestEnv;

before(async () => {
  env = await startEnv();
});

after(async () => {
  await env?.stop();
  await stopSharedContainer();
});

test("/healthz is 200 only with the expected migration head and healthy db", async () => {
  const healthy = await api(env.baseUrl, { path: "/healthz" });
  assert.equal(healthy.status, 200);
  assert.deepEqual(healthy.json, { ok: true });
  assert.equal(Object.keys(asObject(healthy.json)).join(","), "ok");
  assert.doesNotMatch(healthy.text, /version|schema|error|postgres|stack/i);

  await env.migratorPool.query(
    "DELETE FROM schema_migrations WHERE version = $1",
    [expectedMigrationHead()],
  );
  const missingHead = await api(env.baseUrl, { path: "/healthz" });
  assert.equal(missingHead.status, 503);
  assert.deepEqual(missingHead.json, { ok: false });
  assert.doesNotMatch(missingHead.text, /002|foundation|schema_migrations/);

  await env.migratorPool.query(
    "INSERT INTO schema_migrations (version) VALUES ($1)",
    [expectedMigrationHead()],
  );
  await env.migratorPool.query(
    "INSERT INTO schema_migrations (version) VALUES ('999_unexpected')",
  );
  const extra = await api(env.baseUrl, { path: "/healthz" });
  assert.equal(extra.status, 503);
  assert.deepEqual(extra.json, { ok: false });

  await env.migratorPool.query(
    "DELETE FROM schema_migrations WHERE version = '999_unexpected'",
  );
  const restored = await api(env.baseUrl, { path: "/healthz" });
  assert.equal(restored.status, 200);

  const deadPool = createPool("postgres://runtime:nope@127.0.0.1:1/none");
  const deadApp = createApp({ pool: deadPool, config: env.config });
  const deadServer = createServer(deadApp.handler);
  await new Promise<void>((resolve) => {
    deadServer.listen(0, "127.0.0.1", () => resolve());
  });
  const address = deadServer.address();
  if (!address || typeof address === "string") {
    throw new Error("failed to bind");
  }
  try {
    const down = await api(`http://127.0.0.1:${address.port}`, { path: "/healthz" });
    assert.equal(down.status, 503);
    assert.deepEqual(down.json, { ok: false });
    assert.doesNotMatch(down.text, /ECONNREFUSED|password|127\.0\.0\.1/);
  } finally {
    await new Promise<void>((resolve, reject) => {
      deadServer.close((err) => (err ? reject(err) : resolve()));
    });
    await deadPool.end();
  }
});
