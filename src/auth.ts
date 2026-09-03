import type { IncomingMessage } from "node:http";
import { hashesEqual, sha256Buffer } from "./crypto.js";
import type { DbClient, DbPool } from "./db.js";
import { unauthorized } from "./errors.js";

export type DeviceRole = "parent" | "child";

export type AuthDevice = {
  id: string;
  childId: string;
  role: DeviceRole;
  label: string;
};

type DeviceRow = {
  id: string;
  child_id: string;
  role: string;
  label: string;
  token_hash: Buffer;
};

export function parseBearer(req: IncomingMessage): string | null {
  const header = req.headers.authorization;
  const value = Array.isArray(header) ? header[0] : header;
  if (!value) {
    return null;
  }
  const match = /^Bearer\s+(\S+)$/i.exec(value);
  return match?.[1] ?? null;
}

export async function authenticate(
  db: DbPool | DbClient,
  req: IncomingMessage,
): Promise<AuthDevice> {
  const token = parseBearer(req);
  if (!token) {
    throw unauthorized();
  }
  const tokenHash = sha256Buffer(token);
  const result = await db.query<DeviceRow>(
    `SELECT id, child_id, role, label, token_hash
       FROM devices
      WHERE token_hash = $1
        AND revoked_at IS NULL
        AND status = 'active'`,
    [tokenHash],
  );
  const row = result.rows[0];
  if (!row || !hashesEqual(row.token_hash, tokenHash)) {
    throw unauthorized();
  }
  if (row.role !== "parent" && row.role !== "child") {
    throw unauthorized();
  }
  await db.query("UPDATE devices SET last_seen_at = now() WHERE id = $1", [
    row.id,
  ]);
  return {
    id: row.id,
    childId: row.child_id,
    role: row.role,
    label: row.label,
  };
}
