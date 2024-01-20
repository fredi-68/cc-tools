--#import "../util.lua"
--#import "../config.lua"

function ipmc_handle_packet(packet, side, dist)
    if packet.dst_addr == get_local_host_ip_num() then
        os.queueEvent("frednet_message", packet)
    else
        packet.hops = packet.hops + 1
        os.queueEvent("routed_ipmc_packet", packet)
    end
end