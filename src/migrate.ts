import { readdirSync, readFileSync } from "node:fs";
import { join } from "node:path";
import pg from "pg";
import { findProjectRoot } from "./root.js";

const { Client } = pg;

export function listMigrationFiles(root = findProjectRoot()): string[] {
  return readdirSync(join(root, "sql", "migrations"))
    .filter((name) => /^\d+_[\w-]+\.sql$/.test(name))
    .sort();
}

export function expectedMigrationHead(root = findProjectRoot()): string {
  const files = listMigrationFiles(root);
  if (files.length === 0) {
    throw new Error("no migrations found");
  }
  return files[files.length - 1]!.replace(/\.sql$/, "");
}

export function expectedMigrationVersions(root = findProjectRoot()): string[] {
  return listMigrationFiles(root).map((name) => name.replace(/\.sql$/, ""));
}

export async function migrate(connectionString: string): Promise<{
  head: string;
  applied: string[];
}> {
  const root = findProjectRoot();
  const files = listMigrationFiles(root);
  const client = new Client({ connectionString, connectionTimeoutMillis: 10_000 });
  await client.connect();
  const applied: string[] = [];
  try {
    await client.query(`
      CREATE TABLE IF NOT EXISTS schema_migrations (
        version text PRIMARY KEY,
        applied_at timestamptz NOT NULL DEFAULT now()
      )
    `);
    for (const file of files) {
      const version = file.replace(/\.sql$/, "");
      const already = await client.query(
        "SELECT 1 FROM schema_migrations WHERE version = $1",
        [version],
      );
      if ((already.rowCount ?? 0) > 0) {
        continue;
      }
      const sql = readFileSync(join(root, "sql", "migrations", file), "utf8");
      await client.query("BEGIN");
      try {
        await client.query(sql);
        await client.query(
          "INSERT INTO schema_migrations (version) VALUES ($1)",
          [version],
        );
        await client.query("COMMIT");
        applied.push(version);
      } catch (err) {
        await client.query("ROLLBACK");
        throw err;
      }
    }
    return { head: expectedMigrationHead(root), applied };
  } finally {
    await client.end();
  }
}
