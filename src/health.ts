import {
  expectedMigrationHead,
  expectedMigrationVersions,
} from "./migrate.js";
import type { DbPool } from "./db.js";

export async function checkHealth(
  pool: DbPool,
  timeoutMs: number,
): Promise<boolean> {
  const expected = expectedMigrationVersions();
  const head = expectedMigrationHead();
  let client;
  try {
    client = await Promise.race([
      pool.connect(),
      sleepReject(timeoutMs, "health connect timeout"),
    ]);
    await client.query("BEGIN");
    const timeout = Math.max(1, Math.floor(timeoutMs));
    await client.query(`SET LOCAL statement_timeout = '${timeout}ms'`);
    await client.query("SELECT 1");
    const applied = await client.query<{ version: string }>(
      "SELECT version FROM schema_migrations ORDER BY version",
    );
    await client.query("COMMIT");
    const versions = applied.rows.map((row) => row.version);
    if (versions.length !== expected.length) {
      return false;
    }
    for (let i = 0; i < expected.length; i += 1) {
      if (versions[i] !== expected[i]) {
        return false;
      }
    }
    return versions[versions.length - 1] === head;
  } catch {
    if (client) {
      try {
        await client.query("ROLLBACK");
      } catch {
        // ignore
      }
    }
    return false;
  } finally {
    client?.release();
  }
}

function sleepReject(ms: number, message: string): Promise<never> {
  return new Promise((_, reject) => {
    setTimeout(() => reject(new Error(message)), ms).unref();
  });
}
