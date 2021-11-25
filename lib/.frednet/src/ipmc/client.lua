--#import "../util.lua"

function ipmc_handle_packet(packet, side, dist)
    if packet.dst_addr == ip2num(settings.get("frednet.ip")) then
        os.queueEvent("frednet_message", packet.src_addr, packet.src_port, packet.dst_port, packet.data)
    else
        os.queueEvent("routed_ipmc_packet", packet.src_addr, packet.src_port, packet.dst_addr, packet.dst_port, packet.data)
    end
end