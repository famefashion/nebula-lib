# Installation

`src/` contains the maintainable ModuleScript source tree. `dist/Nebula.lua` is
the generated, self-contained Luau loadstring package.

## ModuleScript

Sync or copy the `src/` tree into ReplicatedStorage and require the `Nebula`
ModuleScript entry:

```lua
local Nebula = require(game:GetService("ReplicatedStorage").Packages.Nebula)
local app = Nebula.new({ Theme = "Nebula Dark" })
```

## Loadstring package

Use the generated `dist/Nebula.lua` from a trusted compatible runtime that
provides `game:HttpGet` and `loadstring`:

```lua
local Nebula = loadstring(game:HttpGet("https://raw.githubusercontent.com/famefashion/nebula-lib/main/dist/Nebula.lua"))()
local app = Nebula.new({ Theme = "Nebula Dark" })
```

After changing the modular source, regenerate the standalone package:

```sh
npm run build
npm run check:bundle
```

Remote code changes when the branch changes. Review the source and pin a release
tag or commit SHA when a stable version is required.
