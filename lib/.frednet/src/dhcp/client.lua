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
    if timeout > 0 then
        local timeout = os.startTimer(timeout)
    end
    while true do
        local event, msg, side = os.pullEvent()
        if event == "dhcp_packet" then
            if msg.opcode == op then
                return msg
            end
        elseif event == "timeout" then
            return nil
        end
    end

end)

DHCPClient.run = libfredio.async(function (self)
    while libfrednet.is_connected() do
        -- Do we have a network configuration?
        local config = get_network_config()
        if next(config) then
            -- Do we have a valid IP lease?
            local lease = config.dhcp_lease
            if lease ~= nil and lease.ip ~= nil and lease.ip ~= 0 then
                -- We have a valid IP lease, so we can stop here.
                
            else
                -- We don't have a valid IP lease, so we need to request one.
                self.logger.debug("Lease expired, requesting new address...")
                self._send_request_address()
                local p = libfredio.await(self._wait_for_packet(0x4, 5))
                local ip = num2ip(p.addr)
                lease = {ip = ip, exp = p.lease_exp, flags = p.flags}
                push_network_config({dhcp_lease = lease})
                save_config()
                self.logger.info("New address is " .. ip)
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
            local p = libfredio.await(self._wait_for_packet(0x2, 5))
            local c = {
                netmask = num2ip(p.net_mask), 
                gateway = num2ip(p.gateway_addr), 
                dhcp_options = p.dhcp_opts,
                network = num2ip(p.net_addr),
                dns_server = num2ip(p.dns_addr),
            }
            push_network_config(c)
            save_config()
            self.logger.info("Got new network configuration: net=" .. c.network .. " mask=" .. c.netmask .. " gate=" .. c.gateway)
        end
    end
end)