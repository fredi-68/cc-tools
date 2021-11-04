--#import "/lib/shared/cls.lua"
--#import "../client.lua"

RTPClient = make_class()

function RTPClient.init(self, host, port)
    self.host = ip2num(host)
    self.port = port
end

function RTPClient.get_resource(self, path, data)
    transmit(self.host, self.port, 1, {path = path, data = data})
    local event, src_addr, src_port, dst_port, p = os.pullEvent("frednet_message")
    assert(p.error ~= nil, "Invalid response")
    if p.error == 0 then
        return p.data
    else
        assert(false, "Error: " .. p.error .. ", Reason: " .. tostring(p.data))
    end
end