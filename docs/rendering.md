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

Every window automatically receives a `UI Settings` tab with three mode buttons: **2D**, **3D**, and **Hybrid**. When `Nebula.new` was given an `Adornee` BasePart, selecting 3D or Hybrid animates the current surface away, rebuilds the root in place, and preserves the existing window and tabs. Selecting a non-2D mode without an `Adornee` shows a warning instead of breaking the UI.
