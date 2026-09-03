import { randomUUID } from "node:crypto";
import type { AuthDevice } from "./auth.js";
import type { AppConfig } from "./config.js";
import {
  dummyHashCompare,
  generatePairingCode,
  generateToken,
  hashesEqual,
  isUuidLike,
  sha256Buffer,
} from "./crypto.js";
import type { DbClient, DbPool } from "./db.js";
import { withTransaction } from "./db.js";
import {
  conflict,
  forbidden,
  invalid,
  notFound,
  tooManyRequests,
  unauthorized,
} from "./errors.js";
import { checkHealth } from "./health.js";
import { readJsonBody, readString } from "./http.js";
import { readIdempotencyKey, withIdempotency } from "./idempotency.js";
import { isUniqueViolation } from "./pg-error.js";
import { bootstrapThrottle, claimThrottle } from "./throttle.js";

export type RequestCtx = {
  pool: DbPool;
  config: AppConfig;
  ip: string;
  device: AuthDevice | null;
  headers: Record<string, string | string[] | undefined>;
  urlPath: string;
  method: string;
  req: import("node:http").IncomingMessage;
};

async function singletonChildId(client: DbClient): Promise<string> {
  const result = await client.query<{ id: string }>(
    "SELECT id FROM children ORDER BY created_at ASC LIMIT 1",
  );
  const id = result.rows[0]?.id;
  if (!id) {
    throw new Error("no child row");
  }
  return id;
}

export async function handleHealthz(ctx: RequestCtx): Promise<{
  status: number;
  body: unknown;
}> {
  const ok = await checkHealth(ctx.pool, ctx.config.healthTimeoutMs);
  if (!ok) {
    return { status: 503, body: { ok: false } };
  }
  return { status: 200, body: { ok: true } };
}

export async function handleBootstrap(ctx: RequestCtx): Promise<{
  status: number;
  body: unknown;
}> {
  if (
    !bootstrapThrottle.hit(ctx.ip, {
      max: ctx.config.bootstrapIpMax,
      windowMs: ctx.config.bootstrapIpWindowMs,
    })
  ) {
    throw tooManyRequests();
  }
  const body = await readJsonBody(ctx.req, ctx.config.bodyLimitBytes);
  const deviceLabel = readString(body, "device_label", { min: 1, max: 64 });

  return withTransaction(ctx.pool, async (client) => {
    const settings = await client.query<{ bootstrap_open_until: Date | null }>(
      "SELECT bootstrap_open_until FROM settings WHERE id = true FOR UPDATE",
    );
    const until = settings.rows[0]?.bootstrap_open_until;
    if (!until || until.getTime() <= Date.now()) {
      throw forbidden();
    }
    const active = await client.query(
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
    const childId = await singletonChildId(client);
    const { token, tokenHash } = generateToken();
    let inserted;
    try {
      inserted = await client.query<{ id: string }>(
        `INSERT INTO devices (child_id, role, status, label, token_hash)
         VALUES ($1, 'parent', 'active', $2, $3)
         RETURNING id`,
        [childId, deviceLabel, tokenHash],
      );
    } catch (err) {
      if (isUniqueViolation(err)) {
        throw conflict();
      }
      throw err;
    }
    await client.query(
      "UPDATE settings SET bootstrap_open_until = NULL WHERE id = true",
    );
    return {
      status: 201,
      body: {
        token,
        device_id: inserted.rows[0]!.id,
        role: "parent",
      },
    };
  });
}

type LivePairingRow = {
  id: string;
  pairing_code_hash: Buffer;
  pairing_expires_at: Date;
  pairing_attempts: number;
};

export async function handleCreatePairing(ctx: RequestCtx): Promise<{
  status: number;
  body: unknown;
}> {
  const body = await readJsonBody(ctx.req, ctx.config.bodyLimitBytes, {
    allowEmpty: true,
  });
  const deviceLabel =
    typeof body.device_label === "string" ? body.device_label.trim() : "";
  if (deviceLabel.length > 64) {
    throw invalid();
  }
  const { code, codeHash } = generatePairingCode();
  return withTransaction(ctx.pool, async (client) => {
    await client.query(
      `UPDATE devices
          SET status = 'revoked',
              revoked_at = now()
        WHERE pairing_code_hash IS NOT NULL
          AND token_hash IS NULL
          AND revoked_at IS NULL`,
    );
    const childId = ctx.device?.childId ?? (await singletonChildId(client));
    await client.query(
      `INSERT INTO devices
         (child_id, role, status, label, pairing_code_hash, pairing_expires_at, pairing_attempts)
       VALUES ($1, 'child', 'pending', $2, $3, now() + interval '10 minutes', 0)`,
      [childId, deviceLabel, codeHash],
    );
    return {
      status: 201,
      body: { code, expires_in_seconds: 600 },
    };
  });
}

export async function handleClaimPairing(ctx: RequestCtx): Promise<{
  status: number;
  body: unknown;
}> {
  if (
    !claimThrottle.hit(`ip:${ctx.ip}`, {
      max: ctx.config.claimIpMax,
      windowMs: ctx.config.claimIpWindowMs,
    }) ||
    !claimThrottle.hit("global", {
      max: ctx.config.claimGlobalMax,
      windowMs: ctx.config.claimGlobalWindowMs,
    })
  ) {
    throw tooManyRequests();
  }
  const body = await readJsonBody(ctx.req, ctx.config.bodyLimitBytes);
  const code = typeof body.code === "string" ? body.code.trim() : "";
  const wellFormed = /^\d{6}$/.test(code);
  const submittedHash = sha256Buffer(wellFormed ? code : "000000");

  const outcome = await withTransaction(ctx.pool, async (client) => {
    const live = await client.query<LivePairingRow>(
      `SELECT id, pairing_code_hash, pairing_expires_at, pairing_attempts
         FROM devices
        WHERE pairing_code_hash IS NOT NULL
          AND token_hash IS NULL
          AND revoked_at IS NULL
        FOR UPDATE`,
    );
    const row = live.rows[0];
    if (!row) {
      dummyHashCompare();
      return { kind: "unauthorized" as const };
    }
    const match =
      wellFormed && hashesEqual(row.pairing_code_hash, submittedHash);
    if (!match) {
      const attempts = row.pairing_attempts + 1;
      if (attempts >= ctx.config.pairingMaxAttempts) {
        await client.query(
          `UPDATE devices
              SET status = 'revoked',
                  revoked_at = now(),
                  pairing_attempts = $2
            WHERE id = $1`,
          [row.id, attempts],
        );
      } else {
        await client.query(
          "UPDATE devices SET pairing_attempts = $2 WHERE id = $1",
          [row.id, attempts],
        );
      }
      return { kind: "unauthorized" as const };
    }
    if (row.pairing_expires_at.getTime() <= Date.now()) {
      await client.query(
        `UPDATE devices
            SET status = 'revoked',
                revoked_at = now()
          WHERE id = $1`,
        [row.id],
      );
      return { kind: "unauthorized" as const };
    }
    await client.query(
      `UPDATE devices
          SET status = 'revoked',
              revoked_at = now()
        WHERE role = 'child'
          AND token_hash IS NOT NULL
          AND revoked_at IS NULL
          AND id <> $1`,
      [row.id],
    );
    const { token, tokenHash } = generateToken();
    await client.query(
      `UPDATE devices
          SET status = 'active',
              token_hash = $2,
              pairing_code_hash = NULL,
              pairing_expires_at = NULL,
              pairing_attempts = 0,
              last_seen_at = now()
        WHERE id = $1`,
      [row.id, tokenHash],
    );
    return {
      kind: "ok" as const,
      token,
      deviceId: row.id,
    };
  });
  if (outcome.kind !== "ok") {
    throw unauthorized();
  }
  return {
    status: 201,
    body: {
      token: outcome.token,
      device_id: outcome.deviceId,
      role: "child",
    },
  };
}

export async function handleListDevices(ctx: RequestCtx): Promise<{
  status: number;
  body: unknown;
}> {
  const result = await ctx.pool.query<{
    id: string;
    role: string;
    status: string;
    label: string;
    revoked_at: Date | null;
    last_seen_at: Date | null;
    created_at: Date;
  }>(
    `SELECT id, role, status, label, revoked_at, last_seen_at, created_at
       FROM devices
      ORDER BY created_at ASC`,
  );
  return {
    status: 200,
    body: {
      devices: result.rows.map((row) => ({
        id: row.id,
        role: row.role,
        status: row.status,
        label: row.label,
        revoked_at: row.revoked_at ? row.revoked_at.toISOString() : null,
        last_seen_at: row.last_seen_at ? row.last_seen_at.toISOString() : null,
        created_at: row.created_at.toISOString(),
      })),
    },
  };
}

export async function handleRevokeDevice(
  ctx: RequestCtx,
  deviceId: string,
): Promise<{ status: number; body: unknown }> {
  if (!isUuidLike(deviceId)) {
    throw notFound();
  }
  const result = await ctx.pool.query<{ id: string }>(
    `UPDATE devices
        SET status = 'revoked',
            revoked_at = now()
      WHERE id = $1
        AND revoked_at IS NULL
      RETURNING id`,
    [deviceId],
  );
  if ((result.rowCount ?? 0) === 0) {
    const exists = await ctx.pool.query("SELECT 1 FROM devices WHERE id = $1", [
      deviceId,
    ]);
    if ((exists.rowCount ?? 0) === 0) {
      throw notFound();
    }
  }
  return { status: 200, body: { ok: true } };
}

export async function handleIdempotentEcho(ctx: RequestCtx): Promise<{
  status: number;
  body: unknown;
}> {
  if (!ctx.device) {
    throw unauthorized();
  }
  const key = readIdempotencyKey(ctx.headers);
  const body = await readJsonBody(ctx.req, ctx.config.bodyLimitBytes);
  return withTransaction(ctx.pool, async (client) => {
    return withIdempotency(client, {
      deviceId: ctx.device!.id,
      key,
      method: ctx.method,
      path: ctx.urlPath,
      body,
      handler: async () => ({
        status: 200,
        body: { ok: true, echo: body, nonce: randomUUID() },
      }),
    });
  });
}

