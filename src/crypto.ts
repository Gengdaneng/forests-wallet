import { createHash, randomBytes, randomInt, timingSafeEqual } from "node:crypto";

export function sha256Buffer(value: string | Buffer): Buffer {
  return createHash("sha256").update(value).digest();
}

export function generateToken(): { token: string; tokenHash: Buffer } {
  const token = randomBytes(32).toString("base64url");
  return { token, tokenHash: sha256Buffer(token) };
}

export function generatePairingCode(): { code: string; codeHash: Buffer } {
  const code = String(randomInt(0, 1_000_000)).padStart(6, "0");
  return { code, codeHash: sha256Buffer(code) };
}

export function hashesEqual(a: Buffer, b: Buffer): boolean {
  if (a.length !== b.length) {
    return false;
  }
  return timingSafeEqual(a, b);
}

export function dummyHashCompare(): void {
  const dummy = sha256Buffer("000000");
  timingSafeEqual(dummy, dummy);
}

export const UUID_RE =
  /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

export function isUuidLike(value: string): boolean {
  return UUID_RE.test(value);
}

export function canonicalJson(value: unknown): string {
  return JSON.stringify(sortValue(value));
}

function sortValue(value: unknown): unknown {
  if (Array.isArray(value)) {
    return value.map(sortValue);
  }
  if (value && typeof value === "object") {
    const obj = value as Record<string, unknown>;
    const sorted: Record<string, unknown> = {};
    for (const key of Object.keys(obj).sort()) {
      sorted[key] = sortValue(obj[key]);
    }
    return sorted;
  }
  return value;
}

export function requestHash(
  method: string,
  path: string,
  body: unknown,
): Buffer {
  return sha256Buffer(`${method}\n${path}\n${canonicalJson(body)}`);
}
