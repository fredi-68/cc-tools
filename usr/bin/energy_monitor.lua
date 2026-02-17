dofile("/lib/shared/cls.lua")
dofile("/lib/shared/logging.lua")

MAX_HISTORY = 10
UPDATE_RATE = 1

logger = Logger("energy_monitor")

function _create_history()
    local t = {}
    for i = 1, MAX_HISTORY do
        table.insert(t, 0)
    end
    return t
end

RateMonitor = make_class()

function RateMonitor.init(self, loop, side, avg)
    self.loop = loop
    self.history = _create_history()
    self.avg = function () return peripheral.call(side, avg) end
end
function RateMonitor.start(self)
    self.loop.task(libfredio.async(function ()
        while true do
            table.remove(self.history, 1)
            table.insert(self.history, self.avg())
            os.sleep(UPDATE_RATE)
        end
    end)())
end

function RateMonitor.get_metrics(self)
    return {
        rate_current = self.avg(),
        rate_history = self.history
    }
end

StorageMonitor = make_class()

function StorageMonitor.init(self, loop, side, cur, max)
    self.loop = loop
    self.rate_history = _create_history()
    self.storage_history = _create_history()
    self.cur = function () return peripheral.call(side, cur) end
    self.max = function () return peripheral.call(side, max) end
end
function StorageMonitor.start(self)
    self.loop.task(libfredio.async(function ()
        while true do
            table.remove(self.rate_history, 1)
            table.remove(self.storage_history, 1)
            local v = self.cur()
            table.insert(self.rate_history, v-self.storage_history[#self.storage_history])
            table.insert(self.storage_history, v)
            os.sleep(UPDATE_RATE)
        end
    end)())
end

function StorageMonitor.get_metrics(self)
    local v = self.cur()
    local m = self.max()
    return {
        capacity = m,
        rate_current = self.rate_history[#self.rate_history],
        rate_history = self.rate_history,
        storage_current = v,
        storage_current_ratio = v/m,
        storage_history = self.storage_history
    }
end

function_map = {
    current_transformer = {
        {RateMonitor, "getAveragePower"}
    },
    capacitor_lv = {
        {StorageMonitor, "getEnergyStored", "getMaxEnergyStored"}
    },
    capacitor_mv = {
        {StorageMonitor, "getEnergyStored", "getMaxEnergyStored"}
    },
    capacitor_hv = {
        {StorageMonitor, "getEnergyStored", "getMaxEnergyStored"}
    },
    [ "BigReactors-Reactor" ] = {
        {StorageMonitor, "getEnergyStored", "getEnergyCapacity"},
        {RateMonitor, "getEnergyProducedLastTick"}
    }
}

local loop = libfredio.EventLoop()
local server = libfrednet.RTPServer(90, loop)

local monitors = {}

for i, side in ipairs(peripheral.getNames()) do
    local f = function_map[peripheral.getType(side)]
    if f == nil then
        -- try to substitute for generic storage
        if peripheral.wrap(side)["getEnergy"] ~= nil and peripheral.wrap(side)["getEnergyCapacity"] ~= nil then
            f = {{StorageMonitor, "getEnergy", "getEnergyCapacity"}}
        end
    end
    if f ~= nil then
        logger.info("Found energy device '" .. peripheral.getType(side) .. "' at '" .. side .. "'")
        local path = "/monitor/" .. side
        -- setup monitor
        local _monitors = {}
        for j, m in ipairs(f) do
            local mon = m[1](loop, side, table.unpack(m, 2))
            mon.start()
            table.insert(_monitors, mon)
        end
        monitors[path] = _monitors
        -- setup route
        server.route(path, function (request)
            res = {}
            for k, m in ipairs(monitors[path]) do
                for l, v in pairs(m.get_metrics()) do
                    res[l] = v
                end
            end
            request.respond(res)
        end)
    end
    server.route("/monitor/index", function(request)
        local t = {}
        for m, _ in pairs(monitors) do
            table.insert(t, m)
        end
        request.respond(t)
    end)
end

server.start()
loop.run_forever()