
local _ENV = setmetatable({}, { __index = _G })

if _G.setfenv then -- Lua 5.1 compat
    _G.setfenv(1, _ENV)
end

tuple = require('luberries.classes.tuple')
enum = require('luberries.classes.enum')

function getmetafield(obj, field_name)
    local mt = getmetatable(obj)
    return mt and rawget(mt, field_name)
end

function prequire(name)
    local ok, module = pcall(require, name)

    if not ok then
        return nil, module -- error msg
    end

    return module
end

function requirecopy(name)
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
        if debug.disabled then
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

    function isprotected(tbl)
        if debug.disabled then
            -- Use a less efficient (but reliable) method 
            -- if we don't have the real debug.getmetatable

            local mt = getmetatable(tbl)

            if mt == nil then
                return false
            end

            return type(mt) ~= 'table' or not pcall(setmetatable, tbl, mt)
        end

        local mt = debug.getmetatable(tbl)
        return mt and rawget(mt, '__metatable') ~= nil
    end

    function iscallable(t)
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

local inext = ipairs({})

function xipairs(tbl, start)
    return inext, tbl, (start or 1) - 1
end

local function ripairs_iterator(tbl, i)
    i = i - 1

    if i < 1 then
        return nil
    end

    return i, tbl[i]
end

function ripairs(tbl, start)
    return ripairs_iterator, tbl, (start or #tbl) + 1
end

local function resolve_success(tbl, ...)
    if select('#', ...) < 1 then
        return table.unpack(tbl, 1, tbl.n)
    else
        return true, ...
    end
end

do
    local table_unpack = table.unpack or unpack

    local function table_pack(...)
        return { [0] = select('#', ...), ... }
    end

    function pcallex(func, err_handler, on_success, ...)
        local res = table_pack( xpcall(func, err_handler, ...) )

        if res[1] and on_success then
            --[[
                Calls on_success if func executed successfully. The success callback is 
                passed the return values of func; If the callback returns anything, 
                pcallex will return those instead of func's actual returns.
            --]]

            return resolve_success(
                res,
                on_success(table_unpack(res, 2, res[0]))
            )
        end

        return table_unpack(res, 1, res[0])
    end
end

if not unpack then -- Lua 5.2+ compat
    unpack = table.unpack
end

if not warn then -- Lua 5.3 and below compat
    local warning_system_on = false
    local select = select
    local type = type
    local error = error

    function warn(...)
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

if not setfenv then -- Lua 5.2+ compat
    local debug = require('luberries.debug')

    local function resolve_func(f, set)
        local info, level

        if type(f) ~= 'function' then
            level = f + 2
            info = debug.getinfo(level, 'fS')
            
            if not info or info.what == 'C' then
                error('invalid level', 3)
            end

            f = info.func
        else
            info = debug.getinfo(f, 'S')

            if info.what == 'C' then
                if set then
                    error('cannot change environment of given object', 3)
                else
                    return nil
                end
            end
        end

        if not info.source or info.source == '=?' then
            error('debug info was stripped', 3)
        end

        return f, level
    end

    ---@param looker function
    local function find_env(looker, f)
        for i = 1, math.huge do
            local k, v = looker(f, i)
            if not k then break end

            if k == '_ENV' then
                return v, i
            end
        end
    end

    function setfenv(f, env)
        if debug.disabled then
            return nil
        end

        local func, level = resolve_func(f, true)
        local _, index

        if level then -- change in-scope _ENV
            _, index = find_env(debug.getlocal, level)

            if index then
                debug.setlocal(level - 1, index, env)
                return func
            end
        end

        _, index = find_env(debug.getupvalue, func)

        if index and func then
            debug.upvaluejoin(func, index, function() return env end, 1) -- replace upvalue
            return func
        end

        return nil
    end

    function getfenv(f)
        if debug.disabled then
            return _G
        end

        local func, level = resolve_func(f)

        if not func then
            return _G
        end

        local env

        if level then
            env = find_env(debug.getlocal, level)
        end

        if not env then
            env = find_env(debug.getupvalue, func)
        end

        return env or _G
    end
end

do
    local forwards_args do
        local function verify(ok)
            forwards_args = ok
        end

        xpcall(verify, print, true)
    end

    if not forwards_args then
        xpcall = require('luberries.extensions.base.xpcall')
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
    return rawget(self.class, k)
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

function class(name, base)
    local class = {}
    class.__name = name

    if base then
        setmetatable(class, base)
    end

    return setmetatable({ class = class }, class_meta)
end

function instanceof(class, base)
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

return _ENV