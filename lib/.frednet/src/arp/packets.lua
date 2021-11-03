--#import "/lib/shared/cls.lua"

RequestAddressPacket = make_class()

function RequestAddressPacket.init(self, addr)
    self.host_id = os.getComputerID()
    self.addr = addr
end

AnnounceAddressPacket = make_class()

function AnnounceAddressPacket.init(self)
    self.host_id = os.getComputerID()
    self.addr = os.getenv("frednet.ip")
    self.host_name = os.getComputerLabel()
end