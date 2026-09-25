--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Nebula = require(ReplicatedStorage.Packages.Nebula)

local app
app = Nebula.new({
    Title = "Nebula Showcase",
    Theme = "Nebula Dark",
    RenderMode = "2D",
    Commands = {
        { Label = "Show success toast", OnSelect = function() app:Toast("Command executed", "success") end },
        { Label = "Switch to Aurora", OnSelect = function() app:SetTheme("Aurora") end },
        { Label = "Enable reduced motion", OnSelect = function() app:SetReducedMotion(true) end },
    },
})

local window = app:CreateWindow({
    Title = "Nebula Showcase",
    Subtitle = "A working tour of the runtime",
})

local dashboard = window:AddTab("Dashboard", "◈")
dashboard:AddText("A responsive surface for controls, state, and motion.")
local telemetry = dashboard:AddSurface({ Title = "Telemetry", Size = UDim2.new(1, 0, 0, 190) })
telemetry:AddToggle({
    Label = "Live signal",
    Default = true,
    OnChanged = function(value)
        app:Toast(value and "Live signal connected" or "Live signal paused", value and "success" or "warning")
    end,
})
telemetry:AddSlider({
    Label = "Signal intensity",
    Min = 0,
    Max = 100,
    Default = 64,
    OnChanged = function(value)
        if value > 90 then
            app:Toast("High intensity", "warning", 1.5)
        end
    end,
})
telemetry:AddButton({
    Label = "Run system check",
    OnClick = function()
        app:Toast("All systems nominal", "success")
    end,
})

local themes = window:AddTab("Themes", "✦")
themes:AddText("Theme changes are applied through the shared manager.")
local themeSurface = themes:AddSurface({ Title = "Presets", Size = UDim2.new(1, 0, 0, 180) })
for _, themeName in ipairs({ "Nebula Dark", "Aurora", "Midnight", "Graphite" }) do
    themeSurface:AddButton({
        Label = "Use " .. themeName,
        OnClick = function()
            app:SetTheme(themeName)
            app:Toast(themeName .. " active", "info")
        end,
    })
end

local diagnostics = window:AddTab("Diagnostics", "⌁")
diagnostics:AddText("Press P to open the command palette. Enable debug data in your own surface with GetDiagnostics().")
diagnostics:AddButton({
    Label = "Show breakpoint",
    OnClick = function()
        local report = app:GetDiagnostics()
        app:Toast(report.Breakpoint .. " viewport", "info")
    end,
})
