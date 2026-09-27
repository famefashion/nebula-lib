--!strict

local Component = require(script.Parent.Component)
local Layout = require(script.Parent.Parent.Layout.Layout)

local Surface = {}
Surface.__index = Surface
setmetatable(Surface, Component)

function Surface.new(parent: Instance, options: {[string]: any}, theme, animations)
    local autoSize = options.Size == nil
    local topPadding = options.Title and 46 or 16
    local frame = Instance.new("Frame")
    frame.Name = options.Title or "Surface"
    frame.BackgroundColor3 = theme.Surface
    frame.BackgroundTransparency = theme.Transparency
    frame.BorderSizePixel = 0
    frame.Size = options.Size or UDim2.new(1, 0, 0, topPadding + 16)
    frame.LayoutOrder = options.LayoutOrder or 0
    frame.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, options.CornerRadius or theme.CornerRadius)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = theme.Border
    stroke.Transparency = 0.2
    stroke.Parent = frame
    local glow = Instance.new("UIStroke")
    glow.Name = "NebulaGlow"
    glow.Color = theme.AccentSecondary
    glow.Thickness = 3
    glow.Transparency = 0.84
    glow.Parent = frame

    local self = Component.new(frame, theme, animations)
    setmetatable(self, Surface)
    self.Content = Instance.new("Frame")
    self.Content.Name = "Content"
    self.Content.BackgroundTransparency = 1
    self.Content.Position = UDim2.fromOffset(16, topPadding)
    self.Content.Size = autoSize
        and UDim2.new(1, -32, 0, 0)
        or UDim2.new(1, -32, 1, options.Title and -62 or -32)
    self.Content.Parent = frame
    local contentLayout = Layout.Column(self.Content, { Spacing = 8 })

    if autoSize then
        local function resizeToContent()
            local contentHeight = contentLayout.AbsoluteContentSize.Y
            self.Content.Size = UDim2.new(1, -32, 0, contentHeight)
            frame.Size = UDim2.new(1, 0, 0, topPadding + contentHeight + 16)
        end
        self.Maid:Give(contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(resizeToContent))
        resizeToContent()
    end

    if options.Title then
        local title = Instance.new("TextLabel")
        title.Name = "Title"
        title.BackgroundTransparency = 1
        title.Position = UDim2.fromOffset(16, 13)
        title.Size = UDim2.new(1, -32, 0, 22)
        title.Font = Enum.Font.GothamMedium
        title.Text = options.Title
        title.TextColor3 = theme.Text
        title.TextSize = 15
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Parent = frame
    end
    return self
end

function Surface:AddButton(options: {[string]: any})
    local Button = require(script.Parent.Controls.Button)
    local button = Button.new(self.Content, options, self.Theme, self.Animations)
    self.Maid:Give(button)
    return button
end

function Surface:AddToggle(options: {[string]: any})
    local Toggle = require(script.Parent.Controls.Toggle)
    local toggle = Toggle.new(self.Content, options, self.Theme, self.Animations)
    self.Maid:Give(toggle)
    return toggle
end

function Surface:AddSlider(options: {[string]: any})
    local Slider = require(script.Parent.Controls.Slider)
    local slider = Slider.new(self.Content, options, self.Theme, self.Animations)
    self.Maid:Give(slider)
    return slider
end

return Surface
