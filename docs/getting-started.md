# Getting started

## Requirements

- Roblox Studio with Luau support.
- A LocalScript running for the local player.
- `src/Nebula.lua` copied into ReplicatedStorage as a ModuleScript named `Nebula`.

## Create an app

```lua
local Nebula = require(game:GetService("ReplicatedStorage").Packages.Nebula)
local app = Nebula.new({
    Parent = game:GetService("Players").LocalPlayer.PlayerGui,
})

local window = app:CreateWindow({ Title = "Control Room" })
local tab = window:AddTab("Overview")
local surface = tab:AddSurface({ Title = "Status" })

surface:AddButton({
    Label = "Ping",
    OnClick = function()
        app:Toast("Pong", "success")
    end,
})
```

`Nebula.new` owns every created root, connection, tween, and component. Call `app:Destroy()` when your feature is unloaded.

For the one-file URL loader, use the generated bundle in a compatible custom
runtime; see [installation](installation.md#loadstring-compatible-custom-runtimes-only).
