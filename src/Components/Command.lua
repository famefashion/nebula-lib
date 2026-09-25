--!strict

local UserInputService = game:GetService("UserInputService")
local Component = require(script.Parent.Component)

local Command = {}
Command.__index = Command

function Command.new(root: Instance, commands, theme, animations, maid)
    local overlay = Instance.new("Frame")
    overlay.Name = "NebulaCommand"
    overlay.BackgroundColor3 = theme.Background
    overlay.BackgroundTransparency = 0.05
    overlay.Size = UDim2.fromOffset(480, 340)
    overlay.AnchorPoint = Vector2.new(0.5, 0)
    overlay.Position = UDim2.new(0.5, 0, 0, 80)
    overlay.Visible = false
    overlay.Parent = root
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, theme.CornerRadius)
    corner.Parent = overlay
    local input = Instance.new("TextBox")
    input.ClearTextOnFocus = false
    input.PlaceholderText = "Search commands..."
    input.Text = ""
    input.TextColor3 = theme.Text
    input.PlaceholderColor3 = theme.TextMuted
    input.Font = Enum.Font.Gotham
    input.TextSize = 14
    input.BackgroundColor3 = theme.Surface
    input.BorderSizePixel = 0
    input.Position = UDim2.fromOffset(12, 12)
    input.Size = UDim2.new(1, -24, 0, 42)
    input.Parent = overlay
    local list = Instance.new("ScrollingFrame")
    list.BackgroundTransparency = 1
    list.BorderSizePixel = 0
    list.Position = UDim2.fromOffset(12, 66)
    list.Size = UDim2.new(1, -24, 1, -78)
    list.AutomaticCanvasSize = Enum.AutomaticSize.Y
    list.CanvasSize = UDim2.new()
    list.ScrollBarThickness = 2
    list.Parent = overlay
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 4)
    layout.Parent = list

    local self = Component.new(overlay, theme, animations)
    setmetatable(self, Command)
    self._input = input
    self._list = list
    self._commands = commands or {}
    self._root = root
    self._render = function()
        for _, child in ipairs(list:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        local query = input.Text:lower()
        for _, item in ipairs(self._commands) do
            if query == "" or item.Label:lower():find(query, 1, true) then
                local button = Instance.new("TextButton")
                button.BackgroundColor3 = theme.SurfaceSecondary
                button.BorderSizePixel = 0
                button.Size = UDim2.new(1, 0, 0, 34)
                button.Font = Enum.Font.Gotham
                button.Text = item.Label
                button.TextColor3 = theme.TextSecondary
                button.TextSize = 12
                button.TextXAlignment = Enum.TextXAlignment.Left
                button.Parent = list
                local p = Instance.new("UIPadding")
                p.PaddingLeft = UDim.new(0, 12)
                p.Parent = button
                button.Activated:Connect(function()
                    item.OnSelect()
                    self:Close()
                end)
            end
        end
    end
    self.Maid:Give(input:GetPropertyChangedSignal("Text"):Connect(self._render))
    self.Maid:Give(UserInputService.InputBegan:Connect(function(inputObject, processed)
        if processed then return end
        if inputObject.KeyCode == Enum.KeyCode.P then
            self:Toggle()
        elseif inputObject.KeyCode == Enum.KeyCode.Escape then
            self:Close()
        end
    end))
    maid:Give(self)
    self._render()
    return self
end

function Command:Toggle()
    if self.Instance.Visible then self:Close() else self:Open() end
end

function Command:Open()
    self.Instance.Visible = true
    self._input:CaptureFocus()
end

function Command:Close()
    self.Instance.Visible = false
    self._input:ReleaseFocus()
end

return Command
