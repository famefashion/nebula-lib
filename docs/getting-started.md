# Getting started

## Requirements

- Roblox Studio with Luau support.
- A trusted compatible runtime that provides `game:HttpGet` and `loadstring`.

## Create an app

```lua
local Nebula = loadstring(game:HttpGet("https://raw.githubusercontent.com/famefashion/nebula-lib/main/dist/Nebula.lua"))()
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

The fetched `dist/Nebula.lua` file is the complete runtime package. It does not
call `require(script...)` or download additional modules. For a full working
example, see [`examples/LoadstringExample.lua`](../examples/LoadstringExample.lua).
