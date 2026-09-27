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
    self._selected = false
    local hovered = false
    local function render()
        local selected = self._selected
        animations:Play(button, { BackgroundColor3 = selected and theme.Accent or (hovered and theme.Surface or theme.SurfaceSecondary), TextColor3 = selected and theme.Background or theme.Text }, "quick")
        animations:Play(stroke, { Color = selected and theme.Accent or theme.Border, Transparency = selected and 0.05 or (hovered and 0 or 0.15) }, "quick")
        animations:Scale(button, selected and 1 or (hovered and 1.015 or 1), "quick")
    end
    self.Maid:Give(button.MouseEnter:Connect(function() hovered = true; render() end))
    self.Maid:Give(button.MouseLeave:Connect(function() hovered = false; render() end))
    self.Maid:Give(button.Activated:Connect(function() if options.OnClick then options.OnClick() end end))
    render()
    return self
end

function Button:SetSelected(selected: boolean)
    self._selected = selected == true
    local button = self.Instance
    if button and button.Parent then
        local stroke = button:FindFirstChildOfClass("UIStroke")
        button.BackgroundColor3 = self._selected and self.Theme.Accent or self.Theme.SurfaceSecondary
        button.TextColor3 = self._selected and self.Theme.Background or self.Theme.Text
        if stroke then
            stroke.Color = self._selected and self.Theme.Accent or self.Theme.Border
            stroke.Transparency = self._selected and 0.05 or 0.15
        end
    end
end

function Button:IsSelected(): boolean
    return self._selected == true
end

return Button
