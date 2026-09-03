import assert from "node:assert/strict";
import { execFile as execFileCb } from "node:child_process";
import { promisify } from "node:util";
import { test } from "node:test";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const execFile = promisify(execFileCb);
const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const image = "forests-wallet-app";

async function docker(
  args: string[],
): Promise<{ code: number; stdout: string; stderr: string }> {
  try {
    const { stdout, stderr } = await execFile("docker", args, {
      encoding: "utf8",
      cwd: root,
    });
    return { code: 0, stdout, stderr };
  } catch (err) {
    const failure = err as {
      code?: number;
      stdout?: string;
      stderr?: string;
    };
    return {
      code: failure.code ?? 1,
      stdout: failure.stdout ?? "",
      stderr: failure.stderr ?? "",
    };
  }
}

test("production image exposes fw migrate, open-bootstrap, and revoke-parent-devices", async () => {
  const build = await docker(["build", "-t", image, "."]);
  assert.equal(build.code, 0, build.stderr);

  const pathCheck = await docker([
    "run",
    "--rm",
    "--entrypoint",
    "/bin/sh",
    image,
    "-c",
    "command -v fw && fw",
  ]);
  assert.equal(pathCheck.code, 2, pathCheck.stderr + pathCheck.stdout);
  assert.match(pathCheck.stdout + pathCheck.stderr, /\/usr\/local\/bin\/fw/);
  assert.match(
    pathCheck.stdout + pathCheck.stderr,
    /usage: fw <migrate\|open-bootstrap\|revoke-parent-devices>/,
  );

  for (const command of ["migrate", "open-bootstrap", "revoke-parent-devices"]) {
    const result = await docker([
      "run",
      "--rm",
      "--entrypoint",
      "fw",
      image,
      command,
    ]);
    assert.notEqual(result.code, 127, `${command} not found: ${result.stderr}`);
    assert.match(
      result.stderr,
      /DATABASE_URL is required/,
      `${command}: ${result.stderr}`,
    );
  }
});
