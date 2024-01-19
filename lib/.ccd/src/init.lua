--#import service.lua
--#import const.lua
--#import host.lua
--#import journal.lua
--#import /lib/shared/logging.lua

-- INIT SCRIPT FOR CCD.

function do_init()

  -- strange hack to get around the funky module initialization
  -- code of CC
  if _G.ccd_init_done then
    return
  end
  _G.ccd_init_done = true

  ccd_log_init()

  -- monkey patch the OS shutdown to run our own shutdown sequence instead
  _G.original_shutdown = os.shutdown
  os.shutdown = function () 
    e = _ENV
    e.arg = {"start", "/etc/services/shutdown.lua", "0"}
    loadfile("/bin/systemctl.lua", e)()
  end

  local logger = Logger("ccd")

  -- Load services at boot
  if not fs.exists(SERVICE_DIRECTORY) then
    fs.makeDir(SERVICE_DIRECTORY)
  end
  for i, path in ipairs(fs.list(SERVICE_DIRECTORY)) do
    os.queueEvent(E_SERVICE_START, path, nil)
  end

  -- Create service host and start running 
  _G.service_host = ServiceHost()
  _G.service_host.run()
end