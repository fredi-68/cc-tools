dofile("/lib/shared/cls.lua")

DEBUG = 0
VERBOSE = 5
INFO = 10
WARNING = 20
ERROR = 50
CRITICAL = 100

local LEVEL = WARNING

Logger = make_class()

function Logger.init(self, name)
    self.name = name
end

function Logger.log(self, s, lvl)
    if lvl >= LEVEL then
        print("[" .. os.time() .. "][" .. tostring(lvl) .. "][" .. self.name .. "] " .. s)
    end
end

function Logger.debug(self, s)
    self.log(s, DEBUG)
end

function Logger.verbose(self, s)
    self.log(s, VERBOSE)
end

function Logger.info(self, s)
    self.log(s, INFO)
end

function Logger.warning(self, s)
    self.log(s, WARNING)
end

function Logger.error(self, s)
    self.log(s, ERROR)
end

function Logger.critical(self, s)
    self.log(s, CRITICAL)
end

logger = Logger("root")

function set_level(lvl)
    LEVEL = lvl
end