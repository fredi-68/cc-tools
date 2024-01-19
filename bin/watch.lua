if #arg < 1 then
    error("Usage: watch <program> [args...]")
end

INTERVAL = 2

command = table.concat(arg, " ")

dispatcher = libfredio.async(function ()
    while true do
        term.clear()
        term.setCursorPos(1, 2)
        shell.execute(table.unpack(arg))
        term.setCursorPos(1, 1)
        term.write("Every " .. tostring(INTERVAL) .. "s:" .. command)
        x, y = term.getSize()
        term.setCursorPos(1, y)
        term.write(os.date("%F %T %z"))
        os.sleep(INTERVAL)
    end
end)

input_loop = libfredio.async(function(loop)
    while true do
        _, key = os.pullEvent("char")
        if key == "q" then
            term.clear()
            term.setCursorPos(1, 1)
            loop.close()
        end
    end
end)

loop = libfredio.EventLoop()
loop.task(dispatcher())
loop.task(input_loop(loop))
loop.run_forever()