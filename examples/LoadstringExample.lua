-- Nebula LIB practical loadstring example.
-- This creates a personal floating status companion for the local player.
-- Run it in a trusted compatible runtime that provides game:HttpGet and loadstring.

local SOURCE_URL = "https://raw.githubusercontent.com/famefashion/nebula-lib/main/dist/Nebula.lua"
local Nebula = loadstring(game:HttpGet(SOURCE_URL))()

local alertDuration = 3
local assistantVisible = true
local app

app = Nebula.new({
    Theme = "Nebula Dark",
    RenderMode = "3D",

    -- With no Adornee, Nebula creates the physical glowing display for you.
    FollowPlayer = true,
    FollowOffset = Vector3.new(0, 3.4, -8),
    OrbitRadius = 2.5,
    OrbitSpeed = 0.28,
    HoverSpeed = 1.1,
    HoverAmplitude = 0.28,
    GlowBrightness = 1.4,
    GlowRange = 16,

    Commands = {
        {
            Label = "Show player status",
            OnSelect = function()
                local player = game:GetService("Players").LocalPlayer
                app:Toast(("Online as %s"):format(player.DisplayName), "success", alertDuration)
            end,
        },
        {
            Label = "Switch to Aurora theme",
            OnSelect = function()
                app:SetTheme("Aurora")
                app:Toast("Aurora theme enabled", "info", alertDuration)
            end,
        },
        {
            Label = "Hide floating companion",
            OnSelect = function()
                assistantVisible = false
                app:SetVisible(false)
                app:Toast("Use the ◉ button to bring it back", "warning", alertDuration)
            end,
        },
    },
})

local window = app:CreateWindow({
    Title = "Player Companion",
    Subtitle = "A floating status panel that follows you",
})

local overview = window:AddTab("Overview", "◈")
overview:AddText("Your personal panel follows the character, hovers in place, and stays available from the screen toggle.")

local status = overview:AddSurface({
    Title = "Quick actions",
    Size = UDim2.new(1, 0, 0, 190),
})

status:AddButton({
    Label = "Show player status",
    OnClick = function()
        local player = game:GetService("Players").LocalPlayer
        app:Toast(("Online as %s"):format(player.DisplayName), "success", alertDuration)
    end,
})

status:AddButton({
    Label = "Restore Nebula defaults",
    OnClick = function()
        app:ResetTheme()
        app:Toast("Nebula Dark theme restored", "info", alertDuration)
    end,
})

local preferences = window:AddTab("Preferences", "✦")
preferences:AddText("Adjust how this example behaves, then reuse the same pattern in your own feature.")

local controls = preferences:AddSurface({
    Title = "Companion controls",
    Size = UDim2.new(1, 0, 0, 220),
})

controls:AddToggle({
    Label = "Show floating companion",
    Default = true,
    OnChanged = function(value)
        assistantVisible = value
        app:SetVisible(value)
        if value then
            app:Toast("Companion visible", "success", alertDuration)
        end
    end,
})

controls:AddToggle({
    Label = "Reduced motion",
    Default = false,
    OnChanged = function(value)
        app:SetReducedMotion(value)
        app:Toast(value and "Reduced motion enabled" or "Full motion enabled", "info", alertDuration)
    end,
})

controls:AddSlider({
    Label = "Toast duration",
    Range = NumberRange.new(1, 8),
    Default = alertDuration,
    Format = function(value)
        return string.format("%ds", math.floor(value))
    end,
    OnChanged = function(value)
        alertDuration = math.floor(value)
    end,
})

local themes = window:AddTab("Themes", "◌")
themes:AddText("Swap the shared theme to match the rest of your script.")

local themeSurface = themes:AddSurface({
    Title = "Built-in themes",
    Size = UDim2.new(1, 0, 0, 210),
})

for _, themeName in ipairs({ "Nebula Dark", "Aurora", "Graphite", "Midnight" }) do
    themeSurface:AddButton({
        Label = "Use " .. themeName,
        OnClick = function()
            app:SetTheme(themeName)
            app:Toast(themeName .. " active", "info", alertDuration)
        end,
    })
end

app:Toast("Player Companion ready. Press P for commands.", "success", 4)
