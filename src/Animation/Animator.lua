--!strict

local TweenService = game:GetService("TweenService")
local Maid = require(script.Parent.Parent.Core.Maid)

local Animator = {}
Animator.__index = Animator

local presets = {
    surfaceIn = TweenInfo.new(0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
    control = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    spring = TweenInfo.new(0.48, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    quick = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    reveal = TweenInfo.new(0.36, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
    orbit = TweenInfo.new(0.72, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
}

function Animator.new(reducedMotion: boolean?)
    return setmetatable({
        _reducedMotion = reducedMotion == true,
        _maid = Maid.new(),
        _active = {},
        _destroyed = false,
    }, Animator)
end

function Animator:SetReducedMotion(enabled: boolean)
    self._reducedMotion = enabled
end

function Animator:Play(instance: Instance, properties: {[string]: any}, preset: string?, delayTime: number?)
    assert(not self._destroyed, "Cannot animate after Animator:Destroy()")
    assert(instance and instance.Parent, "Cannot animate a missing or destroyed Instance")
    local old = self._active[instance]
    if old then
        old:Cancel()
    end
    if self._reducedMotion then
        for key, value in pairs(properties) do
            (instance :: any)[key] = value
        end
        return nil
    end
    local info = presets[preset or "control"] or presets.control
    local delay = math.max(delayTime or 0, 0)
    if delay > 0 then
        info = TweenInfo.new(info.Time, info.EasingStyle, info.EasingDirection, info.RepeatCount, info.Reverses, delay)
    end
    local tween = TweenService:Create(instance, info, properties)
    self._active[instance] = tween
    self._maid:Give(tween.Completed:Connect(function()
        if self._active[instance] == tween then
            self._active[instance] = nil
        end
    end))
    tween:Play()
    return tween
end

function Animator:Fade(instance: Instance, transparency: number, preset: string?)
    return self:Play(instance, { BackgroundTransparency = transparency }, preset or "control")
end

function Animator:Scale(instance: GuiObject, scale: number, preset: string?)
    local value = instance:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
    value.Parent = instance
    return self:Play(value, { Scale = scale }, preset or "spring")
end

function Animator:Spring(instance: Instance, properties: {[string]: any})
    return self:Play(instance, properties, "spring")
end

function Animator:Slide(instance: GuiObject, position: UDim2, preset: string?)
    return self:Play(instance, { Position = position }, preset or "reveal")
end

function Animator:Rotate(instance: GuiObject, rotation: number, preset: string?)
    return self:Play(instance, { Rotation = rotation }, preset or "orbit")
end

function Animator:Stagger(instances: {Instance}, properties: {[string]: any}, preset: string?, interval: number?)
    local spacing = math.max(interval or 0.06, 0)
    local tweens = {}
    for index, instance in ipairs(instances) do
        local tween = self:Play(instance, properties, preset or "surfaceIn", (index - 1) * spacing)
        if tween then
            table.insert(tweens, tween)
        end
    end
    return tweens
end

function Animator:GetActiveCount(): number
    local count = 0
    for _ in pairs(self._active) do
        count += 1
    end
    return count
end

function Animator:Destroy()
    if self._destroyed then
        return
    end
    self._destroyed = true
    for _, tween in pairs(self._active) do
        tween:Cancel()
    end
    table.clear(self._active)
    self._maid:Destroy()
end

return Animator
