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

function Nebula.new(options: {[string]: any}?)
    options = options or {}
    local playerGui = options.Parent or Players.LocalPlayer:WaitForChild("PlayerGui")
    local self = setmetatable({
        Maid = Maid.new(),
        Debug = options.Debug == true,
        _componentCount = 0,
        _destroyed = false,
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
    self._applyResponsive()
    return self
end

function Nebula:CreateWindow(options: {[string]: any}?)
    assert(not self._destroyed, "Cannot create a window after Nebula:Destroy()")
    local window = Window.new(self._root, options or {}, self:GetTheme(), self.Animations, self.Maid)
    self._componentCount += 1
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

function Nebula:SetRenderMode(mode: string, options: {[string]: any}?)
    assert(not self._destroyed, "Cannot change render mode after Nebula:Destroy()")
    if mode == self.Root.Mode and not options then
        return
    end
    local commands = self.Commands and self.Commands._commands
    if self.Toasts then
        self.Toasts:Destroy()
    end
    if self.Commands then
        self.Commands:Destroy()
    end
    self.Root:SetMode(mode, options)
    self._root = self.Root.Instance
    assert(self._root, "Nebula render root was not created")
    self.Toasts = ToastStack.new(self._root, self:GetTheme(), self.Animations, self.Maid)
    self.Commands = Command.new(self._root, commands, self:GetTheme(), self.Animations, self.Maid)
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
    if self.Toasts then
        self.Toasts.Theme = theme
    end
end

function Nebula:_applyResponsive()
    if not self or not self._root or not self._root.Parent then return end
    local compact = self._breakpoint == "Compact"
    for _, child in ipairs(self._root:GetChildren()) do
        if child.Name == "NebulaWindow" then
            child.Size = compact and UDim2.new(1, -24, 1, -48) or UDim2.fromOffset(820, 520)
            local navigation = child:FindFirstChild("Navigation")
            local content = child:FindFirstChild("Content")
            if navigation and navigation:IsA("GuiObject") then
                navigation.Visible = not compact
            end
            if content and content:IsA("GuiObject") then
                content.Position = compact and UDim2.fromOffset(16, 78) or UDim2.fromOffset(204, 78)
                content.Size = compact and UDim2.new(1, -32, 1, -98) or UDim2.new(1, -224, 1, -98)
            end
        end
    end
end

function Nebula:Destroy()
    if self._destroyed then
        return
    end
    self._destroyed = true
    self.Maid:Destroy()
end

return Nebula
