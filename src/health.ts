import {
  expectedMigrationHead,
  expectedMigrationVersions,
} from "./migrate.js";
import type { DbClient, DbPool } from "./db.js";

export async function connectWithTimeout<T extends { release: () => void }>(
  pool: { connect: () => Promise<T> },
  timeoutMs: number,
): Promise<T> {
  let settled = false;
  const pending = pool.connect().then((client) => {
    if (settled) {
      client.release();
    }
    return client;
  });

  let timer: ReturnType<typeof setTimeout> | undefined;
  try {
    return await new Promise<T>((resolve, reject) => {
      timer = setTimeout(() => {
        settled = true;
        reject(new Error("health connect timeout"));
      }, timeoutMs);
      timer.unref();
      pending.then(
        (client) => {
          if (!settled) {
            settled = true;
            resolve(client);
          }
        },
        (err: unknown) => {
          if (!settled) {
            settled = true;
            reject(err);
          }
        },
      );
    });
  } finally {
    if (timer) {
      clearTimeout(timer);
    }
  }
}

export async function checkHealth(
  pool: DbPool,
  timeoutMs: number,
): Promise<boolean> {
  const expected = expectedMigrationVersions();
  const head = expectedMigrationHead();
  let client: DbClient | undefined;
  try {
    const acquired = await connectWithTimeout<DbClient>(pool, timeoutMs);
    client = acquired;
    await acquired.query("BEGIN");
    const timeout = Math.max(1, Math.floor(timeoutMs));
    await acquired.query(`SET LOCAL statement_timeout = '${timeout}ms'`);
    await acquired.query("SELECT 1");
    const applied = await acquired.query<{ version: string }>(
      "SELECT version FROM schema_migrations ORDER BY version",
    );
    await acquired.query("COMMIT");
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
