local router_config = textutils.unserialize(fs.open(".frednet-router", "r").readAll())
local routing_table = {}
local main_gateway = nil
if router_config.routes ~= nil then
    for network, config in pairs(router_config.routes) do
        local network_int = libfrednet.ip2num(network)
        if config.is_gateway then
            main_gateway = network_int
        end
        local netmask_int = libfrednet.ip2num(config.netmask)
        config.netmask = netmask_int
        routing_table[network_int] = config
    end
end

--[[
    Return the config of the interface corresponding to the route configured for this destination address.
    Returns nil if no route exists to this network.
]]
local function get_route(addr)
    local _c = nil
    for network, config in pairs(routing_table) do
        local prefix = bit.band(addr, config.netmask)
        if prefix == network then
            _c = config
            break
        end
    end
    if _c == nil and main_gateway ~= nil then
        _c = routing_table[main_gateway]
    end
    return _c
end

local _loop = libfredio.EventLoop()

local do_routing = function ()
    while libfrednet.is_connected() do
        local event, src_addr, src_port, dst_addr, dst_port, msg = os.pullEvent("routed_ipmc_packet")
        local i_src = get_route(src_addr)
        local i_dst = get_route(dst_addr)
        if i_src ~= i_dst then
            if i_dst == nil then
                print("ERROR: No route to " .. libfrednet.num2ip(dst_addr))
            else
                libfrednet.transmit_routed(dst_addr, dst_port, src_addr, src_port, msg, i_dst.side)
            end
        end
    end
end

_loop.task(libfrednet.connect())
_loop.run_until_complete(coroutine.create(do_routing))