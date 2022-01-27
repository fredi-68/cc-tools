--[[
    FredNet management command.
]]

local cmd = arg[1]

if cmd == "address" then
    print("IPMC address: " .. libfrednet.get_local_host_ip())
elseif cmd == "reload" then
    libfrednet.reload_config()
else 
    print(textutils.serialize(libfrednet.get_network_config()))
end
