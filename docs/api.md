# API reference

## `Nebula.new(options?)`

Creates an app runtime.

| Option | Type | Default |
| --- | --- | --- |
| `Parent` | `Instance` | local player's PlayerGui |
| `RenderMode` | `"2D" | "3D" | "Hybrid"` | `"2D"` |
| `Adornee` | `BasePart` | required for 3D/Hybrid |
| `Theme` | `string` | `"Nebula Dark"` |
| `ReducedMotion` | `boolean` | `false` |
| `Commands` | `{ { Label, OnSelect } }` | `{}` |

## Runtime methods

- `CreateWindow(options?)` → Window
- `RegisterTheme(name, theme)` → `nil`
- `SetTheme(name)` → `nil`
- `GetTheme()` → theme table
- `ModifyTheme(changes)` → `nil`
- `ResetTheme()` → `nil`
- `SetRenderMode(mode, options?)` → `nil`
- `SetReducedMotion(enabled)` → `nil`
- `SetDebug(enabled)` → `nil`
- `GetDiagnostics()` → diagnostics table
- `Toast(message, kind?, duration?)` → toast instance
- `Destroy()` → `nil`

## Animations

`app.Animations` is the shared, interruptible animation service:

- `Play(instance, properties, preset?, delayTime?)` → Tween or `nil`
- `Fade(instance, transparency, preset?)` → Tween or `nil`
- `Scale(guiObject, scale, preset?)` → Tween or `nil`
- `Spring(instance, properties)` → Tween or `nil`
- `Slide(guiObject, position, preset?)` → Tween or `nil`
- `Rotate(guiObject, rotation, preset?)` → Tween or `nil`
- `Stagger(instances, properties, preset?, interval?)` → list of Tweens
- `GetActiveCount()` → number of active Tweens
- `SetReducedMotion(enabled)` and `Destroy()`

Built-in presets: `surfaceIn`, `control`, `spring`, `quick`, `reveal`, and `orbit`.
`Stagger` uses a per-item delay; reduced-motion mode applies every target immediately.

## Window and tab methods

- `CreateWindow({ Title, Subtitle })`
- `window:AddTab(name, icon?)` → Tab
- `window:SelectTab(tab)` → `nil`
- `tab:AddSurface({ Title, Size, LayoutOrder })` → Surface
- `tab:AddText(text, options?)` → TextLabel

See [components](components.md) for the control constructors.
