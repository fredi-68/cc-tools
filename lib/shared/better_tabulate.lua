--[[
    Replacement for `textutils.tabulate()` with support
    for per-column width calculation.

    Currently does not support string coercion or text colors.
]]

function tabulate(...)

    t = table.pack(...)
    w, h = term.getSize()

    cols = {}
    for i, row in ipairs(t) do
        for j, v in ipairs(row) do
            if #v+2 > w then
                l = w
            else
                l = #v+1
            end
            if cols[j] == nil then
                cols[j] = l
            else
                cols[j] = math.max(l, cols[j])
            end
        end
    end

    for i, row in ipairs(t) do
        s = 0
        for j, v in ipairs(row) do
            if #v+2 > w then
                v = v.sub(1, w-4) .. "..."
            end
            s = s + cols[j]
            if s > w then
                print("")
                s = cols[j]
            end
            term.write(v)
            term.write(string.rep(" ", cols[j] - #v))
        end
        print("")
    end
end