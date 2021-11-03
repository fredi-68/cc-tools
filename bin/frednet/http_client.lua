--[[
    Example HTTP Client 

    This program implements client side HTTP over RTP/IPMC.
]]

local function application()
    print("Enter the IP of the gateway host: ")
    local host = read()
    -- Create an RTPClient instance linked to our gateway server
    local client = RTPClient(host, 80)
    print("Enter the address of the resource you are trying to reach: ")
    local url = read()
    -- Fetch the HTTP resource synchronously with our RTPClient
    local res = client.get_resource("/get", {url = url})
    print("HTTP Code " .. res.code .. ": " .. res.body)
    -- Disconnect from frednet
    libfrednet.disconnect()
end

-- Connect to frednet and start the event loop
parallel.waitForAny(libfrednet.connect(), application)