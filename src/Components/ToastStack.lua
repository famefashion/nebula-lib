--!strict

local Component = require(script.Parent.Component)

local ToastStack = {}
ToastStack.__index = ToastStack

function ToastStack.new(root: Instance, theme, animations, maid)
    local holder = Instance.new("Frame")
    holder.Name = "NebulaToastStack"
    holder.BackgroundTransparency = 1
    holder.AnchorPoint = Vector2.new(1, 1)
    holder.Position = UDim2.new(1, -24, 1, -24)
    holder.Size = UDim2.fromOffset(300, 240)
    holder.Parent = root
    local layout = Instance.new("UIListLayout")
    layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    layout.Padding = UDim.new(0, 8)
    layout.Parent = holder
    local self = Component.new(holder, theme, animations)
    setmetatable(self, ToastStack)
    maid:Give(self)
    return self
end

function ToastStack:Push(message: string, kind: string?, duration: number?)
    local colors = {
        success = self.Theme.Success,
        warning = self.Theme.Warning,
        error = self.Theme.Error,
        info = self.Theme.Info,
    }
    local toast = Instance.new("TextLabel")
    toast.BackgroundColor3 = self.Theme.Surface
    toast.BackgroundTransparency = self.Theme.Transparency
    toast.BorderSizePixel = 0
    toast.Size = UDim2.fromOffset(280, 42)
    toast.Font = Enum.Font.GothamMedium
    toast.Text = message
    toast.TextColor3 = self.Theme.Text
    toast.TextSize = 12
    toast.TextWrapped = true
    toast.Parent = self.Instance
    local stroke = Instance.new("UIStroke")
    stroke.Color = colors[kind or "info"] or self.Theme.Accent
    stroke.Parent = toast
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 9)
    corner.Parent = toast
    self.Animations:Scale(toast, 1, "spring")
    task.delay(duration or 3.5, function()
        if toast.Parent then
            self.Animations:Fade(toast, 1, "quick")
            task.delay(0.2, function()
                if toast.Parent then toast:Destroy() end
            end)
        end
    end)
    return toast
end

return ToastStack
