import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import { execFileSync } from "node:child_process";
import { fileURLToPath } from "node:url";
import { buildBundle } from "./build-bundle.mjs";

const projectRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const bundlePath = path.join(projectRoot, "dist", "Nebula.lua");
const sourceRoot = path.join(projectRoot, "src");

execFileSync(process.execPath, ["tools/build-bundle.mjs"], {
  cwd: projectRoot,
  stdio: "inherit",
});

assert.ok(fs.existsSync(bundlePath), "dist/Nebula.lua was not generated");
const firstBuild = fs.readFileSync(bundlePath, "utf8");
const secondBuild = buildBundle({ write: false });
assert.equal(secondBuild.output, firstBuild, "bundle output is not deterministic");

assert.match(firstBuild, /local __modules = \{\}/);
assert.match(firstBuild, /local __cache = \{\}/);
assert.match(firstBuild, /return __require\("NebulaCore"\)/);
assert.match(firstBuild, /function Nebula\.new/);
assert.match(firstBuild, /Nebula\.VERSION = "0\.1\.0"/);
assert.doesNotMatch(firstBuild, /require\s*\(\s*script(?:\.|\s|\))/);
assert.doesNotMatch(firstBuild, /\bscript\./);

const factoryIds = [...firstBuild.matchAll(
  /__modules\["([^"]+)"\]\s*=\s*function\(require\)/g,
)].map((match) => match[1]);
assert.equal(
  new Set(factoryIds).size,
  factoryIds.length,
  "a module was bundled more than once",
);
assert.equal(factoryIds.length, secondBuild.moduleIds.length);
assert.ok(factoryIds.includes("NebulaCore"), "entry module is missing");

const sourceModules = [];
function collectLuaFiles(directory) {
  for (const entry of fs.readdirSync(directory, { withFileTypes: true })) {
    const absolutePath = path.join(directory, entry.name);
    if (entry.isDirectory()) {
      collectLuaFiles(absolutePath);
    } else if (entry.isFile() && entry.name.endsWith(".lua")) {
      sourceModules.push(absolutePath);
    }
  }
}
collectLuaFiles(sourceRoot);

for (const file of sourceModules) {
  if (path.basename(file) === "Nebula.lua") continue;
  const relative = path.relative(sourceRoot, file).replaceAll(path.sep, "/");
  const moduleId = relative.replace(/\.lua$/, "").replaceAll("/", ".");
  if (firstBuild.includes(`require(${JSON.stringify(moduleId)})`)) {
    assert.ok(
      factoryIds.includes(moduleId),
      `${moduleId} is required but missing from the bundle`,
    );
  }
}

for (const method of [
  "CreateWindow",
  "RegisterTheme",
  "SetTheme",
  "GetTheme",
  "ModifyTheme",
  "ResetTheme",
  "SetRenderMode",
  "SetReducedMotion",
  "SetDebug",
  "GetDiagnostics",
  "Toast",
  "Destroy",
]) {
  assert.match(firstBuild, new RegExp(`function Nebula:${method}\\b`));
}

console.info(
  `Bundle checks passed: ${factoryIds.length} reachable modules, deterministic output, and no ModuleScript-only dependencies.`,
);