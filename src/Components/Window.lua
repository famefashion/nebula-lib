--!strict

local UserInputService = game:GetService("UserInputService")
local Component = require(script.Parent.Component)
local Surface = require(script.Parent.Surface)
local Layout = require(script.Parent.Parent.Layout.Layout)
local Responsive = require(script.Parent.Parent.Utilities.Responsive)

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
    local headerRule = Instance.new("Frame")
    headerRule.Name = "HeaderRule"
    headerRule.BackgroundColor3 = theme.Border
    headerRule.BackgroundTransparency = 0.35
    headerRule.BorderSizePixel = 0
    headerRule.Position = UDim2.fromOffset(0, 62)
    headerRule.Size = UDim2.new(1, 0, 0, 1)
    headerRule.Parent = frame
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

    local menuButton = Instance.new("TextButton")
    menuButton.Name = "MobileMenu"
    menuButton.AnchorPoint = Vector2.new(0, 0.5)
    menuButton.Position = UDim2.fromOffset(0, 21)
    menuButton.Size = UDim2.fromOffset(40, 40)
    menuButton.BackgroundColor3 = theme.SurfaceSecondary
    menuButton.BorderSizePixel = 0
    menuButton.AutoButtonColor = false
    menuButton.Font = Enum.Font.GothamBold
    menuButton.Text = "☰"
    menuButton.TextColor3 = theme.Text
    menuButton.TextSize = 18
    menuButton.Visible = false
    menuButton.Parent = header
    local menuCorner = Instance.new("UICorner")
    menuCorner.CornerRadius = UDim.new(0, 10)
    menuCorner.Parent = menuButton
    local menuStroke = Instance.new("UIStroke")
    menuStroke.Color = theme.Border
    menuStroke.Transparency = 0.15
    menuStroke.Parent = menuButton

    local nav = Instance.new("ScrollingFrame")
    nav.Name = "Navigation"
    nav.BackgroundTransparency = 1
    nav.Position = UDim2.fromOffset(20, 78)
    nav.Size = UDim2.new(0, 164, 1, -98)
    nav.BorderSizePixel = 0
    nav.CanvasSize = UDim2.new()
    nav.AutomaticCanvasSize = Enum.AutomaticSize.Y
    nav.ScrollBarThickness = 0
    nav.ScrollingDirection = Enum.ScrollingDirection.Y
    nav.Parent = frame
    nav.BackgroundColor3 = theme.Background
    nav.BackgroundTransparency = 0.25
    local navCorner = Instance.new("UICorner")
    navCorner.CornerRadius = UDim.new(0, theme.CornerRadius)
    navCorner.Parent = nav
    local navStroke = Instance.new("UIStroke")
    navStroke.Color = theme.Border
    navStroke.Transparency = 0.35
    navStroke.Parent = nav
    Layout.Column(nav, { Spacing = 6 })
    local content = Instance.new("ScrollingFrame")
    content.Name = "Content"
    content.Position = UDim2.fromOffset(204, 78)
    content.Size = UDim2.new(1, -224, 1, -98)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.ScrollBarThickness = 3
    content.ScrollBarImageColor3 = theme.Accent
    content.ScrollBarImageTransparency = 0.35
    content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    content.CanvasSize = UDim2.new()
    content.Parent = frame

    local self = Component.new(frame, theme, animations)
    setmetatable(self, Window)
    self._navigation = nav
    self._content = content
    self._header = header
    self._headerRule = headerRule
    self._title = title
    self._subtitle = subtitle
    self._menuButton = menuButton
    self._menuOpen = false
    self._compact = false
    self._tabs = {}
    self._active = nil
    maid:Give(self)
    self.Maid:Give(menuButton.Activated:Connect(function()
        self:SetMenuOpen(not self._menuOpen)
    end))

    local dragging = false
    local dragInput
    local dragStart: Vector2
    local startPosition: Vector2
    self.Maid:Give(header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragInput = input
            dragStart = input.Position
            startPosition = frame.AbsolutePosition + frame.AbsoluteSize / 2
        end
    end))
    self.Maid:Give(header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end))
    self.Maid:Give(UserInputService.InputChanged:Connect(function(input)
        if dragging and (input == dragInput
            or input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.fromOffset(
                startPosition.X + delta.X,
                startPosition.Y + delta.Y
            )
            self:ConstrainToViewport()
        end
    end))
    self.Maid:Give(UserInputService.InputEnded:Connect(function(input)
        if input == dragInput
            or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            dragInput = nil
            self:ConstrainToViewport()
        end
    end))
    return self
end

function Window:ConstrainToViewport(viewportSize: Vector2?)
    local camera = workspace.CurrentCamera
    local viewport = viewportSize or (camera and camera.ViewportSize)
    if not viewport or not self.Instance or not self.Instance.Parent then
        return
    end

    local frame = self.Instance
    local halfWidth = frame.AbsoluteSize.X / 2
    local halfHeight = frame.AbsoluteSize.Y / 2
    local margin = 12
    local position = frame.AbsolutePosition + frame.AbsoluteSize / 2
    local minimumX = math.min(halfWidth + margin, viewport.X / 2)
    local maximumX = math.max(viewport.X - halfWidth - margin, viewport.X / 2)
    local minimumY = math.min(halfHeight + margin, viewport.Y / 2)
    local maximumY = math.max(viewport.Y - halfHeight - margin, viewport.Y / 2)

    frame.Position = UDim2.fromOffset(
        math.clamp(position.X, minimumX, maximumX),
        math.clamp(position.Y, minimumY, maximumY)
    )
end

function Window:SetMenuOpen(open: boolean)
    self._menuOpen = open == true
    if self._menuButton then
        self._menuButton.Text = self._menuOpen and "×" or "☰"
    end
    if self._navigation then
        self._navigation.Visible = not self._compact or self._menuOpen
    end
end

function Window:ApplyResponsive(viewportSize: Vector2, breakpoint: string)
    if not self.Instance or not self.Instance.Parent then
        return
    end

    local touchDevice = UserInputService.TouchEnabled
    local compact = breakpoint == "Compact"
        or viewportSize.X < 760
        or (touchDevice and viewportSize.X < 1100)
    self._compact = compact
    local width
    local height
    if compact then
        width = math.clamp(math.floor(viewportSize.X * 0.88), 300, 760)
        height = math.clamp(math.floor(viewportSize.Y * 0.84), 280, 640)
    else
        width = math.max(math.min(900, viewportSize.X - 32), 1)
        height = math.max(math.min(620, viewportSize.Y - 48), 1)
    end
    self.Instance.Size = UDim2.fromOffset(width, height)
    self.Instance.BackgroundTransparency = compact and 0.015 or 0.04

    local layout = self._navigation:FindFirstChildOfClass("UIListLayout")
    if compact then
        self._header.Position = UDim2.fromOffset(14, 10)
        self._header.Size = UDim2.new(1, -28, 0, 40)
        self._headerRule.Position = UDim2.fromOffset(0, 58)
        self._title.Position = UDim2.fromOffset(52, 0)
        self._title.Size = UDim2.new(1, -52, 0, 24)
        self._title.TextSize = 16
        self._subtitle.Visible = false
        self._menuButton.Visible = true
        self._navigation.Position = UDim2.fromOffset(12, 66)
        self._navigation.Size = UDim2.fromOffset(
            math.min(220, width - 24),
            math.min(280, math.max(height - 82, 160))
        )
        self._navigation.AutomaticCanvasSize = Enum.AutomaticSize.Y
        self._navigation.ScrollingDirection = Enum.ScrollingDirection.Y
        self._navigation.ScrollBarThickness = 0
        self._navigation.BackgroundColor3 = self.Theme.BackgroundSecondary
        self._navigation.BackgroundTransparency = 0.02
        self._navigation.ZIndex = 20
        self:SetMenuOpen(self._menuOpen)
        if layout then
            layout.FillDirection = Enum.FillDirection.Vertical
            layout.VerticalAlignment = Enum.VerticalAlignment.Top
            layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
            layout.Padding = UDim.new(0, 6)
        end
        self._content.Position = UDim2.fromOffset(12, 70)
        self._content.Size = UDim2.new(1, -24, 1, -82)
        self._content.ScrollBarThickness = 2
        for _, tab in ipairs(self._tabs) do
            tab.Button.Size = UDim2.new(1, 0, 0, Responsive.TouchTarget(true))
            tab.Button.TextXAlignment = Enum.TextXAlignment.Left
            tab.Button.TextSize = 13
            tab.Button.ZIndex = 21
        end
    else
        self._header.Position = UDim2.fromOffset(20, 16)
        self._header.Size = UDim2.new(1, -40, 0, 42)
        self._headerRule.Position = UDim2.fromOffset(0, 62)
        self._title.Position = UDim2.fromOffset(0, 0)
        self._title.Size = UDim2.new(1, 0, 0, 22)
        self._title.TextSize = 18
        self._subtitle.Visible = true
        self._menuButton.Visible = false
        self._navigation.Position = UDim2.fromOffset(20, 78)
        self._navigation.Size = UDim2.new(0, 164, 1, -98)
        self._navigation.AutomaticCanvasSize = Enum.AutomaticSize.Y
        self._navigation.ScrollingDirection = Enum.ScrollingDirection.Y
        self._navigation.ScrollBarThickness = 0
        self._navigation.BackgroundColor3 = self.Theme.Background
        self._navigation.BackgroundTransparency = 0.25
        self._navigation.ZIndex = 1
        self:SetMenuOpen(false)
        if layout then
            layout.FillDirection = Enum.FillDirection.Vertical
            layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
            layout.VerticalAlignment = Enum.VerticalAlignment.Top
            layout.Padding = UDim.new(0, 6)
        end
        self._content.Position = UDim2.fromOffset(204, 78)
        self._content.Size = UDim2.new(1, -224, 1, -98)
        self._content.ScrollBarThickness = 3
        for _, tab in ipairs(self._tabs) do
            tab.Button.Size = UDim2.new(1, 0, 0, Responsive.TouchTarget(false))
            tab.Button.TextXAlignment = Enum.TextXAlignment.Left
            tab.Button.TextSize = 12
        end
    end

    self:ConstrainToViewport(viewportSize)
end

function Window:AddTab(name: string, icon: string?)
    local tabButton = Instance.new("TextButton")
    tabButton.Name = name
    tabButton.AutoButtonColor = false
    tabButton.BackgroundColor3 = self.Theme.SurfaceSecondary
    tabButton.BackgroundTransparency = 0.4
    tabButton.Size = UDim2.new(1, 0, 0, Responsive.TouchTarget(false))
    tabButton.Font = Enum.Font.GothamMedium
    tabButton.Text = (icon and icon .. "  " or "") .. name
    tabButton.TextColor3 = self.Theme.TextSecondary
    tabButton.TextSize = 12
    tabButton.TextXAlignment = Enum.TextXAlignment.Left
    tabButton.Parent = self._navigation
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 12)
    padding.PaddingRight = UDim.new(0, 12)
    padding.Parent = tabButton
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = tabButton
    local tabStroke = Instance.new("UIStroke")
    tabStroke.Color = self.Theme.Border
    tabStroke.Transparency = 0.55
    tabStroke.Parent = tabButton

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
        ButtonStroke = tabStroke,
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
    if self._compact then
        self:SetMenuOpen(false)
    end
    for _, item in ipairs(self._tabs) do
        local active = item == tab
        item.Page.Visible = active
        item.Button.BackgroundTransparency = active and 0 or 0.4
        item.Button.BackgroundColor3 = active and self.Theme.Accent or self.Theme.SurfaceSecondary
        item.Button.TextColor3 = active and self.Theme.Background or self.Theme.TextSecondary
        item.ButtonStroke.Color = active and self.Theme.Accent or self.Theme.Border
        item.ButtonStroke.Transparency = active and 0.05 or 0.55
        if active then
            local scale = item.Page:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
            scale.Scale = 0.97
            scale.Parent = item.Page
            self.Animations:Scale(item.Page, 1, "reveal")
        end
    end
end

return Window
