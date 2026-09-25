--!strict

local Signal = require(script.Parent.Parent.Core.Signal)
local presets = require(script.Parent.Presets)

local Manager = {}
Manager.__index = Manager

function Manager.new(initial: string?)
    local themes = table.clone(presets)
    local name = initial or "Nebula Dark"
    assert(themes[name], ("Unknown Nebula theme: %s"):format(name))
    return setmetatable({
        _themes = themes,
        _name = name,
        _changed = Signal.new(),
    }, Manager)
end

function Manager:Register(name: string, theme: {[string]: any})
    assert(type(name) == "string" and #name > 0, "Theme name must be a non-empty string")
    assert(type(theme) == "table", "Theme must be a table")
    local merged = table.clone(self._themes["Nebula Dark"])
    for key, value in pairs(theme) do
        assert(merged[key] ~= nil, ("Unknown Nebula theme property: %s"):format(key))
        merged[key] = value
    end
    self._themes[name] = merged
end

function Manager:Set(name: string)
    assert(self._themes[name], ("Unknown Nebula theme: %s"):format(name))
    self._name = name
    self._changed:Fire(self:Get(), name)
end

function Manager:Get(): {[string]: any}
    return self._themes[self._name]
end

function Manager:GetName(): string
    return self._name
end

function Manager:Modify(changes: {[string]: any})
    local current = table.clone(self:Get())
    for key, value in pairs(changes) do
        assert(current[key] ~= nil, ("Unknown Nebula theme property: %s"):format(key))
        current[key] = value
    end
    self._themes[self._name] = current
    self._changed:Fire(current, self._name)
end

function Manager:Reset()
    self:Set("Nebula Dark")
end

function Manager:OnChanged(callback: ({[string]: any}, string) -> ()): RBXScriptConnection
    return self._changed:Connect(callback)
end

function Manager:Destroy()
    self._changed:Destroy()
    table.clear(self._themes)
end

return Manager
