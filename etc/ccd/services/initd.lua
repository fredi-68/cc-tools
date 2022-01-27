-- Run shell so user can actually do stuff

self.provides = "usersession"

function self.run()
   sleep(0.2)
   term.clear()
   term.setCursorPos(1, 1)
   --dofile("/bin/vsh.lua")
   dofile("/rom/programs/shell.lua")
end