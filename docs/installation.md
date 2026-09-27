# Installation

`dist/Nebula.lua` is the generated, self-contained Luau loadstring package.
The modular files under `src/` are build sources and are not needed by the
runtime loader.

## Loadstring installation

Use `dist/Nebula.lua` from a trusted compatible runtime that provides
`game:HttpGet` and `loadstring`:

```lua
local Nebula = loadstring(game:HttpGet("https://raw.githubusercontent.com/famefashion/nebula-lib/main/dist/Nebula.lua"))()
local app = Nebula.new({ Theme = "Nebula Dark" })
```

See [`examples/LoadstringExample.lua`](../examples/LoadstringExample.lua) for a
complete UI example and [`examples/LoadstringSmokeTest.lua`](../examples/LoadstringSmokeTest.lua)
for runtime checks.

After changing the modular source, regenerate the standalone package:

```sh
npm run build
npm run check:bundle
```

Remote code changes when the branch changes. Review the source and pin a release
tag or commit SHA when a stable version is required.
