import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const projectRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const bundlePath = path.join(projectRoot, "dist", "Nebula.lua");
const sourcePath = path.join(projectRoot, "src", "Nebula.lua");

if (!fs.existsSync(bundlePath)) {
  throw new Error("Missing dist/Nebula.lua. Run npm run build first.");
}

const bundle = fs.readFileSync(bundlePath, "utf8");
const source = fs.readFileSync(sourcePath, "utf8");
const modules = [...bundle.matchAll(/__factories\["([^"]+)"\] = function/g)].map((match) => match[1]);
const moduleSet = new Set(modules);
const imports = [...bundle.matchAll(/require\("([^"]+)"\)/g)].map((match) => match[1]);
const missing = [...new Set(imports.filter((name) => !moduleSet.has(name)))];

if (missing.length > 0) {
  throw new Error(`Bundle contains missing modules: ${missing.join(", ")}`);
}
if (!source.includes("require(script.NebulaCore)")) {
  throw new Error("src/Nebula.lua must remain the normal ModuleScript entry point");
}
if (/require\(\s*script(?:\.|\s|\))/i.test(bundle)) {
  throw new Error("Bundle contains an unresolved ModuleScript require");
}
if (!bundle.includes('return __require("Nebula")')) {
  throw new Error("Bundle does not return the public Nebula entry module");
}
if (!bundle.includes("Nebula.VERSION")) {
  throw new Error("Bundle does not include the public version identifier");
}
if (!bundle.includes("function Root:CloseAnimated")) {
  throw new Error("Bundle does not include the 3D close animation");
}
if (!bundle.includes("NebulaToggleButton")) {
  throw new Error("Bundle does not include the separate screen toggle");
}

console.info(`Bundle check passed: ${modules.length} modules, ${imports.length} imports.`);