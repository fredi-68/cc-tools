--[[
    Example HTTP Client 

    This program implements client side HTTP over RTP/IPMC.
]]

loop = libfredio.EventLoop()

local function application()
    print("Enter the IP of the gateway host: ")
    local host = read()
    -- Create an RTPClient instance linked to our gateway server
    local client = libfrednet.RTPClient(host, 80)
    print("Enter the address of the resource you are trying to reach: ")
    local url = read()
    -- Fetch the HTTP resource synchronously with our RTPClient
    local res = client.get_resource("/get", {url = url})
    print("HTTP Code " .. res.status_code .. ": " .. res.body)
    -- Disconnect from frednet
    libfrednet.disconnect()
end

-- Connect to frednet and start the event loop
loop.task(libfrednet.connect())
loop.run_until_complete(coroutine.create(application))