--!strict

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
    }, Root)
    self:_create()
    return self
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
    if previousOverlay and previousOverlay.Parent then previousOverlay:Destroy() end

    local container: Instance
    local overlay: ScreenGui? = nil
    if mode == "2D" then
        container = Instance.new("ScreenGui")
        container.ResetOnSpawn = false
        container.IgnoreGuiInset = false
        container.DisplayOrder = self.Options.DisplayOrder or 20
        container.Parent = playerGui
    else
        local adornee = self.Options.Adornee
        assert(adornee and adornee:IsA("BasePart"), "3D and Hybrid modes require an Adornee BasePart")
        container = Instance.new("SurfaceGui")
        container.Adornee = adornee
        container.Face = self.Options.Face or Enum.NormalId.Front
        container.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
        container.PixelsPerStud = self.Options.PixelsPerStud or 50
        container.Parent = playerGui
        if mode == "Hybrid" then
            overlay = Instance.new("ScreenGui")
            overlay.Name = "NebulaOverlay"
            overlay.ResetOnSpawn = false
            overlay.IgnoreGuiInset = false
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
