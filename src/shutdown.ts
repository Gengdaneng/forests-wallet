import type { Server } from "node:http";

export async function closeServerThenPool(
  server: Server,
  pool: { end: () => Promise<void> },
  timeoutMs = 10_000,
): Promise<void> {
  await new Promise<void>((resolve, reject) => {
    const force = setTimeout(() => {
      reject(new Error("shutdown timeout"));
    }, timeoutMs);
    force.unref();
    server.close((err) => {
      clearTimeout(force);
      if (err) {
        reject(err);
        return;
      }
      resolve();
    });
    server.closeIdleConnections();
  });
  await pool.end();
}
