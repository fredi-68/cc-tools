--[[
    FredIO await() Example.

    This example demonstrates how to use libfredio.EventLoop().await()
    to compose asynchronous function calls.
]]

loop = libfredio.EventLoop()

--[[
    Some asynchronous function that
    computes a result.
]]
function my_function_1 ()
    os.sleep(1)
    return "Hello World"
end

--[[
    Our main entrypoint.
    This function calls my_function_2 using libfredio.EventLoop().await()
    and prints the result. Creation and management of the underlying tasks
    is abstracted away from the user.
]]
function my_function_2 ()
    print(loop.await(my_function_1))
end

-- run until our coroutine has finished
loop.run_until_complete(coroutine.create(my_function_2))