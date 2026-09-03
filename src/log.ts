const SECRET_KEY =
  /^(authorization|token|code|pairing_code|pairingcode|idempotency-key|idempotency_key)$/i;

const SECRET_PATTERN =
  /Bearer\s+\S+/gi;

export type LogFields = Record<string, unknown>;

function redactValue(value: unknown): unknown {
  if (typeof value === "string") {
    return value.replace(SECRET_PATTERN, "Bearer [redacted]");
  }
  if (Array.isArray(value)) {
    return value.map(redactValue);
  }
  if (value && typeof value === "object") {
    const out: Record<string, unknown> = {};
    for (const [key, nested] of Object.entries(value)) {
      out[key] = SECRET_KEY.test(key) ? "[redacted]" : redactValue(nested);
    }
    return out;
  }
  return value;
}

function write(level: string, msg: string, fields?: LogFields): void {
  const line = JSON.stringify(
    redactValue({
      ts: new Date().toISOString(),
      level,
      msg,
      ...(fields ?? {}),
    }),
  );
  const sink = level === "error" ? process.stderr : process.stdout;
  sink.write(`${line}\n`);
}

export function logInfo(msg: string, fields?: LogFields): void {
  write("info", msg, fields);
}

export function logWarn(msg: string, fields?: LogFields): void {
  write("warn", msg, fields);
}

export function logError(msg: string, fields?: LogFields): void {
  write("error", msg, fields);
}

export function redactText(text: string): string {
  return text.replace(SECRET_PATTERN, "Bearer [redacted]");
}
