--[[
    Interactive rtp client.

    Useful for API exploration during development.
]]

dofile("/lib/shared/cli_tools.lua")

parser = ArgumentParser("rtp", "simple RTP client")
parser.add_flag("port", "p", STORE)
parser.parse()

if parser.args.port == nil then
    parser.args.port = 80
else
    parser.args.port = tonumber(parser.args.port)
end

loop = libfredio.EventLoop()

function application()
    print("Please enter the address of the RTP server: ")
    local addr = read()
    print("Connecting to " .. addr .. ":" .. parser.args.port .. "...")
    local client = libfrednet.RTPClient(addr, parser.args.port)
    print("Connected to RTP server at " .. addr .. " . Type resource names to query them from the server or type 'exit' to quit. HINT: Use '/index' to generate a list of available routes on supporting servers.")
    while true do
        io.write(">>> ")
        local cmd = read()
        if cmd == "quit" or cmd == "exit" then
            break
        end
        local success, res = pcall(client.get_resource, cmd)
        if not success then
            print("ERROR: " .. tostring(res))
        else
            if type(res) == "table" then
                print("Result: " .. textutils.serialise(res))
            else
                print("Result: " .. tostring(res))
            end
        end
    end
end

loop.run_until_complete(coroutine.create(application))