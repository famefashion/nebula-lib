--!strict

local Surface = require(script.Parent.Surface)

local Tab = {}
Tab.__index = Tab

function Tab:AddSurface(options: {[string]: any})
    local surface = Surface.new(self.Page, options or {}, self._window.Theme, self._window.Animations)
    self.Maid:Give(surface)
    return surface
end

function Tab:AddText(text: string, options: {[string]: any}?)
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 0, options and options.Height or 24)
    label.Font = options and options.Font or Enum.Font.Gotham
    label.Text = text
    label.TextColor3 = options and options.Color or self._window.Theme.TextSecondary
    label.TextSize = options and options.TextSize or 13
    label.TextWrapped = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = self.Page
    self.Maid:Give(label)
    return label
end

function Tab:Destroy()
    self.Maid:Destroy()
end

return Tab
