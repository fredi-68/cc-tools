self.provides = "energy_monitor"
self.dependencies = {"frednet"}

function self.run()
    dofile("/usr/bin/energy_monitor.lua")
end
