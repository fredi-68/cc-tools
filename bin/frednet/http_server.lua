--[[
    HTTP Gateway Server

    This program will start an HTTP gateway server over RTP/IPMC.
    You can use the libfrednet.RTPClient class to make requests
    to this server, which will be forwarded to the requested host,
    with the result returned via RTP.

    A request made should have the following table as its data:

    {
        url = "http://host:port/path/to/my/resource",
        headers = { OPTIONAL headers table as accepted by http.get }
    }
]]

dofile("/lib/shared/logging.lua")

-- Create server instance running on port 80
local server = libfrednet.RTPServer(80)

-- Register the route "/get" on the server
server.route("/get", function(request)
    local url = request.data.url
    if url == nil then
        return request.error("No URL was specified.")
    end
    local headers = request.data.headers
    if headers == nil then
        headers = {}
    end
    -- Call the http library to make the request
    local result = http.get(url, headers)
    -- Return the result to the client
    request.respond({status_code = result.getResponseCode(), body = result.readAll()})
end)

-- Start the server, this call will block.
server.start()