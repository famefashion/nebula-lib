--!strict

local Component = require(script.Parent.Parent.Component)
local Value = require(script.Parent.Parent.Parent.State.Value)

local Toggle = {}
Toggle.__index = Toggle

function Toggle.new(parent: Instance, options: {[string]: any}, theme, animations)
    local row = Instance.new("TextButton")
    row.Name = options.Label or "Toggle"
    row.AutoButtonColor = false
    row.BackgroundTransparency = 1
    row.Size = UDim2.new(1, 0, 0, theme.ControlHeight)
    row.Text = ""
    row.Parent = parent

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, -58, 1, 0)
    label.Font = Enum.Font.Gotham
    label.Text = options.Label or "Toggle"
    label.TextColor3 = theme.TextSecondary
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row

    local track = Instance.new("Frame")
    track.AnchorPoint = Vector2.new(1, 0.5)
    track.Position = UDim2.new(1, 0, 0.5, 0)
    track.Size = UDim2.fromOffset(42, 22)
    track.BackgroundColor3 = theme.Border
    track.BorderSizePixel = 0
    track.Parent = row
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = track
    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(16, 16)
    knob.Position = UDim2.fromOffset(3, 3)
    knob.BackgroundColor3 = theme.Text
    knob.BorderSizePixel = 0
    knob.Parent = track
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    local self = Component.new(row, theme, animations)
    setmetatable(self, Toggle)
    self.Value = Value.new(options.Default == true)

    local function render(value: boolean)
        animations:Play(track, { BackgroundColor3 = value and theme.Accent or theme.Border }, "quick")
        animations:Play(knob, { Position = value and UDim2.fromOffset(23, 3) or UDim2.fromOffset(3, 3) }, "quick")
    end
    render(self.Value:Get())
    self.Maid:Give(self.Value:Subscribe(function(value)
        render(value)
        if options.OnChanged then
            options.OnChanged(value)
        end
    end))
    self.Maid:Give(row.Activated:Connect(function()
        self:Set(not self:Get())
    end))
    self.Maid:Give(self.Value)
    return self
end

function Toggle:Get(): boolean
    return self.Value:Get()
end

function Toggle:Set(value: boolean)
    self.Value:Set(value == true)
end

function Toggle:OnChanged(callback: (boolean) -> ()): RBXScriptConnection
    return self.Value:Subscribe(callback)
end

return Toggle
