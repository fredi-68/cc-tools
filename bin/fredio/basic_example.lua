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

local loop = libfredio.EventLoop()
local t1 = loop.call(my_function_1)
local t2 = loop.call(my_function_2)

loop.run_forever()
