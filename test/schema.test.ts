import assert from "node:assert/strict";
import { after, before, test } from "node:test";
import pg from "pg";
import { randomUUID } from "node:crypto";
import { sha256Buffer } from "../src/crypto.js";
import { expectedMigrationHead, expectedMigrationVersions } from "../src/migrate.js";
import { RUNTIME_ROLE } from "../src/roles.js";
import { startEnv, stopSharedContainer, type TestEnv } from "./harness.js";

const { Client } = pg;

let env: TestEnv;

before(async () => {
  env = await startEnv();
});

after(async () => {
  await env?.stop();
  await stopSharedContainer();
});

test("fresh postgres migrates to the expected head and seeds categories", async () => {
  const versions = await env.pool.query<{ version: string }>(
    "SELECT version FROM schema_migrations ORDER BY version",
  );
  assert.deepEqual(
    versions.rows.map((row) => row.version),
    expectedMigrationVersions(),
  );
  assert.equal(versions.rows.at(-1)?.version, expectedMigrationHead());

  const settings = await env.pool.query<{
    timezone: string;
    currency_scale: number;
    bootstrap_open_until: Date | null;
  }>("SELECT timezone, currency_scale, bootstrap_open_until FROM settings");
  assert.equal(settings.rows.length, 1);
  assert.equal(settings.rows[0]?.timezone, "Asia/Shanghai");
  assert.equal(settings.rows[0]?.currency_scale, 100);
  assert.equal(settings.rows[0]?.bootstrap_open_until, null);

  const categories = await env.pool.query<{ slug: string; label: string }>(
    "SELECT slug, label FROM categories ORDER BY sort",
  );
  assert.deepEqual(
    categories.rows.map((row) => [row.slug, row.label]),
    [
      ["food", "吃的"],
      ["toys", "玩具"],
      ["games", "游戏"],
      ["books", "书和文具"],
      ["gifts", "送人的礼物"],
      ["other", "其他"],
    ],
  );

  const children = await env.pool.query("SELECT id FROM children");
  assert.equal(children.rowCount, 1);

  const settlement = await env.pool.query<{ indexname: string }>(
    `SELECT indexname FROM pg_indexes
      WHERE tablename = 'transactions'
        AND indexname = 'transactions_one_weekly_settlement'`,
  );
  assert.equal(settlement.rowCount, 1);
});

test("runtime role is not superuser and cannot DDL", async () => {
  const role = await env.pool.query<{
    rolsuper: boolean;
    rolcreatedb: boolean;
    rolcreaterole: boolean;
    current_user: string;
  }>(
    `SELECT current_user, rolsuper, rolcreatedb, rolcreaterole
       FROM pg_roles
      WHERE rolname = current_user`,
  );
  assert.equal(role.rows[0]?.current_user, RUNTIME_ROLE);
  assert.equal(role.rows[0]?.rolsuper, false);
  assert.equal(role.rows[0]?.rolcreatedb, false);
  assert.equal(role.rows[0]?.rolcreaterole, false);

  await assert.rejects(
    () => env.pool.query("CREATE TABLE runtime_should_fail (id int)"),
    /permission denied|must be owner/i,
  );
  await assert.rejects(
    () => env.pool.query("ALTER TABLE transactions ADD COLUMN extra_col int"),
    /must be owner|permission denied/i,
  );
});

test("runtime cannot UPDATE or DELETE the transactions ledger", async () => {
  const child = await env.pool.query<{ id: string }>(
    "SELECT id FROM children LIMIT 1",
  );
  const category = await env.pool.query<{ id: string }>(
    "SELECT id FROM categories WHERE slug = 'other'",
  );
  const device = await env.pool.query<{ id: string }>(
    `INSERT INTO devices (child_id, role, status, label, token_hash)
     VALUES ($1, 'parent', 'active', 'schema-test', $2)
     RETURNING id`,
    [child.rows[0]!.id, sha256Buffer("schema-test-token")],
  );
  const tx = await env.pool.query<{ id: string }>(
    `INSERT INTO transactions (
        child_id, amount_fen, occurred_on, memo, category_id, kind,
        idempotency_key, request_hash, device_id
      ) VALUES ($1, 1000, CURRENT_DATE, '', $2, 'income_temp', $3, $4, $5)
      RETURNING id`,
    [
      child.rows[0]!.id,
      category.rows[0]!.id,
      randomUUID(),
      sha256Buffer("schema-test-request"),
      device.rows[0]!.id,
    ],
  );

  await assert.rejects(
    () =>
      env.pool.query("UPDATE transactions SET amount_fen = 2000 WHERE id = $1", [
        tx.rows[0]!.id,
      ]),
    /permission denied/i,
  );
  await assert.rejects(
    () => env.pool.query("DELETE FROM transactions WHERE id = $1", [tx.rows[0]!.id]),
    /permission denied/i,
  );

  const week = "2026-08-31";
  await env.pool.query(
    `INSERT INTO transactions (
        child_id, amount_fen, occurred_on, memo, category_id, kind,
        settlement_week_start, rule_snapshot, idempotency_key, request_hash, device_id
      ) VALUES ($1, 1000, $2, '', $3, 'allowance_weekly', $2, '跳绳 5/5 → +5', $4, $5, $6)`,
    [
      child.rows[0]!.id,
      week,
      category.rows[0]!.id,
      randomUUID(),
      sha256Buffer("settlement-1"),
      device.rows[0]!.id,
    ],
  );
  await assert.rejects(
    () =>
      env.pool.query(
        `INSERT INTO transactions (
            child_id, amount_fen, occurred_on, memo, category_id, kind,
            settlement_week_start, rule_snapshot, idempotency_key, request_hash, device_id
          ) VALUES ($1, 1000, $2, '', $3, 'allowance_weekly', $2, '跳绳 5/5 → +5', $4, $5, $6)`,
        [
          child.rows[0]!.id,
          week,
          category.rows[0]!.id,
          randomUUID(),
          sha256Buffer("settlement-2"),
          device.rows[0]!.id,
        ],
      ),
    (err: unknown) =>
      typeof err === "object" &&
      err !== null &&
      "code" in err &&
      (err as { code: string }).code === "23505",
  );
});

test("migrator connection can DDL while runtime cannot", async () => {
  await env.migratorPool.query(
    "CREATE TABLE migrator_probe (id int PRIMARY KEY)",
  );
  await env.migratorPool.query("DROP TABLE migrator_probe");
  const who = new Client({ connectionString: env.runtimeUrl });
  await who.connect();
  try {
    await assert.rejects(() => who.query("CREATE TABLE migrator_probe (id int)"));
  } finally {
    await who.end();
  }
});
