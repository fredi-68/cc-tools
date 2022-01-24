-- frednet service

function self.run()
    l = libfredio.EventLoop()
    l.task(libfrednet.connect())
    l.run_forever()
 end