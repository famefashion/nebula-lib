--!strict

local UserInputService = game:GetService("UserInputService")
local Component = require(script.Parent.Parent.Component)
local Value = require(script.Parent.Parent.Parent.State.Value)

local Slider = {}
Slider.__index = Slider

function Slider.new(parent: Instance, options: {[string]: any}, theme, animations)
    local range = options.Range
    local min = options.Min or (range and range.Min) or 0
    local max = options.Max or (range and range.Max) or 100
    local value = math.clamp(options.Default or min, min, max)
    local holder = Instance.new("Frame")
    holder.Name = options.Label or "Slider"
    holder.BackgroundTransparency = 1
    holder.Size = UDim2.new(1, 0, 0, 54)
    holder.Parent = parent

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(0.7, 0, 0, 20)
    label.Font = Enum.Font.Gotham
    label.Text = options.Label or "Slider"
    label.TextColor3 = theme.TextSecondary
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = holder
    local readout = label:Clone()
    readout.Name = "Value"
    readout.Position = UDim2.new(0.7, 0, 0, 0)
    readout.Size = UDim2.new(0.3, 0, 0, 20)
    readout.Text = tostring(value)
    readout.TextXAlignment = Enum.TextXAlignment.Right
    readout.Parent = holder

    local rail = Instance.new("Frame")
    rail.AnchorPoint = Vector2.new(0, 0.5)
    rail.Position = UDim2.new(0, 0, 0, 38)
    rail.Size = UDim2.new(1, 0, 0, 6)
    rail.BackgroundColor3 = theme.Border
    rail.BorderSizePixel = 0
    rail.Parent = holder
    local railCorner = Instance.new("UICorner")
    railCorner.CornerRadius = UDim.new(1, 0)
    railCorner.Parent = rail
    local fill = rail:Clone()
    fill.Name = "Fill"
    fill.BackgroundColor3 = theme.Accent
    fill.Size = UDim2.new((value - min) / math.max(max - min, 1), 0, 1, 0)
    fill.Parent = rail
    local knob = Instance.new("TextButton")
    knob.Name = "Knob"
    knob.Text = ""
    knob.AutoButtonColor = false
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new((value - min) / math.max(max - min, 1), 0, 0.5, 0)
    knob.Size = UDim2.fromOffset(18, 18)
    knob.BackgroundColor3 = theme.Text
    knob.BorderSizePixel = 0
    knob.Parent = rail
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    local self = Component.new(holder, theme, animations)
    setmetatable(self, Slider)
    self.Min = min
    self.Max = max
    self.Value = Value.new(value)
    local dragging = false
    local function update(inputX: number)
        local ratio = math.clamp((inputX - rail.AbsolutePosition.X) / rail.AbsoluteSize.X, 0, 1)
        self:Set(min + (max - min) * ratio)
    end
    local function render(nextValue: number)
        local ratio = (nextValue - min) / math.max(max - min, 1)
        readout.Text = options.Format and options.Format(nextValue) or tostring(math.floor(nextValue * 100) / 100)
        animations:Play(fill, { Size = UDim2.new(ratio, 0, 1, 0) }, "quick")
        animations:Play(knob, { Position = UDim2.new(ratio, 0, 0.5, 0) }, "quick")
    end
    self.Maid:Give(self.Value:Subscribe(function(nextValue)
        render(nextValue)
        if options.OnChanged then
            options.OnChanged(nextValue)
        end
    end))
    self.Maid:Give(knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end))
    self.Maid:Give(UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input.Position.X)
        end
    end))
    self.Maid:Give(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end))
    self.Maid:Give(self.Value)
    return self
end

function Slider:Get(): number
    return self.Value:Get()
end

function Slider:Set(value: number)
    self.Value:Set(math.clamp(value, self.Min or -math.huge, self.Max or math.huge))
end

function Slider:OnChanged(callback: (number) -> ()): RBXScriptConnection
    return self.Value:Subscribe(callback)
end

return Slider
