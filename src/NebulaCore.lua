--!strict

local Players = game:GetService("Players")

local Maid = require(script.Core.Maid)
local Manager = require(script.Theme.Manager)
local Animator = require(script.Animation.Animator)
local Root = require(script.Rendering.Root)
local Window = require(script.Components.Window)
local Command = require(script.Components.Command)
local ToastStack = require(script.Components.ToastStack)
local Responsive = require(script.Utilities.Responsive)

local Nebula = {}
Nebula.__index = Nebula
Nebula.VERSION = "0.1.0"

function Nebula.new(options: {[string]: any}?)
    options = options or {}
    local playerGui = options.Parent or Players.LocalPlayer:WaitForChild("PlayerGui")
    local self = setmetatable({
        Maid = Maid.new(),
        Debug = options.Debug == true,
        _componentCount = 0,
        _destroyed = false,
        _windows = {},
    }, Nebula)
    self.ThemeManager = Manager.new(options.Theme)
    self.Animations = Animator.new(options.ReducedMotion)
    self.Maid:Give(self.ThemeManager)
    self.Maid:Give(self.Animations)
    self.Root = Root.new(options.RenderMode or "2D", {
        Parent = playerGui,
        Adornee = options.Adornee,
        Face = options.Face,
        PixelsPerStud = options.PixelsPerStud,
        DisplayOrder = options.DisplayOrder,
    }, self.Maid)
    self._root = self.Root.Instance
    self.Toasts = ToastStack.new(self._root, self:GetTheme(), self.Animations, self.Maid)
    self.Commands = Command.new(self._root, options.Commands, self:GetTheme(), self.Animations, self.Maid)
    self.Maid:Give(self.ThemeManager:OnChanged(function(theme)
        self:_applyTheme(theme)
    end))
    self.Maid:Give(workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        self._breakpoint = Responsive.GetBreakpoint(workspace.CurrentCamera.ViewportSize.X)
        self:_applyResponsive()
    end))
    self._breakpoint = Responsive.GetBreakpoint(workspace.CurrentCamera.ViewportSize.X)
    self:_applyResponsive()
    return self
end

function Nebula:CreateWindow(options: {[string]: any}?)
    assert(not self._destroyed, "Cannot create a window after Nebula:Destroy()")
    local window = Window.new(self._root, options or {}, self:GetTheme(), self.Animations, self.Maid)
    table.insert(self._windows, window)
    window:AddSettingsTab(self)
    self._componentCount += 1
    self:_applyResponsive()
    return window
end

function Nebula:RegisterTheme(name: string, theme: {[string]: any})
    self.ThemeManager:Register(name, theme)
end

function Nebula:SetTheme(name: string)
    self.ThemeManager:Set(name)
end

function Nebula:GetTheme(): {[string]: any}
    return self.ThemeManager:Get()
end

function Nebula:ModifyTheme(changes: {[string]: any})
    self.ThemeManager:Modify(changes)
end

function Nebula:ResetTheme()
    self.ThemeManager:Reset()
end

function Nebula:CanUseRenderMode(mode: string, options: {[string]: any}?): boolean
    if mode == "2D" then
        return true
    end
    local adornee = (options and options.Adornee) or self.Root.Options.Adornee
    return typeof(adornee) == "Instance" and adornee:IsA("BasePart")
end

function Nebula:GetRenderModes(): {{Name: string, Available: boolean, Reason: string?}}
    local hasAdornee = self:CanUseRenderMode("3D")
    return {
        { Name = "2D", Available = true },
        { Name = "3D", Available = hasAdornee, Reason = hasAdornee and nil or "Requires a BasePart Adornee" },
        { Name = "Hybrid", Available = hasAdornee, Reason = hasAdornee and nil or "Requires a BasePart Adornee" },
    }
end

function Nebula:SetRenderMode(mode: string, options: {[string]: any}?)
    assert(not self._destroyed, "Cannot change render mode after Nebula:Destroy()")
    assert(self:CanUseRenderMode(mode, options), ("Nebula render mode %s requires a BasePart Adornee"):format(tostring(mode)))
    if mode == self.Root.Mode and not options then
        return
    end
    self.Root:SetMode(mode, options)
    self._root = self.Root.Instance
    assert(self._root, "Nebula render root was not created")
    self:_applyResponsive()
end

function Nebula:SetDebug(enabled: boolean)
    self.Debug = enabled
end

function Nebula:SetReducedMotion(enabled: boolean)
    self.Animations:SetReducedMotion(enabled)
end

function Nebula:Toast(message: string, kind: string?, duration: number?)
    return self.Toasts:Push(message, kind, duration)
end

function Nebula:GetDiagnostics()
    local camera = workspace.CurrentCamera
    return {
        ComponentCount = self._componentCount,
        RenderMode = self.Root.Mode,
        Viewport = camera and camera.ViewportSize or Vector2.zero,
        Breakpoint = self._breakpoint,
        ActiveAnimations = self.Animations:GetActiveCount(),
    }
end

function Nebula:_applyTheme(theme)
    self.Toasts.Theme = theme
    for _, window in ipairs(self._windows) do
        window.Theme = theme
    end
end

function Nebula:_applyResponsive()
    if not self or not self._root or not self._root.Parent then
        return
    end
    local camera = workspace.CurrentCamera
    if not camera then
        return
    end
    for _, window in ipairs(self._windows) do
        if window and window.Instance and window.Instance.Parent then
            window:ApplyResponsive(camera.ViewportSize, self._breakpoint)
        end
    end
end

function Nebula:Destroy()
    if self._destroyed then
        return
    end
    self._destroyed = true
    table.clear(self._windows)
    self.Maid:Destroy()
end

return Nebula
