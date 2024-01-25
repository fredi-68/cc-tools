WAIT_TIME = tonumber(arg[1])

self.provides = "reboot"

function self.run()
    sleep(WAIT_TIME)
    print("Sending reboot signal...")
    os.queueEvent(libccd.E_REBOOT)
end