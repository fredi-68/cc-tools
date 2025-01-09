self.provides = "maild"
self.dependencies = {"frednet"}

function self.run ()
    dofile("/usr/bin/maild.lua")
end