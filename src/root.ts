import { existsSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

export function findProjectRoot(
  startDir = dirname(fileURLToPath(import.meta.url)),
): string {
  let dir = startDir;
  for (;;) {
    if (
      existsSync(join(dir, "package.json")) &&
      existsSync(join(dir, "sql", "migrations"))
    ) {
      return dir;
    }
    const parent = dirname(dir);
    if (parent === dir) {
      throw new Error("could not find project root");
    }
    dir = parent;
  }
}
