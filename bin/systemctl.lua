--[[
    Command line utility for managing system services.

    Run `systemctl start <service>` to start a service.
    Run `systemctl stop <service>` to stop a service.
    Run `systemctl enable <service>` to start a service at boot.
    Run `systemctl disable <service>` to prevent a service from starting at boot.
]]

local service_name = arg[2]
function c ()
    if service_name == nil then
        error("Usage: systemctl <start|stop|enable|disable> <service>")
    end
end

new_args = table.pack(table.unpack(arg, 3))

if arg[1] == "start" then
    c()
    os.queueEvent(libccd.E_SERVICE_START, service_name, nil, new_args)
elseif arg[1] == "stop" then
    c()
    os.queueEvent(libccd.E_SERVICE_STOP, service_name, nil, new_args)
elseif arg[1] == "enable" then
    c()
    fs.copy(service_name, libccd.SERVICE_DIRECTORY .. "/" .. fs.getName(service_name))
    os.queueEvent(libccd.E_SERVICE_START, fs.getName(service_name), nil, new_args)
elseif arg[1] == "disable" then
    c()
    fs.delete(libccd.SERVICE_DIRECTORY .. "/" .. fs.getName(service_name))
    os.queueEvent(libccd.E_SERVICE_STOP, fs.getName(service_name), nil, new_args)
elseif arg[1] == "status" then
    print("SERVICE   STATE")
    print("--------------------------------")
    for i, service in ipairs(_G.service_host.pending_services) do
        print(service.service_file .. "   pending")
    end
    for i, service in ipairs(_G.service_host.running_services) do
        print(service.service_file .. "   running")
    end
else
    error("Usage: systemctl <start|stop|enable|disable> <service>") 
end

coroutine.yield() -- wait for the event to get handled before returning to the calling shell.