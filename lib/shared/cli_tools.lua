dofile("/lib/shared/cls.lua")

COUNT = 1
STORE = 2
STORE_TRUE = 3

local function _gc(s, i)
    if i == nil then
        i = 1
    end
    return string.sub(s, i, i)
end

ArgumentParser = make_class()

function ArgumentParser.init(self, name, description)
    assert(not (name == nil))
    self.name = name
    self.description = description or ""

    self._f = {}
    self.args = {}
    self.remaining = {}
end

function ArgumentParser.add_flag(self, name, flag, _type)
    if _type == nil then
        _type = STORE_TRUE 
    end
    if #flag > 1 then
        error("flag '" .. flag .. "' must be one character")
    end
    if not (self._f[flag] == nil) then
        error("flag '" .. flag .. "' already exists")
    end
    self._f[flag] = { name, _type }
end

function ArgumentParser.usage(self)
    print("Usage:", self.name, "[args...]")
    for f, p in pairs(self._f) do
        name, _type = table.unpack(p)
        if _type == STORE then
            _type = "store"
        elseif _type == COUNT then
            _type = "count"
        else
            _type = "store_true"
        end
        print("  -" .. f .. ":", name, "(" .. _type .. ")")
    end
end

function ArgumentParser.help(self)
    print(description)
    self.usage()
end

function ArgumentParser.error(self, msg)
    print(msg)
    self.usage()
    error()
end

function ArgumentParser.parse(self)
    local ind = 1
    local flags_done = false
    while ind <= #args do
        a = args[ind]
        if _gc(a) == "-" then
            if flags_done then
                self.error("Cannot use flags here: " .. a)
            end
            for j = 2, #a do
                local f = _gc(a, j)
                if self._f[f] == nil then
                    self.error("Unknown flag: -" .. f)
                end
                name, _type = table.unpack(self._f[f])
                if self.args[name] == nil then
                    if _type == COUNT then
                        self.args[name] = 1
                    elseif _type == STORE then
                        self.args[name] = args[ind+1]
                        ind = ind + 1
                    else
                        self.args[name] = true
                    end
                else
                    if _type == COUNT then
                        self.args[name] = self.args[name] + 1
                    elseif _type == STORE then
                        if type(self.args[name]) == "table" then
                            table.insert(self.args[name], args[ind+1])
                        else
                            self.args[name] = { self.args[name], args[ind+1]}
                        end
                        ind = ind + 1
                    end
                end
            end
        else
            flags_done = true
            table.insert(self.remaining, a)
        end
        ind = ind + 1
    end
end