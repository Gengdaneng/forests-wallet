#!/usr/bin/env node
import { loadConfig, loadMigrateDatabaseUrl } from "./config.js";
import { createPool } from "./db.js";
import { HttpError } from "./errors.js";
import { migrate } from "./migrate.js";
import { openBootstrap, revokeAllParentDevices } from "./operators.js";

function usage(): never {
  process.stderr.write(
    "usage: fw <migrate|open-bootstrap|revoke-parent-devices>\n",
  );
  process.exit(2);
}

async function main(): Promise<void> {
  const command = process.argv[2];
  if (!command) {
    usage();
  }
  if (command === "migrate") {
    const url = loadMigrateDatabaseUrl();
    const result = await migrate(url);
    process.stdout.write(
      `${JSON.stringify({ ok: true, head: result.head, applied: result.applied })}\n`,
    );
    return;
  }
  if (command === "open-bootstrap") {
    const config = loadConfig();
    const pool = createPool(config.databaseUrl);
    try {
      const result = await openBootstrap(pool, config.bootstrapWindowMs);
      process.stdout.write(`${JSON.stringify({ ok: true, ...result })}\n`);
    } catch (err) {
      if (err instanceof HttpError && err.status === 409) {
        process.stderr.write(
          "active parent device exists; revoke parent devices first\n",
        );
        process.exitCode = 1;
        return;
      }
      throw err;
    } finally {
      await pool.end();
    }
    return;
  }
  if (
    command === "revoke-parent-devices" ||
    command === "revoke-all-parent-devices"
  ) {
    const config = loadConfig();
    const pool = createPool(config.databaseUrl);
    try {
      const result = await revokeAllParentDevices(pool);
      process.stdout.write(`${JSON.stringify({ ok: true, ...result })}\n`);
    } finally {
      await pool.end();
    }
    return;
  }
  usage();
}

main().catch((err: unknown) => {
  const message = err instanceof Error ? err.message : "unknown error";
  process.stderr.write(`${message}\n`);
  process.exit(1);
});
