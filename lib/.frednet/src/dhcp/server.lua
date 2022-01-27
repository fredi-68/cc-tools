--#import "/lib/shared/cls.lua"
--#import "/lib/shared/logging.lua"
--#import "../const.lua"
--#import "packets.lua"

DHCPServer = make_class()

DHCPServer.logger = Logger("DHCP")

function DHCPServer.init(self, side, network, netmask, range, gateway, dns, lease_time, options)
    self.leases = {}
    self.lease_map = {}

    self.side = side
    self.network = ip2num(network)
    self.netmask = ip2num(netmask)
    self.range = range
    self.gateway = ip2num(gateway)
    self.dns = ip2num(dns)
    self.lease_time = lease_time
    self.options = options
end

function DHCPServer._send_config(self, packet)
    packet = RespondConfigPacket(packet.host_id, self.network, self.netmask, nil, self.gateway, self.options)
    _frednet_send(CHANNEL_DHCP, packet, self.side)
end

function DHCPServer._send_address(self, packet)
    local host_id = packet.host_id
    local lease = self.lease_map[host_id]
    if lease == nil then
        -- this host has not been assigned an IP lease yet, generate a new one
        local i = #self.leases
        if i > self.range then
            -- we have exhausted our address space
            self.logger.error("Address space exhausted, cannot comply with client lease request.")
            return
        end
        lease = {
            addr = self.network + i,
            exp = os.time() + self.lease_time
        }
        self.leases[i+1] = lease
        self.lease_map[host_id] = lease
    end
    packet = RespondAddressPacket(host_id, lease.addr, lease.exp, {})
    _frednet_send(CHANNEL_DHCP, packet, self.side)
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