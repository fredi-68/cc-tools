--[[
    Invocation script for fredio applications.

    Automatically creates an event loop, imports the
    given program and runs it in a coroutine.
]]

loop = libfredio.EventLoop()

local _f = libfredio.async(function (path)
    dofile(path)
end)

loop.task(_f(arg[1]))
loop.run_forever()