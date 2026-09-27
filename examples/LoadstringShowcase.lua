-- Nebula LIB loadstring showcase.
-- Zero module packaging: this only downloads the committed single-file bundle.
-- Change the ref to "main" after the branch is merged.

local SOURCE_URL = "https://raw.githubusercontent.com/famefashion/nebula-lib/agent/nebula-loadstring-runtime-20260925/src/Nebula.lua"
local source = game:HttpGet(SOURCE_URL)
local loader, compileError = loadstring(source, "@Nebula.lua")
assert(type(loader) == "function", compileError or "Nebula.lua could not compile")
local Nebula = loader()

local adornee = workspace:FindFirstChild("NebulaDisplay")
if adornee and not adornee:IsA("BasePart") then
    adornee = nil
end

local app
app = Nebula.new({
    Theme = "Midnight",
    RenderMode = "2D",
    Adornee = adornee,
    Commands = {
        { Label = "Show status toast", OnSelect = function() app:Toast("All systems nominal", "success") end },
        { Label = "Use Aurora theme", OnSelect = function() app:SetTheme("Aurora") end },
        { Label = "Reduce motion", OnSelect = function() app:SetReducedMotion(true) end },
    },
})

local window = app:CreateWindow({
    Title = "Nebula",
    Subtitle = "Responsive control surface",
})

local dashboard = window:AddTab("Dashboard", "◈")
dashboard:AddText("A clean, touch-safe showcase built from the single-file loadstring bundle.", { Height = 34 })
local overview = dashboard:AddSurface({ Title = "Overview" })
overview:AddToggle({
    Label = "Live signal",
    Default = true,
    OnChanged = function(value)
        app:Toast(value and "Live signal connected" or "Live signal paused", value and "success" or "warning")
    end,
})
overview:AddSlider({
    Label = "Signal intensity",
    Min = 0,
    Max = 100,
    Default = 68,
    OnChanged = function(value)
        if value > 90 then app:Toast("High intensity", "warning", 1.5) end
    end,
})
overview:AddButton({
    Label = "Run system check",
    Kind = "Primary",
    OnClick = function() app:Toast("All systems nominal", "success") end,
})

local appearance = window:AddTab("Appearance", "✦")
appearance:AddText("Keep the interface calm, readable, and consistent across devices.", { Height = 34 })
local themes = appearance:AddSurface({ Title = "Theme presets" })
for _, themeName in ipairs({ "Midnight", "Nebula Dark", "Aurora", "Graphite" }) do
    themes:AddButton({
        Label = "Use " .. themeName,
        OnClick = function()
            app:SetTheme(themeName)
            app:Toast(themeName .. " active", "info", 2)
        end,
    })
end

local settings = window:AddSettingsTab(app)
local diagnostics = window:AddTab("Diagnostics", "⌁")
diagnostics:AddText("Press P to open the command palette. The mode selector keeps 2D, 3D, and Hybrid explicit.", { Height = 46 })
local reportSurface = diagnostics:AddSurface({ Title = "Runtime" })
reportSurface:AddButton({
    Label = "Show diagnostics",
    OnClick = function()
        local report = app:GetDiagnostics()
        app:Toast(string.format("%s · %s · %s", report.RenderMode, report.Breakpoint, tostring(report.Viewport)), "info", 3)
    end,
})

app:Toast("Nebula showcase loaded", "success", 3)
