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
Nebula.VERSION = "0.2.0"

function Nebula.new(options: {[string]: any}?)
    options = options or {}
    local playerGui = options.Parent or Players.LocalPlayer:WaitForChild("PlayerGui")
    local self = setmetatable({
        Maid = Maid.new(),
        Debug = options.Debug == true,
        _componentCount = 0,
        _destroyed = false,
        _windows = {},
        _renderModeTransitioning = false,
        _queuedRenderMode = nil,
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
    }, self.Maid, self.Animations)
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
    table.insert(self._windows, window)
    self:_addSettingsTab(window, options or {})
    self._componentCount += 1
    self:_applyResponsive()
    return window
end

function Nebula:_addSettingsTab(window, options)
    local settings = window:AddTab("UI Settings", "⚙")
    settings:AddText("Choose where Nebula renders. The selected mode stays active while the window is rebuilt in place.")
    local display = settings:AddSurface({ Title = "Display mode" })
    local modeDefinitions = {
        { Mode = "2D", Label = "▣  2D · Screen overlay" },
        { Mode = "3D", Label = "◇  3D · SurfaceGui on a part" },
        { Mode = "Hybrid", Label = "◈  Hybrid · Surface + screen overlay" },
    }
    local modeButtons = {}
    for _, definition in ipairs(modeDefinitions) do
        local mode = definition.Mode
        local button = display:AddButton({
            Label = definition.Label,
            OnClick = function()
                local adornee = self.Root.Options.Adornee
                if mode ~= "2D" and not (adornee and adornee:IsA("BasePart")) then
                    self:Toast("3D and Hybrid modes need options.Adornee = a BasePart", "warning")
                    return
                end
                self:SetRenderMode(mode)
            end,
        })
        button:SetSelected(self.Root.Mode == mode)
        modeButtons[mode] = button
    end
    window._displayModeButtons = modeButtons
    local behavior = settings:AddSurface({ Title = "Accessibility" })
    local reducedMotion = behavior:AddToggle({ Label = "Reduced motion", Default = options.ReducedMotion == true })
    reducedMotion:OnChanged(function(enabled) self:SetReducedMotion(enabled) end)
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
    assert(mode == "2D" or mode == "3D" or mode == "Hybrid", ("Unsupported Nebula render mode: %s"):format(tostring(mode)))
    if self._renderModeTransitioning then
        self._queuedRenderMode = { Mode = mode, Options = options }
        return
    end
    if mode == self.Root.Mode and not options then return end
    self._renderModeTransitioning = true
    local function applyMode()
        if self._destroyed then return end
        local commands = self.Commands and self.Commands._commands
        if self.Toasts then self.Toasts:Destroy() end
        if self.Commands then self.Commands:Destroy() end
        self.Root:SetMode(mode, options)
        self._root = self.Root.Instance
        assert(self._root, "Nebula render root was not created")
        self.Toasts = ToastStack.new(self._root, self:GetTheme(), self.Animations, self.Maid)
        self.Commands = Command.new(self._root, commands, self:GetTheme(), self.Animations, self.Maid)
        for _, window in ipairs(self._windows) do
            for buttonMode, button in pairs(window._displayModeButtons or {}) do button:SetSelected(buttonMode == mode) end
        end
        self:_applyResponsive()
        self._renderModeTransitioning = false
        local queued = self._queuedRenderMode
        self._queuedRenderMode = nil
        if queued then self:SetRenderMode(queued.Mode, queued.Options) end
    end
    if self.Root.Mode ~= "2D" then self.Root:AnimateExit(applyMode) else applyMode() end
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
    if not self or not self._root or not self._root.Parent then
        return
    end
    local camera = workspace.CurrentCamera
    if not camera then
        return
    end
    local viewport = camera.ViewportSize
    for _, window in ipairs(self._windows) do
        window:ApplyResponsive(viewport, self._breakpoint)
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
