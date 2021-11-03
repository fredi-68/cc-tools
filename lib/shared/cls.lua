local function _construct_object_body(cls)
    local obj = {}
    for key, f in pairs(cls) do
        if type(f) == "function" then
            obj[key] = function (...)
                return f(obj, ...)
            end
        else
            obj[key] = f
        end
    end
    return obj
end

--[[
    Construct a new class.

    cls should be a table containing a constructor, methods and class attributes.
]]
function make_class()
    
    local cls = {}
    setmetatable(cls, {__call = function (_, ...)
        obj = _construct_object_body(cls)
        if obj.init ~= nil then
            obj.init(...)
        end 
        return obj
    end
    })
    return cls
end