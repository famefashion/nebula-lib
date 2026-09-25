# Components

## Window and tabs

`app:CreateWindow({ Title, Subtitle })` creates a movable application surface. `window:AddTab(name, icon)` creates a navigation item and returns a tab.

## Surfaces

`tab:AddSurface({ Title, Size, LayoutOrder })` creates a themed content surface. Surfaces expose:

- `AddButton({ Label, OnClick })`
- `AddToggle({ Label, Default, OnChanged })`
- `AddSlider({ Label, Min, Max, Default, Format, OnChanged })`

## Command palette

Pass command definitions when creating the app:

```lua
local app = Nebula.new({
    Commands = {
        { Label = "Refresh", OnSelect = refresh },
    },
})
```

Press `P` to open the palette and `Escape` to close it.

## Toasts

`app:Toast(message, kind, duration)` supports `success`, `warning`, `error`, and `info`.
