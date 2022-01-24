--[[
    Script for controlling the reactor optimization targed remotely using RTP.
]]

loop = libfredio.EventLoop()

application = libfredio.async(function () 

    io.write("Enter address of the reactor: ")
    local addr = read()
    print("Connecting...")

    local remote = libfrednet.RTPClient(addr, 80)

    while true do
        io.write(">>> ")
        local cmd = read()
        if cmd == "quit" then
            break
        elseif cmd == "help" then
            print("quit - quit the application")
            print("help - show this help")
            print("status - show the current status")
            print("set <parameter> <value> - set the parameter to the given value")
            print("get <parameter> - get the current value of the parameter")
        elseif cmd == "status" then
            local status = remote.get_resource("/get_status")
            print("Current status:")
            print("  Reactor state: " .. (status.reactor_state and "ON" or "OFF"))
            print("  Control rod level: " .. status.control_rod_level)
            print("  Efficiency: " .. status.efficiency)
            print("  Temperature: " .. status.core_temperature)
            print("  Fuel level: " .. status.fuel_level)
            print("  Waste level: " .. status.waste_level)
        elseif cmd:sub(1, 4) == "set " then
            local param, value = cmd:match("set ([^ ]+) ([^ ]+)")
            if param == "efficiency" then
                remote.get_resource("/set_target", {efficiency = tonumber(value)})
            elseif param == "override" then
                remote.get_resource("/set_mode", {manual = value == "on" and 1 or 0})
            elseif param == "max_temperature" then
                remote.get_resource("/set_target", {max_temperature = tonumber(value)})
            elseif param == "min_fuel_level" then
                remote.get_resource("/set_target", {min_fuel_level = tonumber(value)})
            elseif param == "min_waste_level" then
                remote.get_resource("/set_target", {min_waste_level = tonumber(value)})
            elseif param == "max_waste_level" then
                remote.get_resource("/set_target", {max_waste_level = tonumber(value)})
            elseif param == "max_energy_output" then
                remote.get_resource("/set_target", {max_energy_output = tonumber(value)})
            elseif param == "energy_high_level" then
                remote.get_resource("/set_target", {energy_high_level = tonumber(value)})
            else
                print("Unknown parameter: " .. param)
            end
        elseif cmd:sub(1, 4) == "get " then
            local param = cmd:match("get ([^ ]+)")
            if param == "efficiency" then
                local target = remote.get_resource("/get_target")
                print("Current efficiency: " .. target.efficiency)
            elseif param == "override" then
                local mode = remote.get_resource("/get_mode")
                print("Override mode: " .. (mode == 1 and "on" or "off"))
            elseif param == "max_temperature" then
                local target = remote.get_resource("/get_target")
                print("Current max temperature: " .. target.max_temperature)
            elseif param == "min_fuel_level" then
                local target = remote.get_resource("/get_target")
                print("Current min fuel level: " .. target.min_fuel_level)
            elseif param == "min_waste_level" then
                local target = remote.get_resource("/get_target")
                print("Current min waste level: " .. target.min_waste_level)
            elseif param == "max_waste_level" then
                local target = remote.get_resource("/get_target")
                print("Current max waste level: " .. target.max_waste_level)
            elseif param == "max_energy_output" then
                local target = remote.get_resource("/get_target")
                print("Current max energy output: " .. target.max_energy_output)
            elseif param == "energy_high_level" then
                local target = remote.get_resource("/get_target")
                print("Current energy high level: " .. target.energy_high_level)
            else
                print("Unknown parameter: " .. param)
            end
        elseif cmd == "get" then
            local target = remote.get_resource("/get_target")
            print("Target: " .. textutils.serialise(target))
        else
            print("Unknown command: " .. cmd)
        end
    end
end)

loop.run_until_complete(application())