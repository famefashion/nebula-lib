--!strict

local Component = require(script.Parent.Parent.Component)

local Button = {}
Button.__index = Button

function Button.new(parent: Instance, options: {[string]: any}, theme, animations)
    local primary = options.Kind == "Primary"
    local button = Instance.new("TextButton")
    button.Name = options.Label or "Button"
    button.AutoButtonColor = false
    button.Active = true
    button.Selectable = true
    button.BackgroundColor3 = primary and theme.Accent or theme.SurfaceSecondary
    button.BackgroundTransparency = primary and 0.02 or 0
    button.BorderSizePixel = 0
    button.Size = UDim2.new(1, 0, 0, options.Height or theme.ControlHeight)
    button.Font = Enum.Font.GothamMedium
    button.Text = options.Label or "Button"
    button.TextColor3 = primary and theme.Background or theme.Text
    button.TextSize = 13
    button.TextWrapped = true
    button.Parent = parent
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, math.max(9, theme.CornerRadius - 3))
    corner.Parent = button
    local stroke = Instance.new("UIStroke")
    stroke.Color = primary and theme.AccentSecondary or theme.Border
    stroke.Transparency = primary and 0.4 or 0.28
    stroke.Parent = button
    local scale = Instance.new("UIScale")
    scale.Scale = 0.98
    scale.Parent = button
    local self = Component.new(button, theme, animations)
    setmetatable(self, Button)
    animations:Scale(button, 1, "spring")

    self.Maid:Give(button.MouseEnter:Connect(function()
        animations:Play(button, { BackgroundColor3 = primary and theme.AccentSecondary or theme.SurfaceSecondary }, "quick")
        animations:Scale(button, 1.015, "quick")
    end))
    self.Maid:Give(button.MouseLeave:Connect(function()
        animations:Play(button, { BackgroundColor3 = primary and theme.Accent or theme.SurfaceSecondary }, "quick")
        animations:Scale(button, 1, "quick")
    end))
    self.Maid:Give(button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            animations:Scale(button, 0.985, "quick")
        end
    end))
    self.Maid:Give(button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            animations:Scale(button, 1, "quick")
        end
    end))
    self.Maid:Give(button.Activated:Connect(function()
        if options.OnClick then
            options.OnClick()
        end
    end))
    return self
end

return Button
