--[[
    DHCP client service
]]

self.provides = "dhcp"
self.dependencies = {"frednet"}
self.auto_restart = false

function self.run() 
    local l = libfredio.EventLoop()
    local c = libfrednet.DHCPClient()
    l.run_until_complete(c.run())
end