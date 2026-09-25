# Getting started

## Requirements

- Roblox Studio with Luau support.
- A LocalScript running for the local player.
- The `src/` tree copied into ReplicatedStorage or synced with Rojo.

## Create an app

```lua
local Nebula = require(game:GetService("ReplicatedStorage").Packages.Nebula)
local app = Nebula.new({
    Parent = game:GetService("Players").LocalPlayer.PlayerGui,
    Title = "Control Room",
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
