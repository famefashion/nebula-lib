# Installation

`src/Nebula.lua` is a generated, self-contained Luau loadstring package. Fetching
that one file returns the Nebula API table; it does not need a ModuleScript,
`script`, or any sibling source files at runtime.

## Loadstring package

Use it from a trusted compatible runtime that provides `game:HttpGet` and
`loadstring`:

```lua
local Nebula = loadstring(game:HttpGet("https://raw.githubusercontent.com/famefashion/nebula-lib/main/src/Nebula.lua"))()
local app = Nebula.new({ Theme = "Nebula Dark" })
```

The module tree under `src/` is the editable source of truth only. After changing
those modules, regenerate the loadstring package from the repository root:

```sh
node tools/build-bundle.mjs
```

Remote code changes when the branch changes. Review the source and pin a release
tag or commit SHA when a stable version is required.
