--[[
    Interactive rtp client.

    Useful for API exploration during development.
]]

function application()
    print("Please enter the address of the RTP server: ")
    local addr = read()
    print("Connecting...")
    local client = libfrednet.RTPClient(addr, 80)
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

parallel.waitForAny(libfrednet.connect(), application)