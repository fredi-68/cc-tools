--[[
    Basic FredIO Concurrency Example

    This example demonstrates how to achieve concurrent execution of asynchronous
    functions using fredio. It features two functions simultaneously printing
    numbers to the screen with varying amounts of delay.
]]

function my_function_1()
    for i = 1, 10 do
        print(i .. " from function 1")
        os.sleep(1)
    end
    print("function 1 done")
end

function my_function_2()
    for i = 1, 5 do
        print(i .. " from function 2")
        os.sleep(3)
    end
    print("function 2 done")
end

-- first, create a loop instance
local loop = libfredio.EventLoop()
-- use loop.call() to automatically create coroutines from our
-- functions and wrap them in tasks
local t1 = loop.call(my_function_1)
local t2 = loop.call(my_function_2)

-- run the loop until all tasks have finished.
loop.run_forever()
