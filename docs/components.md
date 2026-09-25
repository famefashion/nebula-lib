# Components

## Window and tabs

`app:CreateWindow({ Title, Subtitle })` creates a movable application surface. `window:AddTab(name, icon)` creates a navigation item and returns a tab.

## Surfaces

`tab:AddSurface({ Title, Size, LayoutOrder })` creates a themed content surface. Surfaces expose:

- `AddButton({ Label, OnClick })`
- `AddToggle({ Label, Default, OnChanged })`
- `AddSlider({ Label, Min, Max, Range, Default, Format, OnChanged })`

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

## Motion and loadstring entry point

Windows reveal on creation, the selected tab settles into place, and buttons respond
with a short scale lift. For custom motion, use [`app.Animations`](animations.md).
The generated [`src/Nebula.lua`](../src/Nebula.lua) file is a standalone loadstring
package, so it can be fetched without a ModuleScript or the source module tree.
