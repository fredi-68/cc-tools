--#import "/lib/shared/cls.lua"

RequestConfigPacket = make_class()

function RequestConfigPacket.init(self)
    self.opcode = 0x1
    self.host_id = os.getComputerID()
end

RespondConfigPacket = make_class()

function RespondConfigPacket.init(self, host_id, net_addr, net_mask, gateway_id, gateway_addr, dhcp_opt)
    self.opcode = 0x2
    self.host_id = host_id
    self.net_addr = net_addr
    self.net_mask = net_mask
    self.gateway_id = gateway_id
    self.gateway_addr = gateway_addr
    if dhcp_opt == nil then
        self.dhcp_opt = {}
    else
        self.dhcp_opt = dhcp_opt
    end
end

RequestAddressPacket = make_class()

function RequestAddressPacket.init(self)
    self.opcode = 0x3
    self.host_id = os.getComputerID()
end

RespondAddressPacket = make_class()

function RespondAddressPacket.init(self, host_id, addr, lease_exp, flags)
    self.opcode = 0x4
    self.host_id = host_id
    self.addr = addr
    self.lease_exp = lease_exp
    if flags == nil then
        self.flags = {}
    else
        self.flags = flags
    end
end