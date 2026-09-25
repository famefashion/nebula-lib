--!strict

local Layout = {}

local function addPadding(parent: Instance, padding: number?)
    if not padding then
        return
    end
    local value = Instance.new("UIPadding")
    value.PaddingTop = UDim.new(0, padding)
    value.PaddingBottom = UDim.new(0, padding)
    value.PaddingLeft = UDim.new(0, padding)
    value.PaddingRight = UDim.new(0, padding)
    value.Parent = parent
end

function Layout.Row(parent: Instance, options: {[string]: any}?)
    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = options and options.Alignment or Enum.HorizontalAlignment.Left
    layout.VerticalAlignment = options and options.VerticalAlignment or Enum.VerticalAlignment.Center
    layout.Padding = UDim.new(0, options and options.Spacing or 8)
    layout.Wraps = options and options.Wrap == true
    layout.Parent = parent
    addPadding(parent, options and options.Padding)
    return layout
end

function Layout.Column(parent: Instance, options: {[string]: any}?)
    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.HorizontalAlignment = options and options.Alignment or Enum.HorizontalAlignment.Left
    layout.VerticalAlignment = options and options.VerticalAlignment or Enum.VerticalAlignment.Top
    layout.Padding = UDim.new(0, options and options.Spacing or 8)
    layout.Parent = parent
    addPadding(parent, options and options.Padding)
    return layout
end

function Layout.Grid(parent: Instance, options: {[string]: any}?)
    local layout = Instance.new("UIGridLayout")
    layout.CellSize = options and options.CellSize or UDim2.fromOffset(160, 100)
    layout.CellPadding = options and options.Spacing or UDim2.fromOffset(8, 8)
    layout.HorizontalAlignment = options and options.Alignment or Enum.HorizontalAlignment.Left
    layout.Parent = parent
    addPadding(parent, options and options.Padding)
    return layout
end

function Layout.Stack(parent: Instance)
    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = parent
    return layout
end

function Layout.Overlay(parent: Instance)
    local container = Instance.new("Frame")
    container.Name = "Overlay"
    container.BackgroundTransparency = 1
    container.Size = UDim2.fromScale(1, 1)
    container.Parent = parent
    return container
end

return Layout
