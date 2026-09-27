# Rendering

Nebula uses one component API for three presentation modes:

```lua
local app = Nebula.new({ RenderMode = "2D" })
app:SetRenderMode("3D", {
    Adornee = workspace.Terminal.Screen,
    Face = Enum.NormalId.Front,
})
app:SetRenderMode("Hybrid", { Adornee = workspace.Terminal.Screen })
```

`2D` creates a ScreenGui. `3D` creates a SurfaceGui on a supplied BasePart or
creates a physical follow display when no `Adornee` is supplied. `Hybrid` creates
a SurfaceGui plus a screen overlay for shared app-level UI. Existing components
are not migrated between roots; set the mode before creating windows or rebuild
them after switching.

When `RenderMode = "3D"` or `"Hybrid"` has no `Adornee`, Nebula creates a physical
Neon display part that follows the local player's character with a small orbit and
hover motion. A PointLight is attached to that physical part for the gentle glow;
the GUI itself is not used as the glow source.

Every render mode also gets a separate screen-space `NebulaToggleButton`. It stays
available while the 3D display is hidden. Hiding a followed 3D display runs its
close sequence: orbit around the player, rise upward, fade the physical glow, and
disable the surface.

Useful 3D options include `FollowPlayer`, `FollowOffset`, `OrbitRadius`,
`OrbitSpeed`, `HoverSpeed`, `HoverAmplitude`, `PhysicalSize`, `GlowColor`,
`GlowBrightness`, `GlowRange`, `CloseOrbitDuration`, `CloseRiseDuration`, and
`CloseRiseHeight`.
