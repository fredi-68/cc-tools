--#import "/lib/shared/logging.lua"
--#import "../util.lua"
--#import "packets.lua"
--#import "const.lua"

_RESOLVER_CACHE = {}

function resolve_hostname(hostname)

    -- if the hostname already looks like an IP, just return it
    local ok, result = pcall(ip2num, hostname)
    if ok then
        return hostname
    end

    local logger = Logger("DNS")
    if _RESOLVER_CACHE[hostname] then
        logger.debug("Using cached address for hostname lookup: " .. hostname .. " => " .. _RESOLVER_CACHE[hostname])
        return _RESOLVER_CACHE[hostname]
    end
    
    logger.debug("Looking up address for hostname " .. hostname)
    local p = DNSQuery(hostname)
    local address = ip2num(get_network_config().dns_server)
    transmit(address, 53, 53, p)
    local timeout = os.startTimer(5)
    while true do
        local event, packet = os.pullEvent()
        if event == "frednet_message" then
            if packet.dst_port == 53 and packet.data.hostname == hostname then
                if packet.data.record_type == RECORD_AUTHORITATIVE or packet.data.record_type == RECORD_NON_AUTHORITATIVE then
                    _RESOLVER_CACHE[packet.data.hostname] = packet.data.ip
                    return packet.data.ip
                else 
                    error("Cannot resolve hostname " .. hostname .. ": " .. packet.data.record_type)
                end
            end
        elseif event == "timer" then
            if packet == timeout then
                error("Timeout while resolving hostname " .. hostname)
            end
        end
    end
end

function flush_dns_resolver_cache()
    _RESOLVER_CACHE = {}
end