import type { AuthDevice } from "./auth.js";
import { forbidden } from "./errors.js";

export type RouteAuth = "none" | "parent";

export type RouteSpec = {
  method: string;
  auth: RouteAuth;
  mutating: boolean;
};

/**
 * Single authorization policy: a child token never mutates an authenticated
 * route. Parent-only routes (including GET /v1/devices) also reject children.
 */
export function authorize(route: RouteSpec, device: AuthDevice | null): void {
  if (route.auth === "none") {
    return;
  }
  if (!device) {
    throw forbidden();
  }
  if (device.role === "child") {
    if (route.mutating || route.auth === "parent") {
      throw forbidden();
    }
  }
}
