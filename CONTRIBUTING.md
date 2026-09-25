# Contributing to Nebula LIB

Thanks for helping make Nebula LIB better. The project is intentionally small at its core: changes should be composable, documented, and easy to remove.

## Development setup

1. Install Roblox Studio and a Luau-aware editor.
2. Clone the repository and sync `src/` into a ModuleScript hierarchy with your preferred Rojo workflow.
3. Run the `examples/Showcase.lua` example in a local place.
4. Run the checks in `.github/workflows/validate.yml` locally where possible.

## Source structure

- `src/Nebula.lua` is the public entry point.
- `Core/` owns cleanup and signals.
- `State/`, `Theme/`, `Animation/`, `Rendering/`, and `Layout/` are dependency-light services.
- `Components/` contains user-facing controls and surfaces.
- `examples/` is executable usage documentation.
- `docs/` describes only shipped APIs.

## Coding standards

- Use Luau with `--!strict` in new modules.
- Prefer small modules with one clear responsibility.
- Keep all connections, tweens, and instances owned by a `Maid`.
- Validate public configuration at the boundary and fail with a useful message.
- Never add a documented API that does not have a working implementation.

## Components

Components should expose a small lifecycle-safe API. Interactive values should use `Get`, `Set`, and `OnChanged` where appropriate. Visual behavior belongs in the component, while application logic belongs in the caller.

## Tests and verification

There is no fake test suite. Before opening a pull request, run the repository structure checks and exercise the Showcase example in Roblox Studio across desktop and touch emulation.

## Documentation

Update the relevant document and an example when changing a public method, default, event, or visual behavior.

## Pull requests

- Explain the user-visible change and the implementation boundary.
- Include a short verification list.
- Keep unrelated formatting changes out of the pull request.
- Add a changelog entry for public API changes.

## Commits

Use imperative, focused commit subjects such as `Add responsive command palette` or `Fix toast cleanup`.
