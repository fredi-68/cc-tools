dofile("/lib/shared/logging.lua")

set_log_level(INFO)

local function log_packet (logger, packet, dest)
    logger.info("[FROM " .. libfrednet.num2ip(packet.src_addr) .. ":" .. packet.src_port .. "][VIA " .. packet.hops .. "][TO " .. dest .. ":" .. packet.dst_port .."]: " .. tostring(packet.data))
end

local _loop = libfredio.EventLoop()

local display_ip_packets = function ()
    local logger = Logger("IPMC")
    while libfrednet.is_connected() do
        local event = table.pack(os.pullEvent())
        local packet = event[2]
        if event[1] == "frednet_message" then
            log_packet(logger, packet, "localhost")
        elseif event[1] == "routed_ipmc_packet" then
            log_packet(logger, packet, libfrednet.num2ip(packet.dst_addr))
        end
        
    end
end

_loop.run_until_complete(coroutine.create(display_ip_packets))