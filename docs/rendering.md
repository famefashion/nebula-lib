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

`2D` creates a ScreenGui. `3D` creates a SurfaceGui on the supplied BasePart. `Hybrid` creates a SurfaceGui plus a screen overlay for shared app-level UI. Existing components are not migrated between roots; set the mode before creating windows or rebuild them after switching.
