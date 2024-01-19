function hr_size(size)
    local suffix = ""
    if size >= 1000 then
        suffix = "K"
        size = size / 1000
    end
    if size >= 1000 then
        suffix = "M"
        size = size / 1000
    end
    if size >= 1000 then
        suffix = "G"
        size = size / 1000
    end
    if size >= 1000 then
        suffix = "T"
        size = size / 1000
    end
    return tostring(math.floor(size)) .. suffix
end