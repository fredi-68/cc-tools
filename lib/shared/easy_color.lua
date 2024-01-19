--[[
    Easily use text colors on supporting devices
]]

local BG = 0x10000
local MASK = 0xffff

function bg(col)
    return bit.bor(col, BG)
end

function write_color(...)
    if not term.isColor() then
        for i, v in ipairs(table.pack(...)) do
            if not (type(v) == "number") then
                write(v)
            end
        end
        return
    end
    local old_bg = term.getBackgroundColor()
    local old_fg = term.getTextColor()
    for i, v in ipairs(table.pack(...)) do
        if type(v) == "number" then
            if bit.band(v, BG) > 0 then
                term.setBackgroundColor(bit.band(v, MASK))
            else
                term.setTextColor(bit.band(v))
            end
        else
            write(v)
        end
    end
    term.setBackgroundColor(old_bg)
    term.setTextColor(old_fg)
end