--!strict

local function color(hex: string): Color3
    local value = hex:gsub("#", "")
    return Color3.fromRGB(
        tonumber(value:sub(1, 2), 16) :: number,
        tonumber(value:sub(3, 4), 16) :: number,
        tonumber(value:sub(5, 6), 16) :: number
    )
end

local base = {
    Accent = color("#A995FF"),
    AccentSecondary = color("#5DD5CC"),
    Background = color("#0C1020"),
    BackgroundSecondary = color("#11172B"),
    Surface = color("#171E35"),
    SurfaceSecondary = color("#1D2743"),
    Text = color("#F4F1FF"),
    TextSecondary = color("#B7B9D0"),
    TextMuted = color("#737A9A"),
    Border = color("#303958"),
    BorderHover = color("#6470A0"),
    Success = color("#62D7B5"),
    Warning = color("#F2C977"),
    Error = color("#F47E98"),
    Info = color("#70B6FF"),
    Shadow = color("#050711"),
    CornerRadius = 12,
    BorderThickness = 1,
    Transparency = 0.06,
    Blur = 0,
    AnimationSpeed = 1,
    ControlHeight = 38,
}

local function derive(overrides)
    local result = table.clone(base)
    for key, value in pairs(overrides or {}) do
        result[key] = value
    end
    return result
end

return {
    ["Nebula Dark"] = derive(),
    ["Nebula Light"] = derive({
        Background = color("#EDF1FA"),
        BackgroundSecondary = color("#E2E7F4"),
        Surface = color("#F8F9FD"),
        SurfaceSecondary = color("#E9EDF7"),
        Text = color("#171B2F"),
        TextSecondary = color("#4E5673"),
        TextMuted = color("#7C849F"),
        Border = color("#D4DAEA"),
        BorderHover = color("#9AA6C5"),
        Shadow = color("#8290AC"),
        Transparency = 0,
    }),
    Midnight = derive({ Accent = color("#7397FF"), AccentSecondary = color("#AA7BFF"), Background = color("#070A15") }),
    Graphite = derive({ Accent = color("#D4D9E5"), AccentSecondary = color("#8E9BB5"), Background = color("#101214"), Surface = color("#1D2025") }),
    Aurora = derive({ Accent = color("#6EE7C8"), AccentSecondary = color("#8A8DFF"), Background = color("#0B1520"), Surface = color("#152A35") }),
    Glass = derive({ Accent = color("#8DCAFF"), AccentSecondary = color("#D1B7FF"), Transparency = 0.2, Blur = 8 }),
    Minimal = derive({ Accent = color("#FFFFFF"), AccentSecondary = color("#A7B0C5"), Background = color("#121417"), Surface = color("#1B1E23"), Transparency = 0 }),
}
