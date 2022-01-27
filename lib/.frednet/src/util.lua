function log (s) 
    print("[" .. os.time() .. "] " .. s)
end

--[[
    Split a string into several substrings on each occurence of sep.
]]
function string.split(s, sep)
    local a = {}
    local current_index = 1
    while true do
        local new_index = string.find(s, sep, current_index)
        if new_index == nil then
            table.insert(a, string.sub(s, current_index, -1))
            break
        else
            table.insert(a, string.sub(s, current_index, new_index-1))
            current_index = new_index + 1
        end
    end
    return a
end

--[[
    Convert an IP address from a string representation to an integer and return it.
]]
function ip2num(ip)
    local n = 0
    local ok, parts = pcall(string.split, ip, "[.]")
    if not ok then
        error("Invalid value for ip: " .. tostring(parts))
    end
    assert(#parts == 3, "Invalid value for ip: Incorrect amount of separators encountered, expected 2 but got " .. #parts-1)
    for i, v in ipairs(parts) do
        local byte = tonumber(v)
        assert(byte >= 0 and byte <= 255, "Invalid value for ip: " .. v)
        n = bit.bor(byte, bit.blshift(n, 8))
    end
    return n
end

--[[
    Convert an IP address from a numerical representation to a string and return it.
]]
function num2ip(num)
    local parts = {}
    for i=0, 2 do
        table.insert(parts, 1, tostring(bit.band(255, bit.brshift(num, i*8))))
    end
    return table.concat(parts, ".")
end