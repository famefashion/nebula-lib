--!strict

local UserInputService = game:GetService("UserInputService")
local Component = require(script.Parent.Component)
local Surface = require(script.Parent.Surface)
local Layout = require(script.Parent.Parent.Layout.Layout)

local Window = {}
Window.__index = Window

function Window.new(root: Instance, options: {[string]: any}, theme, animations, maid)
    local frame = Instance.new("Frame")
    frame.Name = "NebulaWindow"
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    local targetPosition = UDim2.fromScale(0.5, 0.5)
    frame.Position = UDim2.new(0.5, 0, 0.5, 12)
    frame.Size = UDim2.fromOffset(820, 520)
    frame.BackgroundColor3 = theme.BackgroundSecondary
    frame.BackgroundTransparency = 1
    frame.BorderSizePixel = 0
    frame.Parent = root
    animations:Play(frame, {
        Position = targetPosition,
        BackgroundTransparency = 0.04,
    }, "reveal")
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, theme.CornerRadius + 4)
    corner.Parent = frame
    local stroke = Instance.new("UIStroke")
    stroke.Color = theme.Border
    stroke.Transparency = 0.12
    stroke.Parent = frame

    local header = Instance.new("Frame")
    header.BackgroundTransparency = 1
    header.Position = UDim2.fromOffset(20, 16)
    header.Size = UDim2.new(1, -40, 0, 42)
    header.Parent = frame
    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, 0, 0, 22)
    title.Font = Enum.Font.GothamBold
    title.Text = options.Title or "Nebula"
    title.TextColor3 = theme.Text
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    local subtitle = Instance.new("TextLabel")
    subtitle.BackgroundTransparency = 1
    subtitle.Position = UDim2.fromOffset(0, 23)
    subtitle.Size = UDim2.new(1, 0, 0, 16)
    subtitle.Font = Enum.Font.Gotham
    subtitle.Text = options.Subtitle or "Interface runtime"
    subtitle.TextColor3 = theme.TextMuted
    subtitle.TextSize = 11
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.Parent = header

    local nav = Instance.new("Frame")
    nav.Name = "Navigation"
    nav.BackgroundTransparency = 1
    nav.Position = UDim2.fromOffset(20, 78)
    nav.Size = UDim2.new(0, 164, 1, -98)
    nav.Parent = frame
    Layout.Column(nav, { Spacing = 6 })
    local content = Instance.new("ScrollingFrame")
    content.Name = "Content"
    content.Position = UDim2.fromOffset(204, 78)
    content.Size = UDim2.new(1, -224, 1, -98)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.ScrollBarThickness = 3
    content.ScrollBarImageColor3 = theme.Accent
    content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    content.CanvasSize = UDim2.new()
    content.Parent = frame

    local self = Component.new(frame, theme, animations)
    setmetatable(self, Window)
    self._navigation = nav
    self._content = content
    self._tabs = {}
    self._active = nil
    maid:Give(self)

    local dragging = false
    local dragStart: Vector2
    local startPosition: UDim2
    self.Maid:Give(header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPosition = frame.Position
        end
    end))
    self.Maid:Give(UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
        end
    end))
    self.Maid:Give(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end))
    return self
end

function Window:AddTab(name: string, icon: string?)
    local tabButton = Instance.new("TextButton")
    tabButton.Name = name
    tabButton.AutoButtonColor = false
    tabButton.BackgroundColor3 = self.Theme.SurfaceSecondary
    tabButton.BackgroundTransparency = 0.4
    tabButton.Size = UDim2.new(1, 0, 0, 34)
    tabButton.Font = Enum.Font.GothamMedium
    tabButton.Text = (icon and icon .. "  " or "") .. name
    tabButton.TextColor3 = self.Theme.TextSecondary
    tabButton.TextSize = 12
    tabButton.TextXAlignment = Enum.TextXAlignment.Left
    tabButton.Parent = self._navigation
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 12)
    padding.Parent = tabButton
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = tabButton

    local page = Instance.new("Frame")
    page.Name = name .. "Page"
    page.BackgroundTransparency = 1
    page.Size = UDim2.new(1, -16, 0, 0)
    page.AutomaticSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.Parent = self._content
    Layout.Column(page, { Spacing = 12 })
    local tab = setmetatable({
        Name = name,
        Page = page,
        Button = tabButton,
        _window = self,
        Maid = require(script.Parent.Parent.Core.Maid).new(),
    }, { __index = require(script.Parent.Tab) })
    table.insert(self._tabs, tab)
    self.Maid:Give(tab)
    self.Maid:Give(tabButton.Activated:Connect(function()
        self:SelectTab(tab)
    end))
    if not self._active then
        self:SelectTab(tab)
    end
    return tab
end

function Window:SelectTab(tab)
    self._active = tab
    for _, item in ipairs(self._tabs) do
        local active = item == tab
        item.Page.Visible = active
        item.Button.BackgroundTransparency = active and 0 or 0.4
        item.Button.BackgroundColor3 = active and self.Theme.Accent or self.Theme.SurfaceSecondary
        item.Button.TextColor3 = active and self.Theme.Background or self.Theme.TextSecondary
        if active then
            local scale = item.Page:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
            scale.Scale = 0.97
            scale.Parent = item.Page
            self.Animations:Scale(item.Page, 1, "reveal")
        end
    end
end

return Window
