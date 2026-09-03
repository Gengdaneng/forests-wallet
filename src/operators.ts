import { conflict } from "./errors.js";
import type { DbPool } from "./db.js";

export async function openBootstrap(
  pool: DbPool,
  windowMs = 30 * 60 * 1000,
): Promise<{ until: string }> {
  const active = await pool.query(
    `SELECT 1
       FROM devices
      WHERE role = 'parent'
        AND revoked_at IS NULL
        AND token_hash IS NOT NULL
      LIMIT 1`,
  );
  if ((active.rowCount ?? 0) > 0) {
    throw conflict();
  }
  const until = new Date(Date.now() + windowMs);
  await pool.query(
    `UPDATE settings
        SET bootstrap_open_until = $1
      WHERE id = true`,
    [until.toISOString()],
  );
  return { until: until.toISOString() };
}

export async function revokeAllParentDevices(
  pool: DbPool,
): Promise<{ count: number }> {
  const result = await pool.query(
    `UPDATE devices
        SET revoked_at = now(),
            status = 'revoked',
            pairing_code_hash = NULL,
            pairing_expires_at = NULL
      WHERE role = 'parent'
        AND revoked_at IS NULL`,
  );
  return { count: result.rowCount ?? 0 };
}

export async function loadSingletonChildId(pool: DbPool): Promise<string> {
  const result = await pool.query<{ id: string }>(
    "SELECT id FROM children ORDER BY created_at ASC LIMIT 1",
  );
  const id = result.rows[0]?.id;
  if (!id) {
    throw new Error("no child row");
  }
  return id;
}
