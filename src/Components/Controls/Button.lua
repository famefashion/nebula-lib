--!strict

local Component = require(script.Parent.Parent.Component)

local Button = {}
Button.__index = Button

function Button.new(parent: Instance, options: {[string]: any}, theme, animations)
    local button = Instance.new("TextButton")
    button.Name = options.Label or "Button"
    button.AutoButtonColor = false
    button.BackgroundColor3 = theme.SurfaceSecondary
    button.BorderSizePixel = 0
    button.Size = UDim2.new(1, 0, 0, theme.ControlHeight)
    button.Font = Enum.Font.GothamMedium
    button.Text = options.Label or "Button"
    button.TextColor3 = theme.Text
    button.TextSize = 13
    button.TextTruncate = Enum.TextTruncate.AtEnd
    button.Parent = parent
    local scale = Instance.new("UIScale")
    scale.Scale = 0.96
    scale.Parent = button
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, theme.CornerRadius - 3)
    corner.Parent = button
    local stroke = Instance.new("UIStroke")
    stroke.Color = theme.Border
    stroke.Transparency = 0.15
    stroke.Parent = button
    local self = Component.new(button, theme, animations)
    setmetatable(self, Button)
    animations:Scale(button, 1, "spring")

    self.Maid:Give(button.MouseEnter:Connect(function()
        animations:Play(button, { BackgroundColor3 = theme.Surface }, "quick")
        animations:Play(stroke, { Transparency = 0 }, "quick")
        animations:Scale(button, 1.015, "quick")
    end))
    self.Maid:Give(button.MouseLeave:Connect(function()
        animations:Play(button, { BackgroundColor3 = theme.SurfaceSecondary }, "quick")
        animations:Play(stroke, { Transparency = 0.15 }, "quick")
        animations:Scale(button, 1, "quick")
    end))
    self.Maid:Give(button.Activated:Connect(function()
        if options.OnClick then
            options.OnClick()
        end
    end))
    return self
end

return Button
