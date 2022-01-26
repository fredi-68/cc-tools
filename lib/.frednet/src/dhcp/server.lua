--#import "/lib/shared/cls.lua"
--#import "/lib/shared/logging.lua"
--#import "../const.lua"
--#import "packets.lua"

DHCPServer = make_class()

DHCPServer.logger = Logger("DHCP")

function DHCPServer.init(self, side, network, netmask, range, gateway, dns, lease_time, options)
    self.leases = {}

    self.side = side
    self.network = network
    self.netmask = netmask
    self.range = range
    self.gateway = gateway
    self.dns = dns
    self.lease_time = lease_time
    self.options = options
end

function DHCPServer._send_config(self, packet)
end

function DHCPServer._send_address(self, packet)
end

DHCPServer._packet_handler = libfredio.async(function(self)
    while libfrednet.is_connected() do
        local event, packet, side = os.pullEvent("dhcp_packet")
        if side == self.side then
            if packet.op == 0x1 then
                self._send_config(packet)
            elseif packet.op == 0x3 then
                self._send_address(packet)
            end -- ignore other packets as they are only interesting for clients
        end
    end
end)

function DHCPServer.start(self)
    local loop = libfredio.EventLoop()
    loop.task(self._packet_handler())
    loop.run_forever()
end