--[[
    Invocation script for fredio applications.

    Automatically creates an event loop, imports the
    given program and runs it in a coroutine.
]]

loop = libfredio.EventLoop()

-- Find executable in path
local executable = nil
local path_entries = string.gmatch(shell.path(), "[^:]+")
for path_entry in path_entries do
    local full_path = path_entry .. "/" .. arg[1]
    if fs.exists(full_path) and not fs.isDir(full_path) then
        executable = full_path
        break
    end
end

local _f = libfredio.async(function (path)
    dofile(path)
end)

loop.task(_f(arg[1]))
loop.run_forever()