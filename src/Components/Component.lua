--!strict

local Maid = require(script.Parent.Parent.Core.Maid)

local Component = {}
Component.__index = Component

function Component.new(instance: GuiObject, theme, animations)
    return setmetatable({
        Instance = instance,
        Theme = theme,
        Animations = animations,
        Maid = Maid.new(),
        _destroyed = false,
    }, Component)
end

function Component:IsAlive(): boolean
    return not self._destroyed and self.Instance.Parent ~= nil
end

function Component:Destroy()
    if self._destroyed then
        return
    end
    self._destroyed = true
    self.Maid:Destroy()
    if self.Instance.Parent then
        self.Instance:Destroy()
    end
end

return Component
