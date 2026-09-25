# Layouts

The internal layout helpers build on Roblox layout instances rather than fixed coordinates:

- `Layout.Row(parent, { Spacing, Padding, Wrap })`
- `Layout.Column(parent, { Spacing, Padding })`
- `Layout.Grid(parent, { CellSize, Spacing, Padding })`
- `Layout.Stack(parent)`
- `Layout.Overlay(parent)`

Application code normally consumes these through components. Use them directly when building a custom component inside the library.
