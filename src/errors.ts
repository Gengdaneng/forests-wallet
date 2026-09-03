export class HttpError extends Error {
  readonly status: number;
  readonly code: string;

  constructor(status: number, code: string) {
    super(code);
    this.status = status;
    this.code = code;
  }
}

export function invalid(): HttpError {
  return new HttpError(400, "invalid");
}

export function unauthorized(): HttpError {
  return new HttpError(401, "unauthorized");
}

export function forbidden(): HttpError {
  return new HttpError(403, "forbidden");
}

export function notFound(): HttpError {
  return new HttpError(404, "not_found");
}

export function conflict(): HttpError {
  return new HttpError(409, "conflict");
}

export function tooLarge(): HttpError {
  return new HttpError(413, "too_large");
}

export function unsupportedMediaType(): HttpError {
  return new HttpError(415, "unsupported_media_type");
}

export function tooManyRequests(): HttpError {
  return new HttpError(429, "too_many_requests");
}

export function unavailable(): HttpError {
  return new HttpError(503, "unavailable");
}
