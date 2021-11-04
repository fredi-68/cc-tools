--#import "/lib/shared/cls.lua"
--#import "/lib/shared/logging.lua"

Task = make_class()

Task.logger = Logger("loop.Task")

function Task.init(self, loop, coro)
    assert(type(coro) == "thread", "First argument to Task constructor must be a thread object, not " .. type(coro))
    self._coro = coro
    self._loop = loop
    self._cbs = {}
    self._started = false
end

function Task.has_started(self)
    return self._started
end

function Task.start(self)
    self._started = true
    self.handle_event({"task_start"})
end

function Task.is_done(self)
    return coroutine.status(self._coro) == "dead"
end

function Task.is_running(self)
    return coroutine.status(self._coro) == "running"
end

--[[
    Cancel this task.

    The pending coroutine will be immediately stopped and
    control will return to the caller.
]]
function Task.cancel(self)
    coroutine.close(self._coro)
    self._is_running = false
end

--[[
    Synchronously wait for this task to complete and return the result.

    For a asynchronous callback based interface, see Task.after().
]]
function Task.wait_for_result(self)
    while not self.is_done() do
        coroutine.yield("task_done", self)
    end
    return self._result
end

--[[
    Schedule a callback to run after the Task completes.
    The callback will be invoked with the result of the coroutine as its arguments.

    This is essentially Promise.then() but because then is a
    Lua keyword we cannot use it.
]]
function Task.after(self, cb)
    table.insert(self._cbs, cb)
end

--[[
    Invoke the event handler for this Task.
]]
function Task.handle_event(self, event)

    if self.is_done() then
        return
    end

    local event_type = event[1]
    if self._wait_for == nil or self._wait_for == event_type or event_type == "terminate" then
        local res = table.pack(coroutine.resume(self._coro, table.unpack(event)))
        if res[1] then
            error(res[2], 0)
        end
        if self.is_done() then
            self.set_result(true, table.unpack(res, 2))
        else
            self._wait_for = res[2]
        end
    end
end

--[[
    Set the result for this Task and run any callbacks registered.
]]
function Task.set_result(self, success, ...)
    self._result = table.pack(...)
    for cb in self._cbs do
        local success, result = pcall(cb, ...)
        if not success then
            self.logger.error(tostring(result))
        end
    end
end