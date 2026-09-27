--!strict

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Root = {}
Root.__index = Root

local modes = { ["2D"] = true, ["3D"] = true, Hybrid = true }

function Root.new(mode: string?, options: {[string]: any}, maid, animations)
    local self = setmetatable({
        Mode = mode or "2D",
        Options = options or {},
        Instance = nil,
        Overlay = nil,
        Animations = animations,
        _maid = maid,
        _followConnection = nil,
        _glowLight = nil,
    }, Root)
    self:_create()
    return self
end

function Root:_stopPresentationEffects()
    if self._followConnection then
        self._followConnection:Disconnect()
        self._followConnection = nil
    end
    if self._glowLight then
        if self._glowLight.Parent then self._glowLight:Destroy() end
        self._glowLight = nil
    end
end

function Root:_startPresentationEffects(adornee: BasePart, container: SurfaceGui)
    self:_stopPresentationEffects()

    if self.Options.Glow ~= false then
        local glow = Instance.new("PointLight")
        glow.Name = "NebulaGlowLight"
        glow.Color = self.Options.GlowColor or Color3.fromRGB(106, 170, 255)
        glow.Brightness = self.Options.GlowBrightness or 1.35
        glow.Range = self.Options.GlowRange or 16
        glow.Shadows = false
        glow.Parent = adornee
        self._glowLight = glow
        self._maid:Give(glow)
    end

    if self.Options.FollowLocalPlayer ~= true then
        return
    end

    local startedAt = os.clock()
    self._followConnection = RunService.RenderStepped:Connect(function()
        if not container.Parent or not adornee.Parent then
            return
        end
        local player = Players.LocalPlayer
        local character = player and player.Character
        local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart or not humanoidRootPart:IsA("BasePart") then
            return
        end

        local elapsed = os.clock() - startedAt
        local distance = self.Options.FollowDistance or 12
        local height = self.Options.FollowHeight or 3.5
        local amplitude = self.Options.HoverAmplitude or 0.35
        local speed = self.Options.HoverSpeed or 1.6
        local bob = math.sin(elapsed * speed) * amplitude
        local position = humanoidRootPart.Position
            + humanoidRootPart.CFrame.LookVector * distance
            + Vector3.new(0, height + bob, 0)
        local lookAt = humanoidRootPart.Position + Vector3.new(0, 2.4, 0)
        adornee.CFrame = CFrame.lookAt(position, lookAt)
    end)
    self._maid:Give(self._followConnection)
end

function Root:_create()
    local previous = self.Instance
    local previousOverlay = self.Overlay
    local preservedChildren = {}
    if previous then
        for _, child in ipairs(previous:GetChildren()) do table.insert(preservedChildren, child) end
    end
    local playerGui = self.Options.Parent
    local mode = self.Mode
    assert(modes[mode], ("Unsupported Nebula render mode: %s"):format(tostring(mode)))
    self:_stopPresentationEffects()
    if previousOverlay and previousOverlay.Parent then previousOverlay:Destroy() end

    local container: Instance
    local overlay: ScreenGui? = nil
    if mode == "2D" then
        container = Instance.new("ScreenGui")
        container.Name = "NebulaRoot2D"
        container.ResetOnSpawn = false
        container.IgnoreGuiInset = false
        container.ZIndexBehavior = Enum.ZIndexBehavior.Global
        container.DisplayOrder = self.Options.DisplayOrder or 20
        container.Parent = playerGui
    else
        local adornee = self.Options.Adornee
        assert(adornee and adornee:IsA("BasePart"), "3D and Hybrid modes require an Adornee BasePart")
        container = Instance.new("SurfaceGui")
        container.Name = "NebulaRoot3D"
        container.Adornee = adornee
        container.Face = self.Options.Face or Enum.NormalId.Front
        container.AlwaysOnTop = self.Options.AlwaysOnTop ~= false
        container.LightInfluence = 0
        container.Brightness = self.Options.Brightness or 2
        container.SizingMode = Enum.SurfaceGuiSizingMode.Fixed
        container.CanvasSize = self.Options.CanvasSize or Vector2.new(1000, 700)
        container.ZIndexBehavior = Enum.ZIndexBehavior.Global
        container.Parent = playerGui
        self:_startPresentationEffects(adornee, container)
        if mode == "Hybrid" then
            overlay = Instance.new("ScreenGui")
            overlay.Name = "NebulaOverlay"
            overlay.ResetOnSpawn = false
            overlay.IgnoreGuiInset = false
            overlay.ZIndexBehavior = Enum.ZIndexBehavior.Global
            overlay.DisplayOrder = (self.Options.DisplayOrder or 20) + 1
            overlay.Parent = playerGui
        end
    end
    for _, child in ipairs(preservedChildren) do child.Parent = container end
    if previous and previous.Parent then previous:Destroy() end
    self.Instance = container
    self.Overlay = overlay
    self._maid:Give(container)
    if overlay then self._maid:Give(overlay) end
end

function Root:AnimateExit(callback: () -> ())
    if self.Mode == "2D" or not self.Instance or not self.Instance.Parent or not self.Animations then
        callback()
        return
    end

    local pending = 0
    local finished = false
    local snapshots = {}
    local function complete()
        pending -= 1
        if pending <= 0 and not finished then
            finished = true
            for child, snapshot in pairs(snapshots) do
                if child.Parent then
                    child.Position = snapshot.Position
                    child.Rotation = snapshot.Rotation
                    child.BackgroundTransparency = snapshot.BackgroundTransparency
                end
            end
            callback()
        end
    end

    for _, child in ipairs(self.Instance:GetChildren()) do
        if child:IsA("GuiObject") then
            pending += 1
            snapshots[child] = {
                Position = child.Position,
                Rotation = child.Rotation,
                BackgroundTransparency = child.BackgroundTransparency,
            }
            local targetPosition = UDim2.new(
                child.Position.X.Scale,
                child.Position.X.Offset,
                child.Position.Y.Scale - 0.35,
                child.Position.Y.Offset
            )
            local tween = self.Animations:Play(child, {
                Position = targetPosition,
                Rotation = child.Rotation + 360,
                BackgroundTransparency = 1,
            }, "orbit")
            if tween then
                self._maid:Give(tween.Completed:Connect(complete))
            else
                complete()
            end
        end
    end

    if pending == 0 then
        callback()
    end
end

function Root:SetMode(mode: string, options: {[string]: any}?)
    assert(modes[mode], ("Unsupported Nebula render mode: %s"):format(tostring(mode)))
    self.Mode = mode
    if options then for key, value in pairs(options) do self.Options[key] = value end end
    self:_create()
end

return Root
