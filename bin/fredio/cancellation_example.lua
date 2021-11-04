--[[
    FredIO Task Cancellation Example

    This example demonstrates the ability to cancel running Tasks.
    Cancelling a Task can be useful, especially since a long running task
    may slow down or outright stall an interactive program. It is also
    very useful for implementing timeouts.
]]

loop = libfredio.EventLoop()

--[[
    A function simulating a long running task.
    Will slowly print the numbers 1 through 10
    to the console.
]]
function long_running_task()
    for i = 1, 10 do
        print("Long task: Progress " .. i)
        os.sleep(3)
    end
    print("Long task finished.")
end

--[[
    Dispatcher function. Queues up a long
    task, then waits a few seconds and cancels it.
    Prints the result of the task to console.
]]
function dispatcher()
    local t = loop.call(long_running_task)
    print("Waiting...")
    os.sleep(10)
    print("Cancelling task.")
    t.cancel()
    print("Waiting for result...")
    local res = t.wait_for_result()
    print("Task result: " .. res)
end

loop.run_until_complete(coroutine.create(dispatcher))