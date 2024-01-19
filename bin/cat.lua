--[[
    Command line utility for reading files
]]

local file = arg[1]

if file == nil then
    error("Usage: cat <file>")
end
file = shell.resolve(file)
if not fs.exists(file) then
    error("cat: no such file: " .. file)
end

print(fs.open(file, "r").readAll())