--#import "/lib/shared/cls.lua"

Future = make_class()

function Future.init(self)
    
end

function Future.is_done(self)
    return not (self.result == nil and self.error == nil)
end

function Future.set_result(self, res)
    self.result = res
end

function Future.set_error(self, error)
    self.error = error
end

function Future.wait_for_result(self)
    coroutine.yield()
    return self.error == nil and self.result or self.error
end