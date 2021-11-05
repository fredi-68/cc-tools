local _loop = libfredio.EventLoop()

local display_ip_packets = function ()
    while libfrednet.is_connected() do
        local event, src_addr, src_port, dst_port, msg = os.pullEvent("frednet_message")
        log("[FROM " .. libfrednet.num2ip(src_addr) .. ":" .. src_port .. "][TO " .. dst_port .."]: " .. tostring(msg))
    end
end

_loop.call(libfrednet.connect())
_loop.run_until_complete(coroutine.create(display_ip_packets))