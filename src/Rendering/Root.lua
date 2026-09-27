--!strict

local Root = {}
Root.__index = Root

local modes = { ["2D"] = true, ["3D"] = true, Hybrid = true }

function Root.new(mode: string?, options: {[string]: any}, maid)
    local self = setmetatable({
        Mode = mode or "2D",
        Options = options or {},
        Instance = nil,
        _overlay = nil,
        _maid = maid,
    }, Root)
    self:_create()
    return self
end

function Root:_create()
    local previous = self.Instance
    local previousOverlay = self._overlay
    local children = {}
    if previous and previous.Parent then
        for _, child in ipairs(previous:GetChildren()) do
            table.insert(children, child)
        end
    end
    local playerGui = self.Options.Parent
    local mode = self.Mode
    assert(modes[mode], ("Unsupported Nebula render mode: %s"):format(tostring(mode)))

    local container: Instance
    if mode == "2D" then
        container = Instance.new("ScreenGui")
        container.ResetOnSpawn = false
        container.IgnoreGuiInset = true
        container.DisplayOrder = self.Options.DisplayOrder or 20
        container.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        container.Parent = playerGui
    else
        local adornee = self.Options.Adornee
        assert(adornee and adornee:IsA("BasePart"), "3D and Hybrid modes require an Adornee BasePart")
        container = Instance.new("SurfaceGui")
        container.Adornee = adornee
        container.Face = self.Options.Face or Enum.NormalId.Front
        container.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
        container.PixelsPerStud = self.Options.PixelsPerStud or 50
        container.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        container.Parent = adornee
        if mode == "Hybrid" then
            local overlay = Instance.new("ScreenGui")
            overlay.ResetOnSpawn = false
            overlay.IgnoreGuiInset = true
            overlay.DisplayOrder = self.Options.DisplayOrder or 20
            overlay.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            overlay.Parent = playerGui
            self._overlay = overlay
            self._maid:Give(overlay)
        else
            self._overlay = nil
        end
    end
    for _, child in ipairs(children) do
        if child.Parent == previous then
            child.Parent = container
        end
    end
    if previous and previous.Parent then
        previous:Destroy()
    end
    if previousOverlay and previousOverlay.Parent then
        previousOverlay:Destroy()
    end
    self.Instance = container
    self._maid:Give(container)
end

function Root:SetMode(mode: string, options: {[string]: any}?)
    assert(modes[mode], ("Unsupported Nebula render mode: %s"):format(tostring(mode)))
    self.Mode = mode
    if options then
        for key, value in pairs(options) do
            self.Options[key] = value
        end
    end
    self:_create()
end

return Root
