--#import util.lua

_CONFIG = {}
_CONFIG_PATH = ".frednet-config"

function push_network_config(config) 
    for k, v in pairs(config) do
        _CONFIG[k] = v
    end
end

function get_network_config()
   return _CONFIG
end

function reload_config()
    _CONFIG = textutils.unserialize(fs.read(_CONFIG_PATH))
end

function save_config()
    fs.write(_CONFIG_PATH, textutils.serialize(_CONFIG))
end

--[[
    Shorthand for get_network_config().ip

    Returns the configured IP address for the local host.
]]
function get_local_host_ip()
    return _CONFIG.ip
end

--[[
    Shorthand for libfrednet.ip2num(get_network_config().ip)

    Returns the configured IP address for the local host as a number.
]]
function get_local_host_ip_num()
    return ip2num(_CONFIG.ip)
end