-- Run shell so user can actually do stuff

function self.run()
   sleep(0.2)
   term.clear()
   term.setCursorPos(1, 1)
   --dofile("/bin/vsh.lua")
   dofile("/rom/programs/shell.lua")
end