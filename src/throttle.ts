export type ThrottleLimit = {
  max: number;
  windowMs: number;
};

type Bucket = {
  hits: number[];
  windowMs: number;
};

export type SlidingWindowOptions = {
  maxKeys?: number;
};

export const DEFAULT_THROTTLE_MAX_KEYS = 4096;

export class SlidingWindowThrottle {
  private readonly buckets = new Map<string, Bucket>();
  private readonly maxKeys: number;

  constructor(opts: SlidingWindowOptions = {}) {
    this.maxKeys = opts.maxKeys ?? DEFAULT_THROTTLE_MAX_KEYS;
  }

  get size(): number {
    return this.buckets.size;
  }

  reset(): void {
    this.buckets.clear();
  }

  prune(now = Date.now()): void {
    for (const [key, bucket] of this.buckets) {
      pruneHits(bucket, now);
      if (bucket.hits.length === 0) {
        this.buckets.delete(key);
      }
    }
  }

  hit(key: string, limit: ThrottleLimit, now = Date.now()): boolean {
    this.prune(now);
    const bucket = this.bucketFor(key, limit);
    pruneHits(bucket, now);
    if (bucket.hits.length >= limit.max) {
      this.storeNonEmpty(key, bucket);
      return false;
    }
    this.evictOldest(now, new Set([key]), this.buckets.has(key) ? 0 : 1);
    bucket.hits.push(now);
    this.buckets.set(key, bucket);
    return true;
  }

  /**
   * Check the global quota before inserting a per-IP key so a unique-IP flood
   * that is already globally rejected cannot grow the map without bound.
   */
  allowIpAndGlobal(
    ipKey: string,
    globalKey: string,
    ipLimit: ThrottleLimit,
    globalLimit: ThrottleLimit,
    now = Date.now(),
  ): boolean {
    this.prune(now);

    const global = this.bucketFor(globalKey, globalLimit);
    pruneHits(global, now);
    if (global.hits.length >= globalLimit.max) {
      this.storeNonEmpty(globalKey, global);
      return false;
    }

    const ip = this.bucketFor(ipKey, ipLimit);
    pruneHits(ip, now);
    if (ip.hits.length >= ipLimit.max) {
      this.storeNonEmpty(ipKey, ip);
      return false;
    }

    const room =
      (this.buckets.has(globalKey) ? 0 : 1) + (this.buckets.has(ipKey) ? 0 : 1);
    this.evictOldest(now, new Set([ipKey, globalKey]), room);
    global.hits.push(now);
    ip.hits.push(now);
    this.buckets.set(globalKey, global);
    this.buckets.set(ipKey, ip);
    return true;
  }

  private bucketFor(key: string, limit: ThrottleLimit): Bucket {
    const existing = this.buckets.get(key);
    if (existing) {
      existing.windowMs = limit.windowMs;
      return existing;
    }
    return { hits: [], windowMs: limit.windowMs };
  }

  private storeNonEmpty(key: string, bucket: Bucket): void {
    if (bucket.hits.length === 0) {
      this.buckets.delete(key);
      return;
    }
    this.buckets.set(key, bucket);
  }

  private evictOldest(now: number, keep: Set<string>, room: number): void {
    this.prune(now);
    while (this.buckets.size + room > this.maxKeys) {
      let oldestKey: string | undefined;
      let oldestTs = Number.POSITIVE_INFINITY;
      for (const [key, bucket] of this.buckets) {
        if (keep.has(key)) {
          continue;
        }
        const last = bucket.hits[bucket.hits.length - 1] ?? 0;
        if (last < oldestTs) {
          oldestTs = last;
          oldestKey = key;
        }
      }
      if (!oldestKey) {
        break;
      }
      this.buckets.delete(oldestKey);
    }
  }
}

function pruneHits(bucket: Bucket, now: number): void {
  const cutoff = now - bucket.windowMs;
  bucket.hits = bucket.hits.filter((ts) => ts > cutoff);
}

export const claimThrottle = new SlidingWindowThrottle();
export const bootstrapThrottle = new SlidingWindowThrottle();

export function resetThrottlesForTests(): void {
  claimThrottle.reset();
  bootstrapThrottle.reset();
}
