--#import "/lib/shared/cls.lua"
--#import "/lib/shared/logging.lua"
--#import "task.lua"

EventLoop = make_class()

EventLoop.logger = Logger("fredio.EventLoop")

function EventLoop.init(self)
    self._is_running = False
    self._tasks = {}
    self._task_ind = 0
    self._task_count = 0
end

--[[
    Run the event loop.

    This function suspends normal program execution until the event loop is either stopped
    or all running Tasks have finished.
    The event loop perpetually pulls for events from the global event queue and delegates them
    to all running Tasks.
]]
function EventLoop._run(self, _until)
    self._is_running = true
    self.logger.debug("Starting event loop.")
    while self._is_running and self._task_count > 0 and (_until == nil or not _until.is_done()) do
        local event = table.pack(os.pullEventRaw())
        -- iterate over all running tasks
        for i, task in pairs(self._tasks) do
            if task ~= nil then
                local ok, reason
                if task.has_started() then
                    ok, reason = pcall(task.handle_event, event)
                else
                    ok, reason = pcall(task.start)
                end
                if not ok then
                    self.logger.error("Error encountered in running task: " .. tostring(reason))
                end
                if task.is_done() then
                    self.logger.debug("Task finished for coroutine " .. tostring(task._coro))
                    os.queueEvent("task_done", task)
                    self._tasks[i] = nil
                    self._task_count = self._task_count - 1
                    self.logger.debug("Task count is now " .. self._task_count)
                end
            end
        end

    end
end

--[[
    Create a new task from a function by wrapping it in a coroutine.
    Returns the created Task.

    For the lazy JavaScript programmers.
]]
function EventLoop.call(self, fn, ...)
    local args = table.pack(...)
    return self.task(coroutine.create(function () return fn(table.unpack(args)) end))
end

--[[
    Create a new task from a coroutine and schedule it for execution.
    Returns the created Task.
]]
function EventLoop.task(self, coro)
    local t = Task(self, coro)
    table.insert(self._tasks, t)
    self._task_count = self._task_count + 1
    return t
end

--[[
    Run the specified coroutine and return its result.

    This call will block until the result from the coroutine is available.
]]
function EventLoop.run_until_complete(self, coro)
    local t = self.task(coro)
    self._run(t)
    return t.wait_for_result()
end

--[[
    Run the event loop.

    This call will block until the event loop is closed or all
    running Tasks have either finished or been cancelled.
]]
function EventLoop.run_forever(self)
    self._run()
end

function EventLoop.is_running(self)
    return self._is_running
end

function EventLoop.close(self)
    self._is_running = false
    for i = 1, #self._tasks do
        local task = self.tasks[i]
        -- make sure the Task exists and is not currently running
        -- (we cannot cancel a running task)
        if task ~= nil and task._coro == coroutine.running() then
            pcall(task.cancel)
        end
    end
end

--[[
    Create a task from a function, then wait for it to complete and return the result.

    For even more lazy Python programmers.
]]
function EventLoop.await(self, fn, ...)
    local args = table.pack(...)
    return self.task(coroutine.create(function () return fn(table.unpack(args)) end)).wait_for_result()
end