--!strict

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Root = {}
Root.__index = Root

local modes = { ["2D"] = true, ["3D"] = true, Hybrid = true }

local function isGuiContainer(instance: Instance?): boolean
    return instance ~= nil and (instance:IsA("ScreenGui") or instance:IsA("SurfaceGui"))
end

function Root.new(mode: string?, options: {[string]: any}, _maid)
    local self = setmetatable({
        Mode = mode or "2D",
        Options = options or {},
        Instance = nil,
        _destroyed = false,
        _visible = true,
        _closing = false,
        _elapsed = 0,
        _closeElapsed = 0,
        _displayInstances = {},
        _followConnection = nil,
        _toggleGui = nil,
        _toggleButton = nil,
        _ownedAdornee = nil,
        _glow = nil,
        _baseTransparency = 0,
    }, Root)
    self:_create()
    return self
end

function Root:_clearDisplay()
    if self._followConnection then
        self._followConnection:Disconnect()
        self._followConnection = nil
    end
    if self._toggleGui then
        self._toggleGui:Destroy()
        self._toggleGui = nil
        self._toggleButton = nil
    end
    if self._glow then
        self._glow:Destroy()
        self._glow = nil
    end
    if self._ownedAdornee then
        if self.Options.Adornee == self._ownedAdornee then
            self.Options.Adornee = nil
        end
        self._ownedAdornee:Destroy()
        self._ownedAdornee = nil
    end
    if self.Instance and self.Instance.Parent then
        self.Instance:Destroy()
    end
    self.Instance = nil
    table.clear(self._displayInstances)
end

function Root:_createPhysicalDisplay(): BasePart
    local options = self.Options
    local part = Instance.new("Part")
    part.Name = "NebulaPhysicalDisplay"
    part.Anchored = true
    part.CanCollide = false
    part.CanTouch = false
    part.CanQuery = false
    part.CastShadow = false
    part.Massless = true
    part.Material = options.PhysicalMaterial or Enum.Material.Neon
    part.Color = options.GlowColor or self.Options.Theme.Accent
    part.Size = options.PhysicalSize or Vector3.new(8, 5, 0.35)
    part.Transparency = options.PhysicalTransparency or 0.72
    part.Parent = workspace
    self._ownedAdornee = part
    self._baseTransparency = part.Transparency
    return part
end

function Root:_setupGlow(adornee: BasePart)
    if self.Options.Glow == false then
        return
    end
    local glow = Instance.new("PointLight")
    glow.Name = "NebulaPhysicalGlow"
    glow.Color = self.Options.GlowColor or self.Options.Theme.Accent
    glow.Brightness = self.Options.GlowBrightness or 1.25
    glow.Range = self.Options.GlowRange or 14
    glow.Shadows = false
    glow.Parent = adornee
    self._glow = glow
end

function Root:_createToggle(playerGui: Instance)
    local theme = self.Options.Theme
    local toggleGui = Instance.new("ScreenGui")
    toggleGui.Name = "NebulaToggle"
    toggleGui.ResetOnSpawn = false
    toggleGui.IgnoreGuiInset = true
    toggleGui.DisplayOrder = (self.Options.DisplayOrder or 20) + 2
    toggleGui.Parent = playerGui

    local button = Instance.new("TextButton")
    button.Name = "NebulaToggleButton"
    button.AnchorPoint = Vector2.new(1, 0)
    button.Position = self.Options.TogglePosition or UDim2.new(1, -18, 0, 18)
    button.Size = self.Options.ToggleSize or UDim2.fromOffset(42, 34)
    button.AutoButtonColor = false
    button.BackgroundColor3 = theme.SurfaceSecondary
    button.BackgroundTransparency = 0.08
    button.BorderSizePixel = 0
    button.Font = Enum.Font.GothamBold
    button.Text = "◉"
    button.TextColor3 = theme.Text
    button.TextSize = 16
    button.ZIndex = 20
    button.Parent = toggleGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 9)
    corner.Parent = button
    local stroke = Instance.new("UIStroke")
    stroke.Color = theme.Accent
    stroke.Transparency = 0.12
    stroke.Parent = button

    self._toggleGui = toggleGui
    self._toggleButton = button
    button.Activated:Connect(function()
        self:Toggle()
    end)
end

function Root:_setDisplayEnabled(enabled: boolean)
    for _, display in ipairs(self._displayInstances) do
        if isGuiContainer(display) then
            display.Enabled = enabled
        end
    end
    if self._toggleButton then
        self._toggleButton.Text = enabled and "◉" or "○"
    end
end

function Root:_playerRoot(): BasePart?
    local player = Players.LocalPlayer
    local character = player and player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if root and root:IsA("BasePart") then
        return root
    end
    return nil
end

function Root:_lookAt(position: Vector3, fallback: Vector3): CFrame
    local camera = workspace.CurrentCamera
    local target = camera and camera.CFrame.Position or fallback
    if (target - position).Magnitude < 0.01 then
        target = position + Vector3.new(0, 0, -1)
    end
    return CFrame.lookAt(position, target)
end

function Root:_followPosition(time: number): (Vector3, Vector3)
    local playerRoot = self:_playerRoot()
    local camera = workspace.CurrentCamera
    local fallback = camera and (camera.CFrame.Position + camera.CFrame.LookVector * 8) or Vector3.zero
    if not playerRoot then
        return fallback, fallback
    end

    local options = self.Options
    local radius = options.OrbitRadius or 2.5
    local speed = options.OrbitSpeed or 0.28
    local hover = math.sin(time * (options.HoverSpeed or 1.1)) * (options.HoverAmplitude or 0.28)
    local angle = time * speed
    local offset = options.FollowOffset or Vector3.new(0, 3.2, -8)
    local orbit = Vector3.new(math.cos(angle) * radius, hover, math.sin(angle) * radius)
    local position = playerRoot.CFrame:PointToWorldSpace(offset + orbit)
    return position, playerRoot.Position + Vector3.new(0, 2.5, 0)
end

function Root:_setPhysicalState(transparency: number, brightness: number?)
    local adornee = self.Options.Adornee
    if self._ownedAdornee and self._ownedAdornee.Parent then
        self._ownedAdornee.Transparency = transparency
    end
    if brightness and self._glow then
        self._glow.Brightness = brightness
    end
end

function Root:_step(deltaTime: number)
    self._elapsed += deltaTime
    local adornee = self.Options.Adornee
    if not adornee or not adornee.Parent then
        return
    end

    if self._closing then
        self._closeElapsed += deltaTime
        local orbitDuration = self.Options.CloseOrbitDuration or 0.78
        local riseDuration = self.Options.CloseRiseDuration or 0.52
        local totalDuration = orbitDuration + riseDuration
        local position: Vector3
        local target: Vector3

        if self._closeElapsed <= orbitDuration then
            position, target = self:_followPosition(self._elapsed + self._closeElapsed * 2.1)
        else
            local progress = math.clamp((self._closeElapsed - orbitDuration) / riseDuration, 0, 1)
            local orbitPosition, orbitTarget = self:_followPosition(self._elapsed + orbitDuration * 2.1)
            local rise = progress * progress * (3 - 2 * progress)
            position = orbitPosition:Lerp(orbitPosition + Vector3.new(0, self.Options.CloseRiseHeight or 90, 0), rise)
            target = orbitTarget
            self:_setPhysicalState(self._baseTransparency + (1 - self._baseTransparency) * rise, (self.Options.GlowBrightness or 1.25) * (1 - rise))
        end

        if adornee:IsA("BasePart") then
            adornee.CFrame = self:_lookAt(position, target)
        end
        if self._closeElapsed >= totalDuration then
            self._closing = false
            self._visible = false
            self:_setDisplayEnabled(false)
            self:_setPhysicalState(1, 0)
        end
        return
    end

    if self._followPlayer and adornee:IsA("BasePart") then
        local position, target = self:_followPosition(self._elapsed)
        adornee.CFrame = self:_lookAt(position, target)
    end
end

function Root:_create()
    self:_clearDisplay()
    local playerGui = self.Options.Parent
    assert(playerGui and playerGui.Parent, "Nebula requires a live PlayerGui parent")
    assert(modes[self.Mode], ("Unsupported Nebula render mode: %s"):format(tostring(self.Mode)))

    local container: Instance
    if self.Mode == "2D" then
        container = Instance.new("ScreenGui")
        container.ResetOnSpawn = false
        container.IgnoreGuiInset = true
        container.DisplayOrder = self.Options.DisplayOrder or 20
        container.Parent = playerGui
    else
        local adornee = self.Options.Adornee
        if not adornee or not adornee:IsA("BasePart") then
            adornee = self:_createPhysicalDisplay()
            self.Options.Adornee = adornee
        end
        self._baseTransparency = adornee.Transparency
        self:_setupGlow(adornee)
        container = Instance.new("SurfaceGui")
        container.Adornee = adornee
        container.Face = self.Options.Face or Enum.NormalId.Front
        container.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
        container.PixelsPerStud = self.Options.PixelsPerStud or 50
        container.AlwaysOnTop = self.Options.AlwaysOnTop ~= false
        container.Parent = adornee
        self._followPlayer = self.Options.FollowPlayer ~= false
        self._followConnection = RunService.Heartbeat:Connect(function(deltaTime)
            self:_step(deltaTime)
        end)
        if self.Mode == "Hybrid" then
            local overlay = Instance.new("ScreenGui")
            overlay.Name = "NebulaOverlay"
            overlay.ResetOnSpawn = false
            overlay.IgnoreGuiInset = true
            overlay.DisplayOrder = self.Options.DisplayOrder or 20
            overlay.Parent = playerGui
            table.insert(self._displayInstances, overlay)
        end
    end
    self.Instance = container
    table.insert(self._displayInstances, container)
    self:_createToggle(playerGui)
    self:_setDisplayEnabled(self._visible)
end

function Root:SetMode(mode: string, options: {[string]: any}?)
    assert(not self._destroyed, "Cannot change a destroyed Nebula root")
    assert(modes[mode], ("Unsupported Nebula render mode: %s"):format(tostring(mode)))
    self.Mode = mode
    if options then
        for key, value in pairs(options) do
            self.Options[key] = value
        end
    end
    self._closing = false
    self._visible = true
    self:_create()
end

function Root:SetTheme(theme)
    self.Options.Theme = theme
    if self._toggleButton then
        self._toggleButton.BackgroundColor3 = theme.SurfaceSecondary
        self._toggleButton.TextColor3 = theme.Text
        local stroke = self._toggleButton:FindFirstChildOfClass("UIStroke")
        if stroke then
            stroke.Color = theme.Accent
        end
    end
    if self._glow then
        self._glow.Color = self.Options.GlowColor or theme.Accent
    end
    if self._ownedAdornee then
        self._ownedAdornee.Color = self.Options.GlowColor or theme.Accent
    end
end

function Root:SetVisible(enabled: boolean)
    if self._destroyed then
        return
    end
    self._closing = false
    self._visible = enabled == true
    self:_setDisplayEnabled(self._visible)
    if self._visible then
        self:_setPhysicalState(self._baseTransparency, self.Options.GlowBrightness or 1.25)
    end
end

function Root:Open()
    self:SetVisible(true)
end

function Root:CloseAnimated()
    if self._destroyed or not self._visible then
        return
    end
    if self.Mode == "2D" or not self._followPlayer or not self.Options.Adornee then
        self:SetVisible(false)
        return
    end
    self._closing = true
    self._closeElapsed = 0
end

function Root:Toggle()
    if self._visible or self._closing then
        self:CloseAnimated()
    else
        self:Open()
    end
end

function Root:IsVisible(): boolean
    return self._visible and not self._closing
end

function Root:Destroy()
    if self._destroyed then
        return
    end
    self._destroyed = true
    self:_clearDisplay()
end

return Root