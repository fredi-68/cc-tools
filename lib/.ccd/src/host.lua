--#import const.lua
--#import "/lib/shared/cls.lua"

ServiceHost = make_class()

function ServiceHost.init(self) 
    self.running_services = {}
    self.pending_services = {}
    self.service_directory = SERVICE_DIRECTORY
end

function ServiceHost.resolve_service_name(self, name)
    if fs.exists(name) then return name end
    if fs.exists(self.service_directory .. "/" .. name) then return self.service_directory .. "/" .. name end
    return nil
end

function ServiceHost._run(self)
    while true do
        local event = table.pack(os.pullEventRaw())
        if event[1] == E_SERVICE_START then
            local service_file = self.resolve_service_name(event[2])
            local service = Service(service_file, event[3], event[4])
            
            -- TODO: resolve dependencies and load them as well
            table.insert(self.pending_services, service)
        elseif event[1] == E_SERVICE_STOP then
            local service_file = self.resolve_service_name(event[2])
            for i, service in ipairs(self.running_services) do
                if service.service_file == service_file then
                    service.stop()
                    self.running_services[i] = nil
                    break
                end
            end
        elseif event[1] == E_SHUTDOWN then
            for i, service in ipairs(self.running_services) do
                service.stop()
            end
            self.running_services = {}
            print("Goodbye.")
            break
        end

        -- try to start pending services
        for i, service in ipairs(self.pending_services) do
            local can_start = true
            for _, dep in ipairs(service.dependencies) do
                local resolved = false
                for _, s in ipairs(self.running_services) do
                    if s.provides == dep then
                        resolved = true
                        break
                    end
                end
                if not resolved then
                    can_start = false -- service depends on another service which is not running, stop for now
                    break
                 end
            end

            if can_start then
                local ok, reason = pcall(service.start)
                if not ok then
                    print("[ ERROR ] Service " .. service.service_file .. " failed to start: " .. reason)
                else
                    table[service.provides] = service
                    table.insert(self.running_services, service)
                end
                self.pending_services[i] = nil
            end
        end

        -- handle events for running services
        for i, service in pairs(self.running_services) do
            if service ~= nil then
                local ok, reason
                ok = true
                if service.check_running() then
                    ok, reason = pcall(service.handle_event, event)
                else
                    if service.auto_restart then
                        print("[ ERROR ] Service " .. service.service_file .. "appears to be stopped, restarting...")
                        service.start()
                    else
                        service.stop()
                        self.running_services[i] = nil
                    end
                end
                if not ok then
                    print("[ ERROR ] Service " .. service.service_file ..  " died: " .. tostring(reason))
                    service.stop()
                    self.running_services[i] = nil
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