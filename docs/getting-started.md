# Getting started

## Requirements

- Roblox Studio with Luau support.
- A LocalScript using the `src/` ModuleScript entry, or a trusted compatible runtime that provides `game:HttpGet` and `loadstring`.

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

For loadstring use, fetch `dist/Nebula.lua` instead. It is the complete runtime
package and does not call `require(script...)` or download additional modules.
