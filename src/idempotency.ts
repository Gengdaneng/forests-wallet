import { hashesEqual, isUuidLike, requestHash } from "./crypto.js";
import type { DbClient } from "./db.js";
import { conflict, invalid } from "./errors.js";

export type StoredResponse = {
  status: number;
  body: unknown;
};

export function readIdempotencyKey(
  headers: Record<string, string | string[] | undefined>,
): string {
  const raw = headers["idempotency-key"];
  const value = Array.isArray(raw) ? raw[0] : raw;
  if (!value || !isUuidLike(value)) {
    throw invalid();
  }
  return value;
}

export async function withIdempotency(
  client: DbClient,
  opts: {
    deviceId: string;
    key: string;
    method: string;
    path: string;
    body: unknown;
    handler: () => Promise<StoredResponse>;
  },
): Promise<StoredResponse> {
  const hash = requestHash(opts.method, opts.path, opts.body);
  await client.query("SELECT id FROM devices WHERE id = $1 FOR UPDATE", [
    opts.deviceId,
  ]);
  const existing = await client.query<{
    request_hash: Buffer;
    response_status: number;
    response_body: string;
  }>(
    `SELECT request_hash, response_status, response_body
       FROM idempotency_keys
      WHERE device_id = $1 AND idempotency_key = $2`,
    [opts.deviceId, opts.key],
  );
  const row = existing.rows[0];
  if (row) {
    if (!hashesEqual(row.request_hash, hash)) {
      throw conflict();
    }
    return {
      status: row.response_status,
      body: JSON.parse(row.response_body) as unknown,
    };
  }
  const result = await opts.handler();
  await client.query(
    `INSERT INTO idempotency_keys
       (device_id, idempotency_key, request_hash, response_status, response_body)
     VALUES ($1, $2, $3, $4, $5)`,
    [
      opts.deviceId,
      opts.key,
      hash,
      result.status,
      JSON.stringify(result.body),
    ],
  );
  return result;
}
