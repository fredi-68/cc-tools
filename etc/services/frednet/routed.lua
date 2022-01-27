self.provides = "router"
self.dependencies = {"frednet"}

function self.run()
    dofile("/bin/frednet/router.lua")
 end