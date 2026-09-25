-- Nebula LIB single-file loadstring smoke test.
-- Paste into the controlled runtime that provides game:HttpGet, loadstring,
-- and (for automatic clipboard copy) setclipboard or toclipboard.

local SOURCE_URL = "https://raw.githubusercontent.com/famefashion/nebula-lib/main/src/Nebula.lua"
local app

local function formatError(err)
    if debug and type(debug.traceback) == "function" then
        return debug.traceback(tostring(err), 2)
    end
    return tostring(err)
end

local function copyError(text)
    if type(setclipboard) == "function" then
        local ok = pcall(setclipboard, text)
        if ok then
            return true
        end
    end
    if type(toclipboard) == "function" then
        local ok = pcall(toclipboard, text)
        if ok then
            return true
        end
    end
    return false
end

local function runSmokeTest()
    assert(type(loadstring) == "function", "This runtime does not expose loadstring")
    assert(game and type(game.HttpGet) == "function", "This runtime does not expose game:HttpGet")

    local source = game:HttpGet(SOURCE_URL)
    assert(type(source) == "string" and #source > 0, "Nebula download returned no source")

    local loader, compileError = loadstring(source, "@Nebula.lua")
    assert(type(loader) == "function", compileError or "loadstring could not compile Nebula.lua")

    local Nebula = loader()
    assert(type(Nebula) == "table", "Nebula.lua did not return a library table")
    assert(type(Nebula.new) == "function", "Nebula.new is missing")

    app = Nebula.new({
        Theme = "Nebula Dark",
        RenderMode = "2D",
        ReducedMotion = true,
        Commands = {
            {
                Label = "Show smoke-test toast",
                OnSelect = function()
                    app:Toast("Command callback reached", "success")
                end,
            },
        },
    })

    app:SetDebug(true)
    app:SetReducedMotion(false)
    for _, method in ipairs({
        "CreateWindow",
        "RegisterTheme",
        "SetTheme",
        "GetTheme",
        "ModifyTheme",
        "ResetTheme",
        "SetRenderMode",
        "SetReducedMotion",
        "SetDebug",
        "GetDiagnostics",
        "Toast",
        "Destroy",
    }) do
        assert(type(app[method]) == "function", "Missing runtime method: " .. method)
    end

    local window = app:CreateWindow({
        Title = "Nebula Runtime Check",
        Subtitle = "Loadstring · API · controls · motion",
    })
    assert(window:IsAlive(), "Window failed its lifecycle check")

    local dashboard = window:AddTab("Dashboard", "◈")
    dashboard:AddText("Use the controls below to exercise the live UI.")
    local firstSurface = dashboard:AddSurface({
        Title = "Signal controls",
        Size = UDim2.new(1, 0, 0, 220),
    })

    local button = firstSurface:AddButton({
        Label = "Run callback",
        OnClick = function()
            app:Toast("Button callback reached", "success")
        end,
    })
    assert(button:IsAlive(), "Button failed its lifecycle check")

    local toggle = firstSurface:AddToggle({
        Label = "Live signal",
        Default = true,
    })
    local toggleChanged
    local toggleConnection = toggle:OnChanged(function(value)
        toggleChanged = value
    end)
    toggle:Set(false)
    assert(toggle:Get() == false and toggleChanged == false, "Toggle Get/Set/OnChanged failed")
    toggle:Set(true)
    toggleConnection:Disconnect()

    local slider = firstSurface:AddSlider({
        Label = "Signal intensity",
        Range = NumberRange.new(0, 100),
        Default = 40,
        Format = function(value)
            return string.format("%d%%", math.floor(value))
        end,
    })
    local sliderChanged
    local sliderConnection = slider:OnChanged(function(value)
        sliderChanged = value
    end)
    slider:Set(72)
    assert(slider:Get() == 72 and sliderChanged == 72, "Slider Get/Set/OnChanged failed")
    sliderConnection:Disconnect()

    local diagnosticsTab = window:AddTab("Diagnostics", "⌁")
    diagnosticsTab:AddText("Diagnostics and theme methods are active.")
    local secondSurface = diagnosticsTab:AddSurface({
        Title = "Event horizon",
        Size = UDim2.new(1, 0, 0, 120),
    })
    window:SelectTab(diagnosticsTab)
    window:SelectTab(dashboard)

    local defaultTheme = table.clone(app:GetTheme())
    app:RegisterTheme("Smoke Test", defaultTheme)
    app:SetTheme("Smoke Test")
    app:ModifyTheme({ CornerRadius = 12 })
    assert(type(app:GetTheme()) == "table", "Theme methods failed")
    app:ResetTheme()
    app:SetTheme("Graphite")
    app:SetTheme("Nebula Dark")

    app.Animations:Fade(firstSurface.Instance, firstSurface.Instance.BackgroundTransparency, "quick")
    app.Animations:Scale(firstSurface.Instance, 1, "spring")
    app.Animations:Spring(secondSurface.Instance, { Position = secondSurface.Instance.Position })
    app.Animations:Slide(secondSurface.Instance, secondSurface.Instance.Position, "reveal")
    app.Animations:Rotate(secondSurface.Instance, 0, "orbit")
    local playTween = app.Animations:Play(
        window.Instance,
        { Position = window.Instance.Position },
        "quick",
        0.02
    )
    assert(playTween ~= nil, "Animator:Play did not create a Tween")
    local staggered = app.Animations:Stagger(
        { firstSurface.Instance, secondSurface.Instance },
        { BackgroundTransparency = 0.04 },
        "surfaceIn",
        0.04
    )
    assert(type(staggered) == "table", "Animator:Stagger did not return a Tween list")
    assert(type(app.Animations:GetActiveCount()) == "number", "Animation diagnostics failed")
    app:SetReducedMotion(true)
    app.Animations:Stagger(
        { firstSurface.Instance, secondSurface.Instance },
        { BackgroundTransparency = 0.04 },
        "surfaceIn",
        0.04
    )
    app:SetReducedMotion(false)

    app:Toast("Smoke test complete. Click Run callback and press P for commands.", "success", 4)
    app.Commands:Open()
    app.Commands:Close()
    app.Commands:Toggle()
    app.Commands:Close()

    -- Render-mode changes rebuild the root, so exercise this after the visible
    -- controls, toast, and command-palette checks are complete.
    app:SetRenderMode("2D")
    app:Toast("Render mode remained stable", "info", 1)
    local report = app:GetDiagnostics()
    assert(report.RenderMode == "2D", "Render mode diagnostic failed")
    assert(report.ComponentCount >= 1, "Component count diagnostic failed")

    local animator = app.Animations
    app:Destroy()
    assert(animator:GetActiveCount() == 0, "Animator cleanup left active Tweens")
    app:Destroy()
    app = nil
    return "Nebula loaded successfully. API and UI checks passed; click Run callback and press P to try the interactive paths."
end

local ok, result = xpcall(runSmokeTest, formatError)
if not ok then
    local message = "[Nebula loadstring smoke test failed]\n" .. tostring(result)
    warn(message)
    if not copyError(message) then
        warn("Clipboard API unavailable. Copy the error above from the executor console.")
    end
    if app then
        pcall(function()
            app:Destroy()
        end)
    end
    error(message, 0)
end

print("[Nebula loadstring smoke test] " .. tostring(result))