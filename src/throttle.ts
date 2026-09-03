export type ThrottleLimit = {
  max: number;
  windowMs: number;
};

type Hit = number;

export class SlidingWindowThrottle {
  private readonly buckets = new Map<string, Hit[]>();

  reset(): void {
    this.buckets.clear();
  }

  hit(key: string, limit: ThrottleLimit, now = Date.now()): boolean {
    const cutoff = now - limit.windowMs;
    const next = (this.buckets.get(key) ?? []).filter((ts) => ts > cutoff);
    if (next.length >= limit.max) {
      this.buckets.set(key, next);
      return false;
    }
    next.push(now);
    this.buckets.set(key, next);
    return true;
  }
}

export const claimThrottle = new SlidingWindowThrottle();
export const bootstrapThrottle = new SlidingWindowThrottle();

export function resetThrottlesForTests(): void {
  claimThrottle.reset();
  bootstrapThrottle.reset();
}
