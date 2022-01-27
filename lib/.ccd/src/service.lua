--#import "/lib/shared/cls.lua"

Service = make_class()

function Service.init(self, service_file, directory, args)

    self.provides = nil
    self.dependencies = {}
    self.auto_restart = true

    if directory == nil then
        self.directory = ""
    else
        self.directory = directory .. "/"
    end
    self.service_file = service_file
    e = _G
    e.self = self
    e.arg = args
    loadfile(self.directory .. service_file, e)()
end

function Service.start(self)
    if self.before ~= nil then
        self.before()
    end
    self._thread = coroutine.create(self.run)
    self.handle_event({"service_started"})
    print("[ OK ] Service " .. self.service_file .. " started.")
end

function Service.stop(self)
    coroutine.resume(self._thread, "terminate")
    self._thread = nil
    if self.after ~= nil then
        self.after()
    end
    print("[ OK ] Service " .. self.service_file .. " stopped.")
end

function Service.handle_event(self, event)
    local event_type = event[1]
    if self._wait_for == nil or self._wait_for == event_type or event_type == "terminate" then
        local res = table.pack(coroutine.resume(self._thread, table.unpack(event)))
        if not res[1] and event_type ~= "terminate" then
            error(res[2], 0)
        end
        self._wait_for = res[2]
    end
end

function Service.check_running(self)
    if self._thread == nil then
        return false
    end
    return coroutine.status(self._thread) ~= "dead"
end