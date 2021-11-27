--#import "/lib/shared/cls.lua"

DNSQuery = make_class()

function DNSQuery.init(self, hostname)
    self.opcode = 0x00
    self.hostname = hostname
end 

DNSResponse = make_class()

function DNSResponse.init(self, hostname, ip, record_type)
    self.opcode = 0x01
    self.hostname = hostname
    self.ip = ip
    self.record_type = record_type
end