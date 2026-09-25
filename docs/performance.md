# Performance and cleanup

Nebula is event-driven. Viewport changes, input changes, and state changes update the UI only when their source changes. Animations are tracked and cancelled through the owning `Maid`.

## Cleanup

```lua
app:Destroy()
```

This disconnects signals, cancels active tweens, destroys component instances, and removes render roots.

## Reduced motion

`app:SetReducedMotion(true)` removes tween work while preserving the final visual state. This is useful for accessibility and lower-power devices.

## Diagnostics

```lua
local report = app:GetDiagnostics()
-- ComponentCount, RenderMode, Viewport, Breakpoint, ActiveAnimations
```
