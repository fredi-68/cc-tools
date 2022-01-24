--[[
    Provides DNS server
]]

function self.get()
    local server = libfrednet.DNSServer(".dns_records")
    server.start()
end