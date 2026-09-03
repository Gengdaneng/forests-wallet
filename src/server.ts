import { createServer } from "node:http";
import { createApp } from "./app.js";
import { loadConfig } from "./config.js";
import { createPool } from "./db.js";
import { logError, logInfo } from "./log.js";
import { closeServerThenPool } from "./shutdown.js";

const config = loadConfig();
const pool = createPool(config.databaseUrl);
let shuttingDown = false;

const app = createApp({
  pool,
  config,
  isShuttingDown: () => shuttingDown,
});

const server = createServer(app.handler);
server.requestTimeout = config.requestTimeoutMs;
server.headersTimeout = Math.min(config.requestTimeoutMs, 10_000);
server.keepAliveTimeout = 5_000;

server.listen(config.port, config.host, () => {
  logInfo("listening", { host: config.host, port: config.port });
});

async function shutdown(signal: string): Promise<void> {
  if (shuttingDown) {
    return;
  }
  shuttingDown = true;
  logInfo("shutdown", { signal });
  try {
    await closeServerThenPool(server, pool, 10_000);
    process.exit(0);
  } catch (err) {
    logError("shutdown failed", {
      err: err instanceof Error ? err.message : "unknown",
    });
    process.exit(1);
  }
}

process.on("SIGTERM", () => {
  void shutdown("SIGTERM");
});
process.on("SIGINT", () => {
  void shutdown("SIGINT");
});
