--!strict

local Responsive = {}

function Responsive.GetBreakpoint(width: number): string
    if width < 600 then
        return "Compact"
    elseif width < 1100 then
        return "Regular"
    end
    return "Wide"
end

function Responsive.TouchTarget(compact: boolean): number
    return compact and 44 or 36
end

return Responsive
