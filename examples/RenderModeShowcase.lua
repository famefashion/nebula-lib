-- Nebula LIB render-mode showcase.
-- Run this as a LocalScript in a trusted Roblox experience.
-- It demonstrates the built-in 2D / 3D / Hybrid selector and the public API.

local Nebula = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/famefashion/nebula-lib/main/dist/Nebula.lua"
))()

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local displayPart = workspace:FindFirstChild("NebulaDisplay")

if not displayPart then
    displayPart = Instance.new("Part")
    displayPart.Name = "NebulaDisplay"
    displayPart.Anchored = true
    displayPart.CanCollide = false
    displayPart.Size = Vector3.new(14, 8, 0.5)
    displayPart.Color = Color3.fromRGB(18, 24, 40)
    displayPart.CFrame = CFrame.new(0, 6, -18)
    displayPart.Parent = workspace
end

local App = Nebula.new({
    Parent = playerGui,
    RenderMode = "2D",
    Adornee = displayPart,
    Face = Enum.NormalId.Front,
    PixelsPerStud = 55,
    Theme = "Midnight",
})

local Window = App:CreateWindow({
    Title = "Nebula Render Lab",
    Subtitle = "2D, 3D, and Hybrid in one runtime",
})

local Home = Window:AddTab("Home", "◈")
local panel = Home:AddSurface({ Title = "Try every presentation mode" })
Home:AddText("Use UI Settings to switch modes without recreating the window. The panel will orbit away when leaving a 3D mode.")
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

App:Toast("Render mode showcase loaded.", "success")
