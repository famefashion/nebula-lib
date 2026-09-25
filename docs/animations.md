# Animations

Nebula's shared animator gives windows, tabs, controls, and custom surfaces the same
motion language. Every animation can be interrupted safely by a newer animation on
the same instance.

## Motion primitives

```lua
local surface = dashboard:AddSurface({
    Title = "Event horizon",
    Size = UDim2.new(1, 0, 0, 160),
})

local motion = app.Animations
motion:Fade(surface.Instance, 0.08, "control")
motion:Scale(surface.Instance, 1.02, "spring")
motion:Slide(surface.Instance, UDim2.fromOffset(8, 0), "reveal")
motion:Rotate(surface.Instance, 0, "orbit")
motion:Spring(surface.Instance, {
    Position = UDim2.fromOffset(12, 0),
})
```

`Play(instance, properties, preset?, delayTime?)` is the general-purpose entry point.
`Fade`, `Scale`, `Slide`, and `Rotate` are focused helpers. `Spring` selects the
spring preset. Supported presets are `surfaceIn`, `control`, `spring`, `quick`,
`reveal`, and `orbit`.

## Stagger a constellation of surfaces

Pass multiple GUI instances and one shared target property table. The interval is
the delay between each instance's start time.

```lua
motion:Stagger(
    { firstSurface.Instance, secondSurface.Instance, thirdSurface.Instance },
    { BackgroundTransparency = 0.06 },
    "surfaceIn",
    0.07
)
```

`Stagger` returns the Tweens it started. `GetActiveCount()` reports currently
tracked Tweens. `app:SetReducedMotion(true)` skips all delays and applies targets
immediately; switch it back off to restore motion.

## Lifecycle

Use `app:Destroy()` when the feature is unloaded. Nebula cancels active Tweens and
disconnects its completion listeners during cleanup. Custom animation targets must
still be live Roblox Instances when they are passed to the animator.
