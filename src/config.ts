export type AppConfig = {
  databaseUrl: string;
  host: string;
  port: number;
  bodyLimitBytes: number;
  requestTimeoutMs: number;
  healthTimeoutMs: number;
  testRoutes: boolean;
  trustForwarded: boolean;
  bootstrapWindowMs: number;
  pairingTtlMs: number;
  pairingMaxAttempts: number;
  claimIpMax: number;
  claimIpWindowMs: number;
  claimGlobalMax: number;
  claimGlobalWindowMs: number;
  bootstrapIpMax: number;
  bootstrapIpWindowMs: number;
};

function envFlag(
  env: NodeJS.Dict<string>,
  name: string,
  fallback: boolean,
): boolean {
  const raw = env[name];
  if (raw === undefined) {
    return fallback;
  }
  return raw === "1" || raw.toLowerCase() === "true";
}

function envInt(
  env: NodeJS.Dict<string>,
  name: string,
  fallback: number,
): number {
  const raw = env[name];
  if (raw === undefined || raw === "") {
    return fallback;
  }
  const n = Number(raw);
  if (!Number.isFinite(n) || n <= 0) {
    throw new Error(`invalid integer env ${name}`);
  }
  return n;
}

export function loadConfig(env = process.env): AppConfig {
  const databaseUrl = env.DATABASE_URL;
  if (!databaseUrl) {
    throw new Error("DATABASE_URL is required");
  }
  return {
    databaseUrl,
    host: env.HOST ?? "0.0.0.0",
    port: env.PORT ? Number(env.PORT) : 3000,
    bodyLimitBytes: 16 * 1024,
    requestTimeoutMs: 15_000,
    healthTimeoutMs: 1_000,
    testRoutes: envFlag(env, "FORESTS_WALLET_TEST_ROUTES", false),
    trustForwarded: envFlag(env, "TRUST_FORWARDED", true),
    bootstrapWindowMs: 30 * 60 * 1000,
    pairingTtlMs: 10 * 60 * 1000,
    pairingMaxAttempts: 5,
    claimIpMax: envInt(env, "CLAIM_THROTTLE_IP_MAX", 5),
    claimIpWindowMs: envInt(env, "CLAIM_THROTTLE_IP_WINDOW_MS", 10 * 60 * 1000),
    claimGlobalMax: envInt(env, "CLAIM_THROTTLE_GLOBAL_MAX", 30),
    claimGlobalWindowMs: envInt(env, "CLAIM_THROTTLE_GLOBAL_WINDOW_MS", 10 * 60 * 1000),
    bootstrapIpMax: envInt(env, "BOOTSTRAP_THROTTLE_IP_MAX", 5),
    bootstrapIpWindowMs: envInt(env, "BOOTSTRAP_THROTTLE_IP_WINDOW_MS", 60 * 60 * 1000),
  };
}

export function loadMigrateDatabaseUrl(env = process.env): string {
  const url = env.MIGRATE_DATABASE_URL || env.DATABASE_URL;
  if (!url) {
    throw new Error("MIGRATE_DATABASE_URL or DATABASE_URL is required");
  }
  return url;
}
