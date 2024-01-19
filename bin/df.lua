dofile("/lib/shared/cli_tools.lua")
dofile("/lib/shared/human_readable.lua")
dofile("/lib/shared/better_tabulate.lua")

parser = ArgumentParser("df", "report file system space usage")
parser.add_flag("human_readable", "h")
parser.parse()

-- https://tweaked.cc/module/fs.html#v:isDriveRoot suggests that it is
-- possible to programatically add mount points from user programs.
-- However, I have not been able to identify any way of actually
-- achieving this. As such, I will hardcode the paths here, since
-- there also appears to be no way of getting a list of all current
-- mounts.
local MOUNTS = {
    "/"
}
for i, p in ipairs(fs.list("/")) do
    if fs.isDriveRoot(p) then
        table.insert(MOUNTS, p)
    end
end

local rows = {
    { "FS", "Size", "Used", "Avail", "Use%" }
}

for i, p in ipairs(MOUNTS) do
    local size = fs.getCapacity(p) or 0
    local avail = fs.getFreeSpace(p)
    local used = size - avail
    local use_p = tostring(math.floor((used / size) * 100))
    if parser.args.human_readable then
        size = hr_size(size)
        avail = hr_size(avail)
        used = hr_size(used)
    else
        size = tostring(size)
        avail = tostring(avail)
        used = tostring(used)
    end
    table.insert(rows, {p, size, used, avail, use_p .. "%"})
end

tabulate(table.unpack(rows))