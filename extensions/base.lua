
local luberry = require('luberries.luberry')
local base = luberry.create('_G')

base.tuple = require('luberries.classes.tuple')
base.enum = require('luberries.classes.enum')

function base.getmetafield(obj, field_name)
    local mt = getmetatable(obj)
    return mt and rawget(mt, field_name)
end

function base.prequire(name)
    local ok, module = pcall(require, name)
    if not ok then return nil, module --[[ error msg ]] end

    return module
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
    local debug = require('luberries.debug')
    local getinfo = debug.getinfo
    local traceback = debug.traceback

    function softerror(msg, level)
        if debug.no then
            io.stderr:write(msg)
            return
        end

        level = (level or 1) + 1

        local info = getinfo(level, 'Sl')

        if info and info.source and info.what ~= 'C' then
            msg = string.format(
                '%s:%d: %s',
                string.sub(info.source, 2),
                info.currentline,
                msg
            )
        else
            msg = tostring(msg)
        end

        io.stderr:write(traceback(msg, level))
    end
end

do
    local type = type
    local debug = require('luberries.debug')

    function base.isprotected(tbl)
        if debug.no then -- Use a less efficient method if we don't have the real debug.getmetatable
            local mt = getmetatable(tbl)

            if mt == nil then
                return false
            end

            return type(mt) ~= 'table' or not pcall(setmetatable, tbl, mt)
        end

        local mt = debug.getmetatable(tbl)
        return mt and rawget(mt, '__metatable') ~= nil
    end

    function base.iscallable(t)
        if type(t) == 'function' then
            return true
        end

        local mt = debug.getmetatable(t)

        if mt == nil or type(mt) ~= 'table' then
            return false
        end

        local mm_call = rawget(mt, '__call')
        return mm_call and type(mm_call) == 'function'
    end
end

local function ripairs_iterator(tbl, i)
    i = i - 1

    if i < 1 then
        return nil
    end

    return i, tbl[i]
end

function base.ripairs(tbl, start)
    start = start or #tbl
    return ripairs_iterator, tbl, start + 1
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

if not base.unpack then -- Lua 5.2+ compat
    base.unpack = table.unpack
end

if not base.warn then -- Lua 5.3 and below compat
    local warning_system_on = false

    function base.warn(...)
        local command = (...)

        if command == '@on' or command == '@off' then
            warning_system_on = command == '@on' and true or command == '@off' and false
            return
        end
            
        if not warning_system_on then return end

        local warning = ''

        for i = 1, select('#', ...) do
            local segment = select(i, ...)
            local t = type(segment)
            
            if t == 'string' or t == 'number' then
                warning = warning .. segment
            else
                error(string.format('bad argument %d (string expected, got %s)', i, t), 2)
            end
        end

        io.stderr:write('Lua warning: ' .. warning)
    end
end

-- xpcall compatibility shim
-- Some versions of Lua have a version of xpcall that doesn't forward arguments
do
    local forwards_args do
        local function verify(ok)
            forwards_args = ok
        end

        xpcall(verify, print, true)
    end

    if not forwards_args then
        local xpcall, select = xpcall, select
        local unpack = table.unpack or unpack

        function base.xpcall(func, err_handler, ...)
            local f, n = func, select('#', ...)

            -- If multiple arguments were passed, pack them into a table
            -- Otherwise, if only one argument was passed, just use that
            local args = n == 1 and (...) or n > 1 and { ... }

            if args then
                if n > 1 then
                    function f()
                        return func(unpack(args, 1, n))
                    end
                else
                    function f()
                        return func(args)
                    end
                end
            end
            
            return xpcall(f, err_handler)
        end
    end
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