loop = libfredio.EventLoop()

function my_function_1 ()
    os.sleep(1)
    return "Hello World"
end

function my_function_2 ()
    print(loop.await(my_function_1))
end

loop.run_until_complete(coroutine.create(my_function_2))