dofile("/lib/shared/cli_tools.lua")

parser = ArgumentParser("mail", "simple CLI mail client")
parser.add_flag("server", "s", STORE)
parser.add_flag("mailbox", "m", STORE)
parser.parse()

if parser.args.mailbox == nil then
    error("Must specify mailbox to use.")
end
if parser.args.server == nil then
    server_addr = libfrednet.get_local_host_ip()
else
    server_addr = parser.args.server
end

client = libfrednet.RTPClient(server_addr, 25)

local h = {
    send = function ()
        term.write("Recipient: ")
        local to = read()
        term.write("Subject: ")
        local sub = read()
        print("Message: ")
        local msg = read()
        local m = {
            from = parser.args.mailbox .. "@" .. server_addr,
            to = to,
            subject = sub,
            body = msg
        }
        if client.get_resource("/send", m) then
            print("Mail sent!")
        end
    end,
    
    receive = function ()
        local mailbox_list = client.get_resource("/mailbox", {mailbox = parser.args.mailbox})
        for i, name in ipairs(mailbox_list) do
            print(i .. " - " .. name)
        end
        term.write("Type ID of mail to view: ")
        local id = tonumber(read())
        local mail = client.get_resource("/receive", {mailbox = parser.args.mailbox, mail = mailbox_list[id]})
        term.clear()
        term.setCursorPos(1, 1)
        print("From: " .. mail.from)
        print("To: " .. mail.to)
        print("Subject: " .. mail.subject)
        print()
        print(mail.body)
        read()
    end
}
print(parser.remaining[1])
h[parser.remaining[1]]()
