--!strict

local Responsive = {}

function Responsive.GetBreakpoint(width: number): string
    if width < 640 then
        return "Compact"
    elseif width < 1024 then
        return "Regular"
    end
    return "Wide"
end

function Responsive.TouchTarget(compact: boolean): number
    return compact and 48 or 40
end

return Responsive
