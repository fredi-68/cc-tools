dofile("/lib/shared/logging.lua")

logger = Logger("router")

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
        if config.is_ansible then
            --[[
                This little hack basically implements
                https://github.com/cc-tweaked/CC-Tweaked/issues/955
                until it gets upstreamed.
                Basically, any modem marked as an "ansible" will stop
                communicating on common frednet channels and instead use the
                special CHANNEL_ANSIBLE channel for communicating with other
                ansibles. Use this to create a mesh network of ender modems.
            ]]
            peripheral.call(config.side, "closeAll")
            peripheral.call(config.side, "open", libfrednet.CHANNEL_ANSIBLE)
        end
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
        local event, packet = os.pullEvent("routed_ipmc_packet")
        local i_src = get_route(packet.src_addr)
        local i_dst = get_route(packet.dst_addr)
        local ch = nil
        if i_src ~= i_dst then
            if i_dst == nil then
                logger.error("ERROR: No route to " .. libfrednet.num2ip(packet.dst_addr))
            else
                if i_dst.is_ansible then
                    ch = libfrednet.CHANNEL_ANSIBLE
                end
                logger.debug("Forwarded packet from " .. i_src.side .. " to " .. i_dst.side)
                libfrednet.transmit_routed(packet.dst_addr, packet.dst_port, packet.src_addr, packet.src_port, packet.data, i_dst.side, packet.hops, ch)
            end
        end
    end
end

_loop.run_until_complete(coroutine.create(do_routing))