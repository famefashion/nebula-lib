--!strict

local UserInputService = game:GetService("UserInputService")
local Component = require(script.Parent.Component)
local Surface = require(script.Parent.Surface)
local Layout = require(script.Parent.Parent.Layout.Layout)
local Maid = require(script.Parent.Parent.Core.Maid)

local Window = {}
Window.__index = Window

local function corner(instance: Instance, radius: number)
    local value = Instance.new("UICorner")
    value.CornerRadius = UDim.new(0, radius)
    value.Parent = instance
    return value
end

local function createTabButton(parent: Instance, name: string, icon: string?, theme, compact: boolean)
    local button = Instance.new("TextButton")
    button.Name = name
    button.AutoButtonColor = false
    button.Active = true
    button.Selectable = true
    button.BackgroundColor3 = theme.SurfaceSecondary
    button.BackgroundTransparency = 0.38
    button.BorderSizePixel = 0
    button.Size = compact and UDim2.fromOffset(118, 38) or UDim2.new(1, 0, 0, 40)
    button.Font = Enum.Font.GothamMedium
    button.Text = (icon and icon .. "  " or "") .. name
    button.TextColor3 = theme.TextSecondary
    button.TextSize = compact and 12 or 13
    button.TextTruncate = Enum.TextTruncate.AtEnd
    button.TextXAlignment = Enum.TextXAlignment.Left
    button.Parent = parent
    corner(button, compact and 11 or 10)
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, compact and 13 or 14)
    padding.PaddingRight = UDim.new(0, 10)
    padding.Parent = button
    return button
end

function Window.new(root: Instance, options: {[string]: any}, theme, animations, maid)
    local frame = Instance.new("Frame")
    frame.Name = "NebulaWindow"
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.Position = UDim2.fromScale(0.5, 0.5)
    frame.Size = UDim2.fromOffset(820, 520)
    frame.BackgroundColor3 = theme.BackgroundSecondary
    frame.BackgroundTransparency = 0.03
    frame.BorderSizePixel = 0
    frame.ClipsDescendants = true
    frame.Parent = root
    corner(frame, theme.CornerRadius + 5)
    local stroke = Instance.new("UIStroke")
    stroke.Color = theme.Border
    stroke.Transparency = 0.08
    stroke.Thickness = 1
    stroke.Parent = frame

    local accent = Instance.new("Frame")
    accent.Name = "AccentLine"
    accent.BackgroundColor3 = theme.Accent
    accent.BorderSizePixel = 0
    accent.Position = UDim2.fromOffset(18, 8)
    accent.Size = UDim2.new(0, 44, 0, 3)
    accent.Parent = frame
    corner(accent, 2)

    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Active = true
    header.BackgroundTransparency = 1
    header.Position = UDim2.fromOffset(18, 16)
    header.Size = UDim2.new(1, -36, 0, 40)
    header.Parent = frame

    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, -86, 0, 22)
    title.Font = Enum.Font.GothamBold
    title.Text = options.Title or "Nebula"
    title.TextColor3 = theme.Text
    title.TextSize = 18
    title.TextTruncate = Enum.TextTruncate.AtEnd
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header

    local subtitle = Instance.new("TextLabel")
    subtitle.BackgroundTransparency = 1
    subtitle.Position = UDim2.fromOffset(0, 23)
    subtitle.Size = UDim2.new(1, -86, 0, 16)
    subtitle.Font = Enum.Font.Gotham
    subtitle.Text = options.Subtitle or "Interface runtime"
    subtitle.TextColor3 = theme.TextMuted
    subtitle.TextSize = 11
    subtitle.TextTruncate = Enum.TextTruncate.AtEnd
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.Parent = header

    local status = Instance.new("TextLabel")
    status.BackgroundTransparency = 1
    status.AnchorPoint = Vector2.new(1, 0)
    status.Position = UDim2.new(1, 0, 0, 4)
    status.Size = UDim2.fromOffset(74, 18)
    status.Font = Enum.Font.GothamMedium
    status.Text = "●  READY"
    status.TextColor3 = theme.AccentSecondary
    status.TextSize = 10
    status.TextXAlignment = Enum.TextXAlignment.Right
    status.Parent = header

    local divider = Instance.new("Frame")
    divider.Name = "Divider"
    divider.BackgroundColor3 = theme.Border
    divider.BackgroundTransparency = 0.35
    divider.BorderSizePixel = 0
    divider.Position = UDim2.fromOffset(18, 64)
    divider.Size = UDim2.new(1, -36, 0, 1)
    divider.Parent = frame

    local nav = Instance.new("Frame")
    nav.Name = "Navigation"
    nav.BackgroundTransparency = 1
    nav.Position = UDim2.fromOffset(18, 82)
    nav.Size = UDim2.new(0, 168, 1, -102)
    nav.Parent = frame
    Layout.Column(nav, { Spacing = 7 })

    local mobileNav = Instance.new("ScrollingFrame")
    mobileNav.Name = "MobileNavigation"
    mobileNav.BackgroundTransparency = 1
    mobileNav.BorderSizePixel = 0
    mobileNav.Position = UDim2.fromOffset(18, 74)
    mobileNav.Size = UDim2.new(1, -36, 0, 38)
    mobileNav.CanvasSize = UDim2.new()
    mobileNav.AutomaticCanvasSize = Enum.AutomaticSize.X
    mobileNav.ScrollingDirection = Enum.ScrollingDirection.X
    mobileNav.ScrollBarThickness = 0
    mobileNav.Visible = false
    mobileNav.Parent = frame
    Layout.Row(mobileNav, { Spacing = 7 })

    local content = Instance.new("ScrollingFrame")
    content.Name = "Content"
    content.Position = UDim2.fromOffset(208, 82)
    content.Size = UDim2.new(1, -226, 1, -102)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.ScrollBarThickness = 3
    content.ScrollBarImageColor3 = theme.Accent
    content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    content.CanvasSize = UDim2.new()
    content.ClipsDescendants = true
    content.Parent = frame

    local self = Component.new(frame, theme, animations)
    setmetatable(self, Window)
    self._navigation = nav
    self._mobileNavigation = mobileNav
    self._content = content
    self._header = header
    self._divider = divider
    self._tabs = {}
    self._active = nil
    self._compact = false
    maid:Give(self)

    local dragging = false
    local dragStart: Vector2
    local startPosition: UDim2
    self.Maid:Give(header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPosition = frame.Position
        end
    end))
    self.Maid:Give(UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
        end
    end))
    self.Maid:Give(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end))
    self:SetResponsive(false)
    return self
end

function Window:AddTab(name: string, icon: string?)
    local tabButton = createTabButton(self._navigation, name, icon, self.Theme, false)
    local mobileButton = createTabButton(self._mobileNavigation, name, icon, self.Theme, true)
    local page = Instance.new("Frame")
    page.Name = name .. "Page"
    page.BackgroundTransparency = 1
    page.Size = UDim2.new(1, -8, 0, 0)
    page.AutomaticSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.Parent = self._content
    Layout.Column(page, { Spacing = 12 })
    local tab = setmetatable({
        Name = name,
        Page = page,
        Button = tabButton,
        MobileButton = mobileButton,
        _window = self,
        Maid = Maid.new(),
    }, { __index = require(script.Parent.Tab) })
    table.insert(self._tabs, tab)
    self.Maid:Give(tab)
    self.Maid:Give(tabButton.Activated:Connect(function()
        self:SelectTab(tab)
    end))
    self.Maid:Give(mobileButton.Activated:Connect(function()
        self:SelectTab(tab)
    end))
    if not self._active then
        self:SelectTab(tab)
    end
    return tab
end

function Window:AddSettingsTab(app, options: {[string]: any}?)
    options = options or {}
    local tab = self:AddTab(options.Name or "UI Settings", options.Icon or "⚙")
    tab:AddText(options.Description or "Tune the interface for your device and choose where Nebula renders.", {
        Height = 38,
        TextSize = 13,
        Color = self.Theme.TextSecondary,
    })
    local surface = tab:AddSurface({ Title = "Display mode" })
    local modes = {
        { Name = "2D", Detail = "Screen overlay", Icon = "▣" },
        { Name = "3D", Detail = "SurfaceGui on a part", Icon = "◇" },
        { Name = "Hybrid", Detail = "Surface + screen overlay", Icon = "◈" },
    }
    for _, mode in ipairs(modes) do
        surface:AddButton({
            Label = string.format("%s  %s  ·  %s", mode.Icon, mode.Name, mode.Detail),
            Kind = mode.Name == "2D" and "Primary" or "Default",
            OnClick = function()
                if not app:CanUseRenderMode(mode.Name) then
                    app:Toast(mode.Name .. " mode needs a BasePart Adornee", "warning", 3)
                    return
                end
                local ok, err = pcall(function()
                    app:SetRenderMode(mode.Name)
                end)
                if ok then
                    app:Toast(mode.Name .. " display mode active", "success", 2.5)
                else
                    app:Toast(tostring(err), "error", 4)
                end
            end,
        })
    end
    return tab
end

function Window:SelectTab(tab)
    self._active = tab
    for _, item in ipairs(self._tabs) do
        local active = item == tab
        item.Page.Visible = active
        for _, button in ipairs({ item.Button, item.MobileButton }) do
            button.BackgroundTransparency = active and 0 or 0.38
            button.BackgroundColor3 = active and self.Theme.Accent or self.Theme.SurfaceSecondary
            button.TextColor3 = active and self.Theme.Background or self.Theme.TextSecondary
        end
        if active then
            local scale = item.Page:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
            scale.Scale = 0.985
            scale.Parent = item.Page
            self.Animations:Scale(item.Page, 1, "reveal")
        end
    end
end

function Window:SetResponsive(compact: boolean)
    self._compact = compact
    if compact then
        self.Instance.Size = UDim2.new(1, -20, 1, -28)
        self._header.Position = UDim2.fromOffset(16, 12)
        self._header.Size = UDim2.new(1, -32, 0, 40)
        self._divider.Position = UDim2.fromOffset(16, 64)
        self._divider.Size = UDim2.new(1, -32, 0, 1)
        self._navigation.Visible = false
        self._mobileNavigation.Visible = true
        self._mobileNavigation.Position = UDim2.fromOffset(16, 74)
        self._mobileNavigation.Size = UDim2.new(1, -32, 0, 38)
        self._content.Position = UDim2.fromOffset(16, 124)
        self._content.Size = UDim2.new(1, -32, 1, -140)
        self._content.ScrollBarThickness = 0
    else
        self.Instance.Size = UDim2.fromOffset(820, 520)
        self._header.Position = UDim2.fromOffset(18, 16)
        self._header.Size = UDim2.new(1, -36, 0, 40)
        self._divider.Position = UDim2.fromOffset(18, 64)
        self._divider.Size = UDim2.new(1, -36, 0, 1)
        self._navigation.Visible = true
        self._mobileNavigation.Visible = false
        self._navigation.Position = UDim2.fromOffset(18, 82)
        self._navigation.Size = UDim2.new(0, 168, 1, -102)
        self._content.Position = UDim2.fromOffset(208, 82)
        self._content.Size = UDim2.new(1, -226, 1, -102)
        self._content.ScrollBarThickness = 3
    end
end

function Window:ApplyResponsive(_viewport, breakpoint: string)
    self:SetResponsive(breakpoint == "Compact")
end

return Window
