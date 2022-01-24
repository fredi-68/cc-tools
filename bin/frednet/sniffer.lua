dofile("/lib/shared/logging.lua")

set_log_level(INFO)

local _loop = libfredio.EventLoop()

local display_ip_packets = function ()
    local logger = Logger("IPMC")
    while libfrednet.is_connected() do
        local event = table.pack(os.pullEvent())
        local src_addr, src_port, dst_addr, dst_port, msg
        if event[1] == "frednet_message" then
            _, src_addr, src_port, dst_port, msg = table.unpack(event)
            logger.info("[FROM " .. libfrednet.num2ip(src_addr) .. ":" .. src_port .. "][TO localhost:" .. dst_port .."]: " .. tostring(msg))
        elseif event[1] == "routed_ipmc_packet" then
            _, src_addr, src_port, dst_addr, dst_port, msg = table.unpack(event)
            logger.info("[FROM " .. libfrednet.num2ip(src_addr) .. ":" .. src_port .. "][TO " .. libfrednet.num2ip(dst_addr) .. ":" .. dst_port .."]: " .. tostring(msg))
        end
    end
end

_loop.run_until_complete(coroutine.create(display_ip_packets))