--[[
    Provides DHCP server
]]

CONFIG_PATH = "/etc/dhcpd.conf"

DEFAULT_CONFIG = {
    iface = "right",
    network = "200.0.0",
    netmask = "255.255.0",
    range = "253",
    gateway = "200.0.254",
    dns = "200.0.254",
    lease_time = 0,
    options = {}
}

function self.before()
    if not fs.exists(CONFIG_PATH) then
        fs.write(CONFIG_PATH, textutils.serialize(DEFAULT_CONFIG))
    end
end

function self.run()

    local config = textutils.unserialize(fs.read(CONFIG_PATH))

    local iface = config.iface
    local network = config.network
    local netmask = config.netmask
    local range = config.range
    local gateway = config.gateway
    local dns = config.dns
    local lease_time = config.lease_time
    local options = config.options

    local server = libfrednet.DHCPServer(iface, network, netmask, range, gateway, dns, lease_time, options)
    server.start()
end