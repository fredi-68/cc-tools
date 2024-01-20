--#import util.lua

_CONFIG = {}
_CONFIG_PATH = "/etc/frednet.conf"

function push_network_config(config) 
    for k, v in pairs(config) do
        _CONFIG[k] = v
    end
end

function get_network_config()
   return _CONFIG
end

function reload_config()
    if not fs.exists(_CONFIG_PATH) then
        return
    end
    local f = fs.open(_CONFIG_PATH, "r")
    _CONFIG = textutils.unserialize(f.readAll())
    f.close()
end

function save_config()
    local f = fs.open(_CONFIG_PATH, "w")
    f.write(textutils.serialize(_CONFIG))
    f.close()
end

--[[
    Shorthand for get_network_config().ip

    Returns the configured IP address for the local host.
]]
function get_local_host_ip()
    if _CONFIG.dhcp_lease ~= nil and _CONFIG.dhcp_lease.ip ~= nil then
        return _CONFIG.dhcp_lease.ip
    end
    return _CONFIG.ip
end

--[[
    Shorthand for libfrednet.ip2num(get_network_config().ip)

    Returns the configured IP address for the local host as a number.
]]
function get_local_host_ip_num()
    return ip2num(get_local_host_ip())
end