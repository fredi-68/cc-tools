--#import "/lib/shared/logging.lua"
--#import "../config.lua"
--#import "packets.lua"

function dhcp_handle_packet(packet, side, dist)
    os.queueEvent("dhcp_packet", packet, side)
end

DHCPClient = make_class()

DHCPClient.logger = Logger("DHCP")

function DHCPClient.init(self, loop)
    self._loop = loop
end

function DHCPClient._send_request_config(self)
    _frednet_send(CHANNEL_DHCP, RequestConfigPacket())
end

function DHCPClient._send_request_address(self)
    _frednet_send(CHANNEL_DHCP, RequestAddressPacket())
end

DHCPClient._wait_for_packet = libfredio.async(function (self, op, timeout)
end)

DHCPClient._run = libfredio.async(function (self)
    while libfrednet.is_connected() do
        -- Do we have a network configuration?
        local config = get_network_config()
        if config ~= nil then
            -- Do we have a valid IP lease?
            local lease = config.dhcp_lease
            if lease ~= nil and lease.ip ~= nil and lease.ip ~= 0 then
                -- We have a valid IP lease, so we can stop here.
                
            else
                -- We don't have a valid IP lease, so we need to request one.
                self.logger.debug("Lease expired, requesting new address...")
                self._send_request_address()
                local p = libfredio.await(self._wait_for_packet(0x4, 0))
                push_network_config({dhcp_lease = {ip = p.ip, exp = p.lease_exp, flags = p.flags}})
                self.logger.info("New address is " .. p.ip)
            end
            -- sleep until our lease expires
            if lease.exp > 0 then
                os.sleep(lease.exp)
            else
                return
            end
        else
            self.logger.info("Obtaining network configuration...")
            self._send_request_config()
            local p = libfredio.await(self._wait_for_packet(0x2, 0))
            push_network_config({netmask = p.net_mask, gateway = p.gateway_addr, dhcp_options = p.dhcp_opts})
            self.logger.info("Got new network configuration: net=" .. p.net_addr .. " mask=" .. p.net_mask .. " gate=" .. p.gateway_addr)
        end
    end
end)