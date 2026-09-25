# State and input

Value components expose `Get`, `Set`, and `Subscribe`.

```lua
local toggle = surface:AddToggle({ Label = "Enabled" })
toggle:Set(true)
print(toggle:Get())

local connection = toggle:OnChanged(function(value)
    print("changed", value)
end)
```

Destroy the owning component or app to disconnect subscriptions. Buttons use `Activated`, so mouse and touch activation share the same callback.
