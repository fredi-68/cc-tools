--[[
    Provides DNS server
]]

function self.run()
    local server = libfrednet.DNSServer(".dns_records")
    server.start()
end