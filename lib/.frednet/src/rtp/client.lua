--#import "/lib/shared/cls.lua"
--#import "../client.lua"

RTPClient = make_class()

function RTPClient.init(self, host, port)
    self.host = ip2num(host)
    self.port = port
end

function RTPClient.get_resource(self, path)
    transmit(self.host, self.port, 1, {path = path})
    local event, src_addr, src_port, dst_port, p = os.pullEvent("frednet_message")
    assert(p.error ~= nil, "Invalid response")
    if p.error == 0 then
        return p.data
    else
        assert(true, "Error: " .. p.error .. ", Reason: " .. p.data)
    end
end