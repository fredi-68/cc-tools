dofile("/lib/shared/logging.lua")

local logger = Logger("maild")

local config = {
    allow_remote_receive = false,
    allow_remote_send = false,
}
local mail_path = "/etc/maild"
local mailbox_path = "/etc/maild/mailbox"

local server = libfrednet.RTPServer(25)

server.route("/send", function (request) 
    if not config.allow_remote_send and request.src_addr ~= libfrednet.get_local_host_ip() then
        logger.warning("Attempt to send mail from " .. request.src_addr .. " was denied.")
        return request.error("Forbidden.")
    end
    local user, host = table.unpack(string.split(request.data.to, "@", 1))
    -- TODO: Check if host is remote, for now assume local
    local mailbox = fs.combine(mailbox_path, user)
    if not fs.exists(mailbox) then
        logger.error("Received mail for unknown recipient: " .. user)
        return request.error("Recipient not found.")
    end
    local f = io.open(fs.combine(mailbox, os.date("%F_%H_%M_%S ") .. request.data.subject), "w")
    f:write(textutils.serialize(request.data))
    f:close()
    return request.respond(true)
end)

server.route("/receive", function (request)
    if not config.allow_remote_receive and request.src_addr ~= libfrednet.get_local_host_ip() then
        logger.warning("Attempt to receive mail from " .. request.src_addr .. " was denied.")
        request.error("Forbidden.")
    end
    local mailbox = fs.combine(mailbox_path, request.data.mailbox)
    if not fs.exists(mailbox) then
        logger.error("Attempt to receive mail from unknown mailbox " .. request.data.mailbox)
        return request.error("Mailbox not found.")
    end
    local path = fs.combine(mailbox, request.data.mail)
    if not fs.exists(path) then
        logger.error("Attempt to receive unknown mail: " .. request.data.mail)
        return request.error("Mail not found.")
    end
    local f = io.open(path, "r")
    request.respond(textutils.unserialize(f:read("a")))
    f:close()
end)

server.route("/mailbox", function (request)
    if not config.allow_remote_receive and request.src_addr ~= libfrednet.get_local_host_ip() then
        logger.warning("Attempt to open mailbox from " .. request.src_addr .. " was denied.")
        request.error("Forbidden.")
    end
    local mailbox = fs.combine(mailbox_path, request.data.mailbox)
    if not fs.exists(mailbox) then
        logger.error("Attempt to receive mail from unknown mailbox " .. request.data.mailbox)
        return request.error("Mailbox not found.")
    end
    request.respond(fs.list(mailbox))
end)

server.start()