local _loop = libfrednet.connect()

local display_ip_packets = function ()
    while libfrednet.is_connected() do
        local event, src_addr, src_port, dst_port, msg = os.pullEvent("frednet_message")
        log("[FROM " .. libfrednet.num2ip(src_addr) .. ":" .. src_port .. "][TO " .. dst_port .."]: " .. tostring(msg))
    end
end

parallel.waitForAll(_loop, display_ip_packets)