--[[
    FredIO await() Example.

    This example demonstrates how to use libfredio.await()
    to compose asynchronous function calls.
]]

loop = libfredio.EventLoop()

--[[
    Some asynchronous function that
    computes a result.
]]
my_function_1 = libfredio.async(function (name)
    os.sleep(1)
    return "Hello " .. name
end)

--[[
    Our main entrypoint.
    This function calls my_function_2 using libfredio.await()
    and prints the result. Creation and management of the underlying tasks
    is abstracted away from the user.
    This example improves on await_example.lua by using libfredio.await(), 
    which hides the running event loop completely, instead using
    coroutine functions and coroutine objects as abstractions.
]]
my_function_2 = libfredio.async(function ()
    print(libfredio.await(my_function_1("World")))
end)

-- run until our coroutine has finished
loop.run_until_complete(my_function_2())