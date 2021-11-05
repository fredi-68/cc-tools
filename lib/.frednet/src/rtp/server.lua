--#import "../client.lua"
--#import "../util.lua"
--#import "/lib/shared/cls.lua"
--#import "/lib/shared/logging.lua"

RTPServer = make_class()

RTPServer.logger = Logger("rtp.server")

function RTPServer.init(self, port, loop)
    self.port = port
    self.routes = {["/index"] = self._index}
    self._loop = loop
end

--[[
    Create a new route for the given path.

    This method takes two arguments, path and cb respectively.
    The first argument should be the path to this resource and is used
    as a label when requesting an endpoint.
    The second argument should be a function that takes a single parameter,
    request. request is a table with the following structure: 

    {
        src_addr = the address of the client requesting the resource
        src_port = the port of the client requesting the resource
        data = the data that was sent as part of the request
    }

    Further, request also contains two function pointers under the names
    respond() and error().

        respond() takes a single parameter of any type and sends it back to the client
            together with a success code.
        error() takes a single parameter describing the reason the request failed. It will
            be returned to the client together with a code 3 error and a message will be
            logged to the server console.
]]
function RTPServer.route(self, path, cb)
    self.routes[path] = cb
end

--[[
    Wrap a peripheral table in an RTP API.
    Automatically creates routes for each function provided by
    the peripheral.
]]
function RTPServer.wrap(self, peripheral)
    for key, fn in pairs(peripheral) do
        self.route("/" .. key, function (request) request.respond(fn(request.data)) end)
    end
end

function RTPServer._index(self, request)
    local res = {}
    for key, fn in pairs(self.routes) do
        table.insert(res, key)
    end
    request.respond(res)
end

function RTPServer._serve(self)
    return function ()
        self.logger.info("Now serving RTP requests on port " .. self.port)
        while is_connected() do
            local event, src_addr, src_port, dst_port, data = os.pullEvent("frednet_message")
            if dst_port == self.port then
                self.logger.verbose("New connection from " .. num2ip(src_addr) .. ":" .. src_port)
                if data.path ~= nil then
                    local cb = self.routes[data.path]
                    if cb ~= nil then
                        local t = {
                            src_addr = src_addr,
                            src_port = src_port,
                            data = data.data,
                            respond = function (r_data)
                                return transmit(src_addr, src_port, self.port, {error=0, data=r_data})
                            end,
                            error = function (reason)
                                self.logger.error("Error happened in '" .. data.path .. "': " .. reason)
                                return transmit(src_addr, src_port, self.port, {error=3, data=reason})
                            end
                        }
                        cb(t)
                    else
                        self.logger.error("ERROR: Path '" .. data.path .. "', resource location is not valid or does not exist.")
                        transmit(src_addr, src_port, self.port, {error=2})
                    end
                else
                    self.logger.error("ERROR: No path specified, invalid request.")
                    transmit(src_addr, src_port, self.port, {error=1})
                end
            end
        end
        self.logger.info("exit")
    end
end

--[[
    Start the server and wait for incoming connections.

    If no event loop was specified, this call will create a new event loop
    and immediately start it, blocking until the server is shut down.
    If you specified your own event loop, you are responsible for starting it.
]]
function RTPServer.start(self)
    self.logger.debug("Starting RTP server...")
    if self._loop == nil then
        self._loop = libfredio.EventLoop()
        self._loop.call(connect())
        self._loop.call(self._serve())
        return self._loop.run_forever()
    end
    self._loop.call(self._serve())
end