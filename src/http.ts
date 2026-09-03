import type { IncomingMessage, ServerResponse } from "node:http";
import { HttpError, invalid, tooLarge, unsupportedMediaType } from "./errors.js";

export type JsonObject = Record<string, unknown>;

export function clientIp(
  req: IncomingMessage,
  trustForwarded: boolean,
): string {
  if (trustForwarded) {
    const forwarded = req.headers["x-forwarded-for"];
    const raw = Array.isArray(forwarded) ? forwarded[0] : forwarded;
    const first = raw?.split(",")[0]?.trim();
    if (first) {
      return first;
    }
  }
  return req.socket.remoteAddress ?? "unknown";
}

export function sendJson(
  res: ServerResponse,
  status: number,
  body: unknown,
): void {
  if (res.writableEnded) {
    return;
  }
  const payload = Buffer.from(JSON.stringify(body));
  res.writeHead(status, {
    "content-type": "application/json; charset=utf-8",
    "content-length": payload.length,
    "cache-control": "no-store",
    "x-content-type-options": "nosniff",
  });
  res.end(payload);
}

export function sendError(res: ServerResponse, err: unknown): void {
  if (err instanceof HttpError) {
    sendJson(res, err.status, { error: err.code });
    return;
  }
  sendJson(res, 500, { error: "internal" });
}

function contentType(req: IncomingMessage): string {
  const raw = req.headers["content-type"];
  const value = Array.isArray(raw) ? raw[0] : raw;
  return (value ?? "").split(";")[0]?.trim().toLowerCase() ?? "";
}

export async function readJsonBody(
  req: IncomingMessage,
  limitBytes: number,
  opts: { allowEmpty?: boolean } = {},
): Promise<JsonObject> {
  const type = contentType(req);
  const declared = Number(req.headers["content-length"] ?? "0");
  if (!type) {
    if (opts.allowEmpty && (!Number.isFinite(declared) || declared === 0)) {
      return {};
    }
    throw unsupportedMediaType();
  }
  if (type !== "application/json") {
    throw unsupportedMediaType();
  }
  const chunks: Buffer[] = [];
  let size = 0;
  for await (const chunk of req) {
    const buf = Buffer.isBuffer(chunk) ? chunk : Buffer.from(chunk);
    size += buf.length;
    if (size > limitBytes) {
      req.destroy();
      throw tooLarge();
    }
    chunks.push(buf);
  }
  if (size === 0) {
    if (opts.allowEmpty) {
      return {};
    }
    throw invalid();
  }
  let parsed: unknown;
  try {
    parsed = JSON.parse(Buffer.concat(chunks).toString("utf8"));
  } catch {
    throw invalid();
  }
  if (parsed === null || typeof parsed !== "object" || Array.isArray(parsed)) {
    throw invalid();
  }
  return parsed as JsonObject;
}

export function readString(
  body: JsonObject,
  key: string,
  opts: { min?: number; max?: number } = {},
): string {
  const value = body[key];
  if (typeof value !== "string") {
    throw invalid();
  }
  const trimmed = value.trim();
  const min = opts.min ?? 1;
  const max = opts.max ?? 128;
  if (trimmed.length < min || trimmed.length > max) {
    throw invalid();
  }
  return trimmed;
}
