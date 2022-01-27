--#import "/lib/shared/cls.lua"
--#import "/lib/shared/logging.lua"
--#import "../const.lua"
--#import "packets.lua"

DHCPServer = make_class()

DHCPServer.logger = Logger("DHCP")

set_log_level(DEBUG)

function DHCPServer.init(self, side, network, netmask, range, gateway, dns, lease_time, options)
    self.leases = {}
    self.lease_map = {}

    self.side = side
    self.network = ip2num(network)
    self.netmask = ip2num(netmask)
    self.range = tonumber(range)
    self.gateway = ip2num(gateway)
    self.dns = ip2num(dns)
    self.lease_time = tonumber(lease_time)
    self.options = options
end

function DHCPServer._send_config(self, packet)
    self.logger.debug("Device " .. packet.host_id .. " requested network configuration")
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
            addr = self.network + i + 1, -- yes that +1 is important, do not remove
            exp = self.lease_time > 0 and os.time() + self.lease_time or 0
        }
        self.leases[i+1] = lease
        self.lease_map[host_id] = lease
    end
    self.logger.debug("Device " .. host_id .. " requested new IP lease " .. num2ip(lease.addr))
    packet = RespondAddressPacket(host_id, lease.addr, lease.exp, {})
    _frednet_send(CHANNEL_DHCP, packet, self.side)
end

DHCPServer._packet_handler = libfredio.async(function(self)
    while libfrednet.is_connected() do
        local event, packet, side = os.pullEvent("dhcp_packet")
        if side == self.side then
            if packet.opcode == 0x1 then
                self._send_config(packet)
            elseif packet.opcode == 0x3 then
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