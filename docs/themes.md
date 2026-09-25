# Themes

The theme manager has named presets and validates custom properties.

```lua
app:RegisterTheme("Ocean", {
    Accent = Color3.fromRGB(80, 190, 255),
    Surface = Color3.fromRGB(22, 32, 48),
})

app:SetTheme("Ocean")
app:ModifyTheme({ CornerRadius = 14 })
app:ResetTheme()
```

Custom themes inherit unspecified values from `Nebula Dark`. Unknown properties raise an error instead of silently doing nothing.
