# Installation

`src/Nebula.lua` is a generated, self-contained Luau bundle. It can be installed as one ModuleScript or fetched by a compatible runtime that provides `game:HttpGet` and `loadstring`.

## ModuleScript (recommended for Roblox Studio)

Copy `src/Nebula.lua` into ReplicatedStorage as a ModuleScript named `Nebula`, then:

```lua
local Nebula = require(game:GetService("ReplicatedStorage").Packages.Nebula)
local app = Nebula.new({ Theme = "Nebula Dark" })
```

The module tree under `src/` remains the editable source of truth. After changing
those modules, regenerate the standalone entry point from the repository root:

```sh
node tools/build-bundle.mjs
```

## Loadstring (compatible custom runtimes only)

Use this only in a trusted runtime you control that explicitly implements both
`game:HttpGet` and `loadstring`. The ordinary Roblox client does not enable this
pattern for LocalScripts.

```lua
local Nebula = loadstring(game:HttpGet("https://raw.githubusercontent.com/famefashion/nebula-lib/main/src/Nebula.lua"))()
local app = Nebula.new({ Theme = "Nebula Dark" })
```

Remote code changes when the branch changes. Review the source and pin a release
tag or commit SHA when a stable version is required.
