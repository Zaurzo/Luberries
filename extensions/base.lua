
local luberry = require('luberries.luberry')
local base = luberry.create('_G')

function base.prequire(name)
    local ok, module = pcall(require, name)
    return ok and module or nil
end

function base.requirecopy(name)
    local module = require(name)

    if type(module) ~= 'table' then
        return module
    end

    local shallow_copy = {}

    for k, v in pairs(module) do
        shallow_copy[k] = v
    end

    return shallow_copy
end

do
    local setmetatable = setmetatable
    local getmetatable = getmetatable

    function base.isprotected(tbl)
        local mt = getmetatable(tbl)
        if mt == nil then return false end

        if type(mt) ~= 'table' then
            return true
        end

        return not pcall(setmetatable, tbl, mt)
    end

    local getrawmetatable = require('debug').getmetatable
    local type = type

    function base.iscallable(t)
        if type(t) == 'function' then
            return true
        end

        local mt = getrawmetatable(t)
        return type(mt) == 'table' and type(mt.__call) == 'function'
    end
end

-- Returns all of `...` if there are any items - otherwise unpacks and returns all of `tbl`
local function resolve_success(tbl, ok, ...)
    if not ok or select('#', ...) < 1 then
        return table.unpack(tbl, 1, tbl.n)
    else
        return true, ...
    end
end

function base.pcallex(func, err_handler, on_success, ...)
    local res = table.pack(pcall(func, ...))

    if not res[1] then -- `func` had an error
        local err = err_handler and err_handler(res[2])
        return false, err or res[2]
    end

    if on_success then -- callback if `func` executed successfully
        return resolve_success(res, pcall(on_success, table.unpack(res, 2, res.n)))
    end

    return table.unpack(res, 1, res.n)
end

--#region Classes

local class_meta = {}
class_meta.__metatable = {}

function class_meta:new(...)
    local obj = {}
    local class = self.class

    if class.__ctor then
        class.__ctor(obj, ...)
    end

    return setmetatable(obj, class)
end

function class_meta:__index(k)
    local v = rawget(self.class, k)
    if v ~= nil then return end

    return k == 'new' and class_meta.new or nil
end

function class_meta:__newindex(k, v)
    rawset(self.class, k, v)
end

function class_meta:__pairs()
    return pairs(self.class)
end

function class_meta:__len()
    return #self.class
end

class_meta.__call = class_meta.new

function base.class(name, base)
    local class = {}
    class.__name = name

    if base then
        setmetatable(class, base)
    end

    return setmetatable({ class = class }, class_meta)
end

function base.instanceof(class, base)
    local mt = getmetatable(class)

    while mt ~= base do
        mt = getmetatable(mt)

        if not mt then
            return false
        end
    end

    return true
end

--#endregion

return base