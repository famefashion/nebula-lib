# Animations

Use the centralized animator through `app.Animations`.

```lua
app.Animations:Fade(instance, 0.2)
app.Animations:Scale(instance, 1.02)
app.Animations:Spring(instance, {
    Position = UDim2.fromOffset(24, 24),
})
```

The animator cancels an active tween on the same instance before starting a new one. `app:SetReducedMotion(true)` applies target properties immediately.
