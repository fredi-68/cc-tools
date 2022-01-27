--[[
    Provides DNS server
]]

self.provides = "dns"
self.dependencies = {"frednet"}

function self.run()
    local server = libfrednet.DNSServer(".dns_records")
    server.start()
end