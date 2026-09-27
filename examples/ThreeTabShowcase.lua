-- Nebula LIB three-tab loadstring example.
-- Run this in a trusted runtime that provides game:HttpGet and loadstring.

local Nebula = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/famefashion/nebula-lib/main/dist/Nebula.lua"
))()

local Players = game:GetService("Players")
local displayPart = workspace:FindFirstChild("NebulaDisplay")
local App = Nebula.new({
    Parent = Players.LocalPlayer:WaitForChild("PlayerGui"),
    RenderMode = "2D",
    -- Optional: provide a BasePart to enable the built-in 2D/3D switch.
    Adornee = displayPart,
    Theme = "Nebula Dark",
})

local Window = App:CreateWindow({
    Title = "Nebula Showcase",
    Subtitle = "Standalone three-tab bundle",
})

local Overview = Window:AddTab("Overview", "◈")
local OverviewSurface = Overview:AddSurface({
    Title = "Welcome",
})
Overview:AddText("This window is running entirely from dist/Nebula.lua.")
OverviewSurface:AddButton({
    Label = "Show toast",
    OnClick = function()
        App:Toast("The standalone bundle is working.", "success")
    end,
})

local Controls = Window:AddTab("Controls", "✦")
local ControlsSurface = Controls:AddSurface({
    Title = "Interactive controls",
})
local Notifications = ControlsSurface:AddToggle({
    Label = "Enable notifications",
    Default = true,
})
Notifications:OnChanged(function(enabled)
    App:Toast(enabled and "Notifications enabled" or "Notifications disabled", "info")
end)

local Intensity = ControlsSurface:AddSlider({
    Label = "Intensity",
    Range = NumberRange.new(0, 100),
    Default = 60,
    Format = function(value)
        return string.format("%d%%", math.floor(value))
    end,
})
Intensity:OnChanged(function(value)
    print("Nebula intensity:", value)
end)

local Diagnostics = Window:AddTab("Diagnostics", "⌁")
local DiagnosticsSurface = Diagnostics:AddSurface({
    Title = "Runtime status",
})
Diagnostics:AddText("Use this tab to inspect the current runtime state.")
DiagnosticsSurface:AddButton({
    Label = "Print diagnostics",
    OnClick = function()
        local report = App:GetDiagnostics()
        print("Nebula version:", Nebula.VERSION)
        print("Render mode:", report.RenderMode)
        print("Components:", report.ComponentCount)
        print("Breakpoint:", report.Breakpoint)
    end,
})

App:Toast("Nebula Showcase loaded with three tabs.", "success")

-- Call App:Destroy() when the owning feature is unloaded.