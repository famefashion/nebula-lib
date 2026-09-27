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

`2D` creates a ScreenGui. `3D` creates a SurfaceGui on the supplied BasePart. `Hybrid` creates a SurfaceGui plus a screen overlay for shared app-level UI. Existing components are migrated to the new root when the mode changes.

Every window automatically receives a `UI Settings` tab. When `Nebula.new` was
given an `Adornee` BasePart, its **Use 3D surface UI** toggle switches between 2D
and 3D without requiring the caller to rebuild the window. Without an `Adornee`,
the setting stays available but explains how to enable 3D safely.
