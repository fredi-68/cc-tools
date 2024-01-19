loop = libfredio.EventLoop()
if arg[1] == nil then
    error("Usage: dig <hostname>")
end

do_lookup = libfredio.async(function () 
    local ok, result = pcall(libfrednet.resolve_hostname, arg[1])
    if not ok then
        print("Error: " .. result)
    else
        print("Host " .. arg[1] .. " is at " .. result)
    end
end)

loop.run_until_complete(do_lookup())
