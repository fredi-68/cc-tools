-- Run shell so user can actually do stuff

self.provides = "usersession"
self.ignore_terminate = false

function self.run()
   sleep(0.2)
   term.clear()
   term.setCursorPos(1, 1)
   ok, err = pcall(dofile, "/bin/vsh.lua")
   if not ok then
      self.log("INIT PROCESS DIED: " .. err)
      print("Bailing out, you are on your own.")
      self.auto_restart = false
   end
   --dofile("/rom/programs/shell.lua")
end