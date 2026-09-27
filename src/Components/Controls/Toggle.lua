--!strict

local Component = require(script.Parent.Parent.Component)
local Value = require(script.Parent.Parent.Parent.State.Value)
local Responsive = require(script.Parent.Parent.Parent.Utilities.Responsive)

local Toggle = {}
Toggle.__index = Toggle

function Toggle.new(parent: Instance, options: {[string]: any}, theme, animations)
    local row = Instance.new("TextButton")
    row.Name = options.Label or "Toggle"
    row.AutoButtonColor = false
    row.BackgroundTransparency = 1
    row.Size = UDim2.new(1, 0, 0, math.max(theme.ControlHeight, Responsive.TouchTarget(true)))
    row.Text = ""
    row.Parent = parent

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, -74, 1, 0)
    label.Font = Enum.Font.Gotham
    label.Text = options.Label or "Toggle"
    label.TextColor3 = theme.TextSecondary
    label.TextSize = options.TextSize or 14
    label.TextTruncate = Enum.TextTruncate.AtEnd
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row

    local track = Instance.new("Frame")
    track.AnchorPoint = Vector2.new(1, 0.5)
    track.Position = UDim2.new(1, 0, 0.5, 0)
    track.Size = UDim2.fromOffset(50, 28)
    track.BackgroundColor3 = theme.Border
    track.BorderSizePixel = 0
    track.Parent = row
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = track
    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(20, 20)
    knob.Position = UDim2.fromOffset(4, 4)
    knob.BackgroundColor3 = theme.Text
    knob.BorderSizePixel = 0
    knob.Parent = track
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob
    local trackStroke = Instance.new("UIStroke")
    trackStroke.Color = theme.BorderHover
    trackStroke.Transparency = 0.25
    trackStroke.Parent = track

    local self = Component.new(row, theme, animations)
    setmetatable(self, Toggle)
    self.Value = Value.new(options.Default == true)

    local function render(value: boolean)
        animations:Play(track, { BackgroundColor3 = value and theme.Accent or theme.Border }, "quick")
        animations:Play(knob, {
            Position = value and UDim2.fromOffset(26, 4) or UDim2.fromOffset(4, 4),
            BackgroundColor3 = value and theme.Background or theme.Text,
        }, "quick")
        animations:Play(trackStroke, {
            Color = value and theme.Accent or theme.BorderHover,
            Transparency = value and 0.05 or 0.25,
        }, "quick")
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
