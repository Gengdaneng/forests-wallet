import assert from "node:assert/strict";
import { test } from "node:test";
import { SlidingWindowThrottle } from "../src/throttle.js";

const ipLimit = { max: 5, windowMs: 10_000 };
const globalLimit = { max: 3, windowMs: 10_000 };

test("expired keys are pruned and cannot grow the map indefinitely", () => {
  const throttle = new SlidingWindowThrottle({ maxKeys: 1_000 });
  const limit = { max: 2, windowMs: 1_000 };
  for (let i = 0; i < 200; i += 1) {
    assert.equal(throttle.hit(`old-${i}`, limit, 0), true);
  }
  assert.equal(throttle.size, 200);
  assert.equal(throttle.hit("fresh", limit, 5_000), true);
  assert.equal(throttle.size, 1);
});

test("globally rejected unique IPs do not create unbounded keys", () => {
  const throttle = new SlidingWindowThrottle({ maxKeys: 1_000 });
  const now = 1_000;
  for (let i = 0; i < globalLimit.max; i += 1) {
    assert.equal(
      throttle.allowIpAndGlobal(`ip:${i}`, "global", ipLimit, globalLimit, now),
      true,
    );
  }
  const filled = throttle.size;
  assert.equal(filled, globalLimit.max + 1);
  for (let i = 100; i < 400; i += 1) {
    assert.equal(
      throttle.allowIpAndGlobal(`ip:${i}`, "global", ipLimit, globalLimit, now),
      false,
    );
  }
  assert.equal(throttle.size, filled);
});

test("hard bound evicts oldest keys instead of growing without limit", () => {
  const throttle = new SlidingWindowThrottle({ maxKeys: 8 });
  const limit = { max: 1, windowMs: 60_000 };
  for (let i = 0; i < 40; i += 1) {
    throttle.hit(`k-${i}`, limit, 1_000 + i);
  }
  assert.ok(throttle.size <= 8);
  assert.equal(throttle.hit("k-39", limit, 2_000), false);
});
