--#import "/lib/shared/cls.lua"
--#import "../dns/client.lua"
--#import "../client.lua"

RTPClient = make_class()

function RTPClient.init(self, host, port)
    self.host = host
    self.port = port
end

--[[
    Fetch a resource from a remote server.
    Waits for a response and then returns the data.
]]
function RTPClient.get_resource(self, path, data)
    transmit(self.host, self.port, 1, {path = path, data = data})
    local event, packet
    local timeout = os.startTimer(5)
    while true do
        event, packet = os.pullEvent()
        if event == "timer" and packet == timeout then
            error("Request timed out.")
        elseif event == "frednet_message" and packet.dst_port == 1 then
            break
        end
    end
    assert(packet.data.error ~= nil, "Invalid response")
    if packet.data.error == 0 then
        return packet.data.data
    else
        assert(false, "Error: " .. packet.data.error .. ", Reason: " .. tostring(packet.data.data))
    end
end

--[[
    Send a message to a remote server.
    Does NOT wait for a response.
]]
function RTPClient.send_message(self, path, data)
    transmit(self.host, self.port, 1, {path = path, data = data})
end