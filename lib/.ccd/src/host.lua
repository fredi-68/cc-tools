--#import const.lua
--#import "/lib/shared/cls.lua"

ServiceHost = make_class()

function ServiceHost.init(self) 
    self.services = {}
    self.service_directory = SERVICE_DIRECTORY
end

function ServiceHost._run(self)
    while true do
        local event = table.pack(os.pullEventRaw())
        if event[1] == E_SERVICE_START then
            local service_file = event[2]
            local service = Service(service_file, event[3], event[4])
            
            local ok, reason = pcall(service.start)
            if not ok then
                print("[ ERROR ] Service " .. service.service_file .. "failed to start: " .. reason)
            else
                table.insert(self.services, service)
            end
        elseif event[1] == E_SERVICE_STOP then
            local service_file = event[2]
            for i, service in ipairs(self.services) do
                if service.service_file == service_file then
                    service.stop()
                    self.services[i] = nil
                    break
                end
            end
        elseif event[1] == E_SHUTDOWN then
            for i, service in ipairs(self.services) do
                service.stop()
            end
            self.services = {}
            print("Goodbye.")
            break
        end

        for i, service in pairs(self.services) do
            if service ~= nil then
                local ok, reason
                ok = true
                if service.check_running() then
                    ok, reason = pcall(service.handle_event, event)
                else
                    if service.auto_restart then
                        print("[ ERROR ] Service " .. service.service_file .. "appears to be stopped, restarting...")
                        service.start()
                    end
                end
                if not ok then
                    print("[ ERROR ] Service " .. service.service_file ..  " died: " .. tostring(reason))
                    service.stop()
                    self.services[i] = nil
                end
            end 
        end
    end
    -- TODO: handle different targets (shutdown, reboot, root shell, etc...)
    sleep(0.5)
    _G.original_shutdown()
end

function ServiceHost.run(self) 
    self._run()
end