--[[
    FredNet management command.
]]

local cmd = arg[1]

if cmd == "address" then
    print("IPMC address: " .. libfrednet.get_local_host_ip())
elseif cmd == "reload" then
    libfrednet.reload_config()
elseif cmd == "dhcp" then
    if arg[2] == "release" then
        libfrednet.push_network_config({dhcp_lease = {}})
        libfrednet.save_config()
    elseif arg[2] == "renew" then
        shell.run("systemctl start /etc/services/frednet/dhcp.lua")
    else
        print("Usage: frednet dhcp [release|renew]")
    end
else 
    print(textutils.serialize(libfrednet.get_network_config()))
end
