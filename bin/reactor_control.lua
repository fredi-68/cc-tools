--[[
    Automatic reactor management script for ExtremeReactors (BigReactors).

    Authors: fredi_68, GitHub Copilot
]]

--[[
    maximum energy buffer constant.
    If the reactor is wasting too much energy,
    set this to a lower value
]]
ENERGY_MAX = 0.90

--[[
    How often to run the automatic optimization task.
    This value determines how long to wait before reevaluation, in seconds.
]]
EVALUATION_DELAY = 1

--[[
    Maximum control rod movement change per cycle, in percent.
]]
SPEED = 2

local loop = libfredio.EventLoop()

local reactor = peripheral.wrap("back")
local manual_control = false
local target = {
    efficiency = 3,             -- Target efficiency of the reactor.
    max_temperature = 1200,      -- Maximum core temperature constraint in degrees centigrade.
    min_fuel_level = 0,         -- Minimum fuel level constraint. Valid values are 0 to 1.
    min_waste_level = 0,        -- Minimum waste level constraint. Valid values are 0 to 1.
    max_waste_level = 0.5,      -- Maximum waste level constraint. Valid values are 0 to 1.
    max_energy_output = 0,      -- Maximum energy output constraint. Set to 0 to disable.
    energy_high_level = 0.5     -- Target energy buffer level. Valid values are 0 to 1. Upon reaching this level, output throttling will be applied.
}

local function get_energy_fill_ratio(reactor)
    local energy_capacity = reactor.getEnergyCapacity()
    local energy_stored = reactor.getEnergyStored()
    return energy_stored / energy_capacity
end

--[[
    This function displays a status report on
    the screen.
    For each value in the target table, it
    prints the current value and the target in
    a table format.
]]
local function show_status_report(reactor)
    
    term.clear()
    term.setCursorPos(1, 1)
    local w = io.write
    w("Reactor status report\n")
    w("\n")
    w("Reactor state: " .. (reactor.getActive() and "ON" or "OFF") .. " [" .. (manual_control and "MANUAL" or "AUTO") .. "]\n")
    w("Control rod level: " .. reactor.getControlRodLevel(0) .. "\n")
    w("Efficiency: " .. reactor.getFuelReactivity() .. " / " .. target.efficiency * 100 .. "\n")
    w("Core temperature: " .. reactor.getFuelTemperature() .. " / " .. target.max_temperature .. "\n")
    w("Fuel level: " .. reactor.getFuelAmount() .. " / " .. reactor.getFuelAmountMax() .. "\n")
    w("Waste level: " .. reactor.getWasteAmount() .. " / " .. target.max_waste_level .. "\n")
    w("Energy output: " .. reactor.getEnergyStored() .. " / " .. reactor.getEnergyCapacity() .. "\n")
    if get_energy_fill_ratio(reactor) > target.energy_high_level then
        w("INFO: Energy output is being limited.")
    end
end


local function eject_waste(reactor)
    -- TODO: implement
end

--[[
    Reactor control loop.

    This function attempts to automatically optimize the reactors
    performance, efficiency and output by adjusting the control rods,
    waste disposal settings and reactor state according to a set of 
    constraints.

    The primary optimization goal is reactor output. Its limit is set by
    max_energy_output. Additional constraints are applied as requested.
    Fuel burnup rate may be adjusted by tweaking efficiency and maximum
    power output targets. 
]]
local control_loop = libfredio.async(function (reactor) 
    while true do
        if not manual_control then
            -- first, check if we even need to generate power
            local fill_ratio = get_energy_fill_ratio(reactor)
            if fill_ratio > ENERGY_MAX then
                -- output buffer is full, shut down the reactor
                reactor.setActive(false)
            else
                -- how much power do we need to generate?
                -- the target power is the maximum power constraint times the current
                -- fill ratio in proportion to energy_high_level and ENERGY_MAX
                local target_power = 0
                local dampen = 1 - math.max(0, (fill_ratio - target.energy_high_level)) / (1 - target.energy_high_level)
                if target.max_energy_output > 0 then
                    target_power = target.max_energy_output * dampen
                else
                    target_power = dampen * 10000
                end
                if target_power > 0 then
                    -- we need to generate power, so turn on the reactor
                    reactor.setActive(true)
                    -- do we need to generate more power than we currently are?
                    local power_output = reactor.getEnergyProducedLastTick()
                    local power_change = 0
                    if power_output < target_power then
                        -- we need to increase the power output
                        power_change = math.min(target_power - power_output, SPEED)
                    else
                        -- we need to decrease the power output
                        power_change = math.max(target_power - power_output, -SPEED)
                    end
                    -- are we meeting our efficiency target?
                    local reactivity = reactor.getFuelReactivity()/100
                    if reactivity > 0 and reactivity < target.efficiency then
                        -- we need to increase the efficiency, reduce the power change
                        power_change = -SPEED * (target.efficiency - reactor.getFuelReactivity()/100)
                    -- are we overheating?
                    end
                    if reactor.getFuelTemperature() > target.max_temperature then
                        -- we need to decrease the power change to cool down
                        power_change = SPEED * (target.max_temperature - reactor.getFuelTemperature())
                        --power_change = math.max(power_change + (target.max_temperature - reactor.getFuelTemperature()), -SPEED)
                    else
                        if power_change > 0 then
                            -- TODO: This is currently linear, but logarithmic falloff would be better
                            power_change = power_change * (1 - (reactor.getFuelTemperature() / target.max_temperature))

                        end
                    end
                    reactor.setAllControlRodLevels(math.max(0, math.min(100, reactor.getControlRodLevel(0) - power_change)))
                end
            end
            -- do we need to eject waste?
            if reactor.getWasteAmount() > target.max_waste_level then
                -- eject waste
                eject_waste(reactor.getWasteAmount() - target.max_waste_level)
            end
        end
        show_status_report(reactor)
        os.sleep(EVALUATION_DELAY)
    end

end)

local server = libfrednet.RTPServer(80, loop)

server.route("/set_mode", function (request)
    manual_control = request.data.manual
    request.respond(manual_control)
end)

server.route("/get_mode", function (request)
    request.respond(manual_control)
end)

server.route("/get_target", function (request)
    request.respond(target)
end)

server.route("/set_target", function(request)
    for key, value in pairs(target) do
        if request.data[key] ~= nil then
            target[key] = request.data[key]
        end
    end
    request.respond(target)
end)

server.route("/get_status", function(request) 
    request.respond({
        reactor_state = reactor.getActive(),
        control_rod_level = reactor.getControlRodLevel(0),
        efficiency = reactor.getFuelReactivity()/100,
        core_temperature = reactor.getFuelTemperature(),
        fuel_level = reactor.getFuelAmount(),
        waste_level = reactor.getWasteAmount(),
    })
end)

server.start()
loop.task(libfrednet.connect())
loop.task(control_loop(reactor))
loop.run_forever()