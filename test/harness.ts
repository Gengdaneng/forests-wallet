import { execFile as execFileCb } from "node:child_process";
import { randomUUID } from "node:crypto";
import { createServer, type Server } from "node:http";
import { promisify } from "node:util";
import pg from "pg";
import { createApp, type App } from "../src/app.js";
import { type AppConfig, loadConfig } from "../src/config.js";
import { createPool, type DbPool } from "../src/db.js";
import { migrate } from "../src/migrate.js";
import { MIGRATOR_ROLE, RUNTIME_ROLE } from "../src/roles.js";
import { resetThrottlesForTests } from "../src/throttle.js";

const execFile = promisify(execFileCb);
const { Client } = pg;

const MIGRATOR_PASSWORD = "migrator-test-pass";
const RUNTIME_PASSWORD = "runtime-test-pass";
const SUPER_PASSWORD = "postgres";

export type JsonResponse = {
  status: number;
  json: unknown;
  text: string;
};

export type TestEnv = {
  config: AppConfig;
  pool: DbPool;
  migratorPool: DbPool;
  superUrl: string;
  migratorUrl: string;
  runtimeUrl: string;
  app: App;
  server: Server;
  baseUrl: string;
  stop: () => Promise<void>;
};

let containerId: string | null = null;
let hostPort: number | null = null;
let starting: Promise<void> | null = null;

async function docker(args: string[]): Promise<string> {
  const { stdout, stderr } = await execFile("docker", args, { encoding: "utf8" });
  if (stderr && !stdout) {
    // docker prints some notices on stderr
  }
  return stdout.trim();
}

async function sleep(ms: number): Promise<void> {
  await new Promise((resolve) => setTimeout(resolve, ms));
}

async function waitForPostgres(port: number): Promise<void> {
  const deadline = Date.now() + 40_000;
  let lastErr: unknown;
  while (Date.now() < deadline) {
    const client = new Client({
      connectionString: superUrl(port, "postgres"),
      connectionTimeoutMillis: 1_000,
    });
    try {
      await client.connect();
      await client.query("SELECT 1");
      await client.end();
      await sleep(400);
      const check = new Client({
        connectionString: superUrl(port, "postgres"),
        connectionTimeoutMillis: 1_000,
      });
      try {
        await check.connect();
        await check.query("SELECT 1");
        await check.end();
        return;
      } catch (err) {
        lastErr = err;
        try {
          await check.end();
        } catch {
          // ignore
        }
      }
    } catch (err) {
      lastErr = err;
      try {
        await client.end();
      } catch {
        // ignore
      }
      await sleep(200);
    }
  }
  throw new Error(`postgres container did not become ready: ${String(lastErr)}`);
}

async function ensureContainer(): Promise<{ port: number; id: string }> {
  if (containerId && hostPort) {
    return { port: hostPort, id: containerId };
  }
  if (starting) {
    await starting;
    return { port: hostPort!, id: containerId! };
  }
  starting = (async () => {
    const name = `fw-test-pg-${process.pid}-${randomUUID().slice(0, 8)}`;
    const id = await docker([
      "run",
      "-d",
      "--rm",
      "--name",
      name,
      "-e",
      `POSTGRES_PASSWORD=${SUPER_PASSWORD}`,
      "-p",
      "127.0.0.1:0:5432",
      "postgres:18",
      "-c",
      "fsync=off",
      "-c",
      "full_page_writes=off",
    ]);
    containerId = id;
    const mapping = await docker(["port", id, "5432/tcp"]);
    const portText = mapping.split("\n")[0]?.split(":")[1];
    const port = Number(portText);
    if (!Number.isFinite(port)) {
      throw new Error(`could not parse docker port mapping: ${mapping}`);
    }
    hostPort = port;
    await waitForPostgres(port);
    const admin = new Client({
      connectionString: superUrl(port, "postgres"),
    });
    await admin.connect();
    try {
      await admin.query(
        `CREATE ROLE ${MIGRATOR_ROLE} LOGIN PASSWORD '${MIGRATOR_PASSWORD}' NOSUPERUSER`,
      );
      await admin.query(
        `CREATE ROLE ${RUNTIME_ROLE} LOGIN PASSWORD '${RUNTIME_PASSWORD}' NOSUPERUSER NOCREATEDB NOCREATEROLE`,
      );
    } finally {
      await admin.end();
    }
  })();
  try {
    await starting;
  } finally {
    starting = null;
  }
  return { port: hostPort!, id: containerId! };
}

function superUrl(port: number, db: string): string {
  return `postgres://postgres:${SUPER_PASSWORD}@127.0.0.1:${port}/${db}`;
}

function roleUrl(role: string, password: string, port: number, db: string): string {
  return `postgres://${role}:${encodeURIComponent(password)}@127.0.0.1:${port}/${db}`;
}

export async function startEnv(opts?: {
  testRoutes?: boolean;
  extraEnv?: Record<string, string>;
}): Promise<TestEnv> {
  resetThrottlesForTests();
  const { port } = await ensureContainer();
  const dbName = `fw_${randomUUID().replaceAll("-", "")}`;
  const admin = new Client({ connectionString: superUrl(port, "postgres") });
  await admin.connect();
  try {
    await admin.query(`CREATE DATABASE ${dbName} OWNER ${MIGRATOR_ROLE}`);
  } finally {
    await admin.end();
  }

  const migratorUrl = roleUrl(MIGRATOR_ROLE, MIGRATOR_PASSWORD, port, dbName);
  const runtimeUrl = roleUrl(RUNTIME_ROLE, RUNTIME_PASSWORD, port, dbName);
  await migrate(migratorUrl);

  const config = loadConfig({
    DATABASE_URL: runtimeUrl,
    FORESTS_WALLET_TEST_ROUTES: opts?.testRoutes === false ? "0" : "1",
    TRUST_FORWARDED: "true",
    HOST: "127.0.0.1",
    PORT: "0",
    ...opts?.extraEnv,
  });
  const pool = createPool(runtimeUrl);
  const migratorPool = createPool(migratorUrl);
  const app = createApp({ pool, config });
  const server = createServer(app.handler);
  await new Promise<void>((resolve) => {
    server.listen(0, "127.0.0.1", () => resolve());
  });
  const address = server.address();
  if (!address || typeof address === "string") {
    throw new Error("failed to bind test server");
  }

  let stopped = false;
  return {
    config,
    pool,
    migratorPool,
    superUrl: superUrl(port, dbName),
    migratorUrl,
    runtimeUrl,
    app,
    server,
    baseUrl: `http://127.0.0.1:${address.port}`,
    stop: async () => {
      if (stopped) {
        return;
      }
      stopped = true;
      await new Promise<void>((resolve, reject) => {
        server.close((err) => (err ? reject(err) : resolve()));
      });
      await pool.end();
      await migratorPool.end();
      const drop = new Client({ connectionString: superUrl(port, "postgres") });
      await drop.connect();
      try {
        await drop.query(
          `SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = $1`,
          [dbName],
        );
        await drop.query(`DROP DATABASE IF EXISTS ${dbName}`);
      } finally {
        await drop.end();
      }
    },
  };
}

export async function stopSharedContainer(): Promise<void> {
  if (containerId) {
    const id = containerId;
    containerId = null;
    hostPort = null;
    try {
      await docker(["rm", "-f", id]);
    } catch {
      // already gone
    }
  }
}

process.on("exit", () => {
  if (containerId) {
    execFileCb("docker", ["rm", "-f", containerId], () => undefined);
  }
});

export async function api(
  baseUrl: string,
  opts: {
    method?: string;
    path: string;
    token?: string;
    body?: unknown;
    headers?: Record<string, string>;
    ip?: string;
    json?: boolean;
  },
): Promise<JsonResponse> {
  const headers: Record<string, string> = { ...(opts.headers ?? {}) };
  if (opts.body !== undefined && opts.json !== false) {
    headers["content-type"] ??= "application/json";
  }
  if (opts.token) {
    headers.authorization = `Bearer ${opts.token}`;
  }
  if (opts.ip) {
    headers["x-forwarded-for"] = opts.ip;
  }
  const res = await fetch(`${baseUrl}${opts.path}`, {
    method: opts.method ?? "GET",
    headers,
    body:
      opts.body === undefined
        ? undefined
        : opts.json === false
          ? (opts.body as string)
          : JSON.stringify(opts.body),
  });
  const text = await res.text();
  let json: unknown = null;
  try {
    json = JSON.parse(text);
  } catch {
    json = null;
  }
  return { status: res.status, json, text };
}

export function asObject(json: unknown): Record<string, unknown> {
  if (!json || typeof json !== "object" || Array.isArray(json)) {
    throw new Error(`expected object, got ${textPreview(json)}`);
  }
  return json as Record<string, unknown>;
}

function textPreview(value: unknown): string {
  return JSON.stringify(value);
}

export async function captureLogs<T>(
  fn: () => Promise<T>,
): Promise<{ result: T; logs: string }> {
  const chunks: string[] = [];
  const wrap = (stream: NodeJS.WriteStream) => {
    const orig = stream.write.bind(stream);
    stream.write = ((chunk: unknown, ...rest: unknown[]) => {
      chunks.push(String(chunk));
      return (orig as (...args: unknown[]) => boolean)(chunk, ...rest);
    }) as typeof stream.write;
    return orig;
  };
  const out = wrap(process.stdout);
  const err = wrap(process.stderr);
  try {
    const result = await fn();
    return { result, logs: chunks.join("") };
  } finally {
    process.stdout.write = out;
    process.stderr.write = err;
  }
}
