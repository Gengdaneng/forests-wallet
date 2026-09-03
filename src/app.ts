import type { IncomingMessage, ServerResponse } from "node:http";
import { authenticate, type AuthDevice } from "./auth.js";
import type { AppConfig } from "./config.js";
import type { DbPool } from "./db.js";
import { HttpError, notFound } from "./errors.js";
import {
  handleBootstrap,
  handleClaimPairing,
  handleCreatePairing,
  handleHealthz,
  handleIdempotentEcho,
  handleListDevices,
  handleRevokeDevice,
  type RequestCtx,
} from "./handlers.js";
import { clientIp, sendError, sendJson } from "./http.js";
import { logError, logInfo } from "./log.js";
import { authorize, type RouteSpec } from "./policy.js";

export type Route = RouteSpec & {
  name: string;
  pattern: string;
  handler: (
    ctx: RequestCtx,
    params: Record<string, string>,
  ) => Promise<{ status: number; body: unknown }>;
};

export type App = {
  config: AppConfig;
  routes: Route[];
  handler: (req: IncomingMessage, res: ServerResponse) => void;
};

function matchRoute(
  pattern: string,
  path: string,
): Record<string, string> | null {
  const patternParts = pattern.split("/");
  const pathParts = path.split("/");
  if (patternParts.length !== pathParts.length) {
    return null;
  }
  const params: Record<string, string> = {};
  for (let i = 0; i < patternParts.length; i += 1) {
    const expected = patternParts[i]!;
    const actual = pathParts[i]!;
    if (expected.startsWith(":")) {
      params[expected.slice(1)] = actual;
      continue;
    }
    if (expected !== actual) {
      return null;
    }
  }
  return params;
}

export function buildRoutes(config: AppConfig): Route[] {
  const routes: Route[] = [
    {
      name: "healthz",
      method: "GET",
      pattern: "/healthz",
      auth: "none",
      mutating: false,
      handler: (ctx) => handleHealthz(ctx),
    },
    {
      name: "bootstrap",
      method: "POST",
      pattern: "/v1/bootstrap",
      auth: "none",
      mutating: true,
      handler: (ctx) => handleBootstrap(ctx),
    },
    {
      name: "create-pairing",
      method: "POST",
      pattern: "/v1/pairings",
      auth: "parent",
      mutating: true,
      handler: (ctx) => handleCreatePairing(ctx),
    },
    {
      name: "claim-pairing",
      method: "POST",
      pattern: "/v1/pairings/claim",
      auth: "none",
      mutating: true,
      handler: (ctx) => handleClaimPairing(ctx),
    },
    {
      name: "list-devices",
      method: "GET",
      pattern: "/v1/devices",
      auth: "parent",
      mutating: false,
      handler: (ctx) => handleListDevices(ctx),
    },
    {
      name: "revoke-device",
      method: "POST",
      pattern: "/v1/devices/:id/revoke",
      auth: "parent",
      mutating: true,
      handler: (ctx, params) => handleRevokeDevice(ctx, params.id ?? ""),
    },
  ];
  if (config.testRoutes) {
    routes.push({
      name: "idempotent-echo",
      method: "POST",
      pattern: "/v1/_test/idempotent-echo",
      auth: "parent",
      mutating: true,
      handler: (ctx) => handleIdempotentEcho(ctx),
    });
  }
  return routes;
}

export function mutatingAuthenticatedRoutes(routes: Route[]): Route[] {
  return routes.filter((route) => route.auth !== "none" && route.mutating);
}

export function createApp(opts: {
  pool: DbPool;
  config: AppConfig;
  isShuttingDown?: () => boolean;
}): App {
  const routes = buildRoutes(opts.config);

  const handler = (req: IncomingMessage, res: ServerResponse): void => {
    void dispatch(req, res);
  };

  async function dispatch(
    req: IncomingMessage,
    res: ServerResponse,
  ): Promise<void> {
    const started = Date.now();
    const ip = clientIp(req, opts.config.trustForwarded);
    const method = (req.method ?? "GET").toUpperCase();
    const url = new URL(req.url ?? "/", `http://${req.headers.host ?? "127.0.0.1"}`);
    const path = url.pathname;

    try {
      if (opts.isShuttingDown?.() && path === "/healthz") {
        sendJson(res, 503, { ok: false });
        return;
      }

      const allowedMethods = new Set<string>();
      let matched: { route: Route; params: Record<string, string> } | null =
        null;
      for (const route of routes) {
        const params = matchRoute(route.pattern, path);
        if (!params) {
          continue;
        }
        allowedMethods.add(route.method);
        if (route.method === method) {
          matched = { route, params };
        }
      }
      if (!matched) {
        if (allowedMethods.size > 0) {
          res.setHeader("allow", [...allowedMethods].join(", "));
          sendJson(res, 405, { error: "method_not_allowed" });
          return;
        }
        throw notFound();
      }

      let device: AuthDevice | null = null;
      if (matched.route.auth !== "none") {
        device = await authenticate(opts.pool, req);
        authorize(matched.route, device);
      }

      const ctx: RequestCtx = {
        pool: opts.pool,
        config: opts.config,
        ip,
        device,
        headers: req.headers,
        urlPath: path,
        method,
        req,
      };
      const result = await matched.route.handler(ctx, matched.params);
      sendJson(res, result.status, result.body);
    } catch (err) {
      if (!(err instanceof HttpError)) {
        logError("request failed", {
          method,
          path,
          ip,
          err: err instanceof Error ? err.message : "unknown",
        });
      }
      sendError(res, err);
    } finally {
      if (!req.readableEnded) {
        req.resume();
      }
      logInfo("request", {
        method,
        path,
        ip,
        status: res.statusCode,
        ms: Date.now() - started,
      });
    }
  }

  return { config: opts.config, routes, handler };
}
