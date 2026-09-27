-- Nebula LIB render-mode showcase.
-- Run this as a LocalScript in a trusted Roblox experience.
-- The sample starts in a floating 3D mode so the follow, hover, glow,
-- and persistent on-screen mode control are immediately visible.

local Nebula = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/famefashion/nebula-lib/main/dist/Nebula.lua"
))()

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local displayPart = workspace:FindFirstChild("NebulaDisplay")

if not displayPart or not displayPart:IsA("BasePart") then
    displayPart = Instance.new("Part")
    displayPart.Name = "NebulaDisplay"
    displayPart.Parent = workspace
end

displayPart.Anchored = true
displayPart.CanCollide = false
displayPart.CanTouch = false
displayPart.CanQuery = false
displayPart.Size = Vector3.new(16, 10, 0.5)
displayPart.Material = Enum.Material.Neon
displayPart.Color = Color3.fromRGB(35, 82, 150)
displayPart.Transparency = 0.08

displayPart.CFrame = CFrame.new(0, 6, -18)

local App = Nebula.new({
    Parent = playerGui,
    RenderMode = "3D",
    Adornee = displayPart,
    Face = Enum.NormalId.Front,
    CanvasSize = Vector2.new(1000, 700),
    AlwaysOnTop = true,
    Brightness = 2.2,
    Glow = true,
    GlowColor = Color3.fromRGB(90, 170, 255),
    GlowBrightness = 1.5,
    GlowRange = 18,
    FollowLocalPlayer = true,
    FollowDistance = 12,
    FollowHeight = 3.6,
    HoverAmplitude = 0.35,
    HoverSpeed = 1.6,
    Theme = "Midnight",
})

local Window = App:CreateWindow({
    Title = "Nebula Render Lab",
    Subtitle = "Floating 3D interface",
})

local Home = Window:AddTab("Home", "◈")
local panel = Home:AddSurface({ Title = "Try every presentation mode" })
Home:AddText("The panel follows your character, hovers gently, and can switch presentation modes from either toggle.")
panel:AddButton({ Label = "Switch to 2D", OnClick = function() App:SetRenderMode("2D") end })
panel:AddButton({ Label = "Switch to 3D", OnClick = function() App:SetRenderMode("3D", { Adornee = displayPart }) end })
panel:AddButton({ Label = "Switch to Hybrid", OnClick = function() App:SetRenderMode("Hybrid", { Adornee = displayPart }) end })

local Diagnostics = Window:AddTab("Diagnostics", "⌁")
local diagnostics = Diagnostics:AddSurface({ Title = "Runtime status" })
diagnostics:AddButton({
    Label = "Print diagnostics",
    OnClick = function()
        local report = App:GetDiagnostics()
        print("Nebula mode:", report.RenderMode)
        print("Nebula breakpoint:", report.Breakpoint)
        print("Nebula components:", report.ComponentCount)
    end,
})

App:Toast("Floating 3D render mode loaded.", "success")
