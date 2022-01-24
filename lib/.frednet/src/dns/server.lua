--#import "/lib/shared/cls.lua"
--#import "/lib/shared/logging.lua"
--#import "packets.lua"
--#import "const.lua"
--#import "client.lua"

DNSServer = make_class()
DNSServer.logger = Logger("dns.server")
DNSServer.port = 53

function DNSServer.init(self, record_table)

    self._record_table = record_table

    self.load_records()
end

function DNSServer.load_records(self)
    self.logger.info("Reloading DNS record table...")
    self.records = textutils.unserialize(fs.open(self._record_table, "r").readAll())
    flush_dns_resolver_cache()
end

function DNSServer._serve(self)
    return libfredio.async(function ()
        self.logger.info("Now serving DNS requests on port " .. self.port)
        while is_connected() do
            local event, src_addr, src_port, dst_port, data = os.pullEvent("frednet_message")
            if dst_port == self.port then
                local src_addr_s = num2ip(src_addr)
                local p
                if self.records[data.hostname] ~= nil then
                    self.logger.verbose("Found record for host "..data.hostname .. " in record table.")
                    p = DNSResponse(data.hostname, self.records[data.hostname], RECORD_AUTHORITATIVE)
                else
                    -- if we have an upstream DNS server, try to resolve the address from there
                    local ok, result = pcall(resolve_hostname, data.hostname)
                    if ok then
                        self.logger.verbose("Upstream DNS response for " .. data.hostname .. ": " .. result)
                        p = DNSResponse(data.hostname, result, RECORD_NON_AUTHORITATIVE)
                    else
                        self.logger.verbose("Unable to resolve address for " .. data.hostname .. ": Upstream DNS query failed.")
                        p = DNSResponse(data.hostname, nil, RECORD_NXDOMAIN)
                    end
                end
                transmit(src_addr, src_port, self.port, p)
            end
        end
        self.logger.info("exit")
    end)()
end

--[[
    Start the server and wait for incoming connections.

    If no event loop was specified, this call will create a new event loop
    and immediately start it, blocking until the server is shut down.
    If you specified your own event loop, you are responsible for starting it.
]]
function DNSServer.start(self)
    self.logger.debug("Starting DNS server...")
    if self._loop == nil then
        self._loop = libfredio.EventLoop()
        if not is_connected() then
            self._loop.task(connect())
        end
        self._loop.task(self._serve())
        return self._loop.run_forever()
    end
    self._loop.task(self._serve())
end

