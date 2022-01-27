WAIT_TIME = tonumber(arg[1])

self.provides = "shutdown"

function self.run()
    sleep(WAIT_TIME)
    print("Sending shutdown signal...")
    os.queueEvent(libccd.E_SHUTDOWN)
end