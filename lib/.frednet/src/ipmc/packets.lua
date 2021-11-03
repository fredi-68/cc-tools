--#import "/lib/shared/cls.lua"

IpPacket = make_class()

function IpPacket.init(self, src_addr, src_port, dst_addr, dst_port, data)
    self.src_addr = src_addr
    self.src_port = src_port
    self.dst_addr = dst_addr
    self.dst_port = dst_port
    self.data = data
end