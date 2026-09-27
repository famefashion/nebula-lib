# Responsive behavior

Nebula uses the active camera's viewport width to select:

| Breakpoint | Width | Behavior |
| --- | ---: | --- |
| Compact | `< 640` or touch viewport `< 1100` | Floating mobile card with a touch-sized tab drawer |
| Regular | `640–1023` | Standard window sizing with a vertical navigation rail |
| Wide | `>= 1024` | Larger window with room for navigation and content |

The root listens to camera viewport changes. Touch devices use compact navigation
through tablet widths instead of forcing a desktop sidebar onto a landscape tablet.
Compact windows become a smaller floating card with a compact header and a
hamburger-driven tab drawer; the desktop sidebar is not squeezed into the phone
layout. They use safe margins, stay below Roblox's top inset, and hide the
secondary subtitle to preserve vertical space. Tab buttons are at least 48px high
in compact mode; toggles and sliders also expose larger touch targets and sliders
can be dragged from the full rail instead of only the knob.

This follows the most useful patterns found in public loadstring UI libraries:

- **[WindUI](https://github.com/Footagesus/WindUI)**: explicit window/tab/element
  primitives, touch-friendly controls, and a strong visual hierarchy.
- **[Fluent](https://github.com/LuauExploiter/Fluent-UI-Library)**: cross-platform
  input handling and larger mobile-ready controls.
- **[Rayfield](https://github.com/shlexware/Rayfield)**: clear tab/page navigation
  and familiar toggle/slider affordances.
- **[Orion](https://github.com/OrionLibrary/Orion)**, **[Linoria](https://github.com/violin-suzutsuki/LinoriaLib)**,
  **[Venyx](https://github.com/7GrandDadPGN/Venyx-UI-Library)**, **[Kavo](https://github.com/Kinlei/UILib)**,
  and **[Visual UI Library](https://github.com/VisualRoblox/Roblox)**: useful
  reference points for compact tab navigation, settings surfaces, and simple
  loadstring ergonomics.

There is no canonical registry of every public Roblox loadstring library, so this is
a review of the major public libraries and documented patterns rather than a claim
that every fork or private script hub has been exhaustively enumerated.
