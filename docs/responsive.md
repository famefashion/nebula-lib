# Responsive behavior

Nebula uses the active camera's viewport width to select:

| Breakpoint | Width | Behavior |
| --- | ---: | --- |
| Compact | `< 600` | Window fills the viewport with safe margins |
| Regular | `600–1099` | Standard window sizing |
| Wide | `>= 1100` | Standard window sizing with room for navigation |

The root listens to camera viewport changes. Controls keep a minimum height suitable for mouse and touch input.
