--#import "../util.lua"
--#import "../config.lua"

function ipmc_handle_packet(packet, side, dist)
    if packet.dst_addr == get_local_host_ip_num() then
        os.queueEvent("frednet_message", packet.src_addr, packet.src_port, packet.dst_port, packet.data)
    else
        os.queueEvent("routed_ipmc_packet", packet.src_addr, packet.src_port, packet.dst_addr, packet.dst_port, packet.data)
    end
end