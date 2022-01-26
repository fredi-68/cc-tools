--[[
    Command line utility for managing system services.

    Run `systemctl start <service>` to start a service.
    Run `systemctl stop <service>` to stop a service.
    Run `systemctl enable <service>` to start a service at boot.
    Run `systemctl disable <service>` to prevent a service from starting at boot.
]]

local service_name = arg[2]
if service_name == nil then
    print("Usage: systemctl <start|stop|enable|disable> <service>")
    os.exit(1)
end

new_args = table.pack(table.unpack(arg, 3))

if arg[1] == "start" then
    os.queueEvent(libccd.E_SERVICE_START, service_name, nil, new_args)
elseif arg[1] == "stop" then
    os.queueEvent(libccd.E_SERVICE_STOP, service_name, nil, new_args)
elseif arg[1] == "enable" then
    fs.copy(service_name, libccd.SERVICE_DIRECTORY .. "/" .. fs.getName(service_name))
    os.queueEvent(libccd.E_SERVICE_START, fs.getName(service_name), nil, new_args)
elseif arg[1] == "disable" then
    fs.delete(libccd.SERVICE_DIRECTORY .. "/" .. fs.getName(service_name))
    os.queueEvent(libccd.E_SERVICE_STOP, fs.getName(service_name), nil, new_args)
else
    print("Usage: systemctl <start|stop|enable|disable> <service>")
    os.exit(1)
end