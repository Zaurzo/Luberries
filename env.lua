
local ok, debug = pcall(require, 'debug')
if not ok then error('debug library is missing', 2) end

local M = {}
M.debug = {}

local env_helper, env_registry do

    env_registry = setmetatable({}, { __mode = 'k' }) -- less than ideal

    ---@param using function
    ---@param f function|number
    ---@param stop_index number
    local function search(using, f, stop_index)
        for i = 1, stop_index or math.huge do
            local name, value = using(f, i)
            if not name then break end

            if name == '_ENV' then
                return value, i
            end
        end
    end

    ---@param func function|number
    ---@param setting boolean
    function env_helper(func, setting, check_scope)
        local info, level

        if type(func) == 'number' then
            level = func + 2
            info = debug.getinfo(level, 'Sfu')

            if not info or info.what == 'C' then
                error('invalid level', 3)
            end

            func = info.func
        else
            info = debug.getinfo(func, 'Su')

            if info.what == 'C' then
                if setting then
                    error("'setfenv' cannot change environment of given object", 3)
                else
                    return func, env_registry[func] or _G, 0
                end
            end
        end

        if not info.source or info.source == '=?' then
            error('debug info was stripped', 3)
        end

        if level and check_scope then
            local env, index = search(debug.getlocal, level + 1)

            if index then
                return func, env, index, level - 1
            end
        end

        return func, search(debug.getupvalue, func, info.nups)
    end

end

local type = type

local function check_type(v, type_name, argn)
    local t = type(v)
    if t == type_name then return end

    local info = debug.getinfo(2, 'n')
    local name = (info and info.name) or '?'
    local msg = 'bad argument #%d to \'%s\' (%s expected, got %s)'

    error(string.format(msg, argn, name, type_name, t), 3)
end

if setfenv then
    M.setfenv = setfenv
    M.getfenv = getfenv
    M.debug.setfenv = debug.setfenv
    M.debug.getfenv = debug.getfenv

    return M
else
    function M.setfenv(f, env)
        check_type(env, 'table', 2)

        if type(f) ~= 'function' then
            check_type(f, 'number', 1)
        end

        local func, _, index = env_helper(f, true)

        -- Replace _ENV upvalue
        debug.upvaluejoin(func, index, function() return env end, 1)

        return func
    end

    function M.getfenv(f)
        if type(f) ~= 'function' then
            check_type(f, 'number', 1)
        end
        
        local _, env = env_helper(f)
        return env or _G
    end

    local type_blacklist = {
        ['boolean'] = true,
        ['string'] = true,
        ['number'] = true,
        ['nil'] = true
    }

    local setfenv = M.setfenv

    function M.debug.setfenv(obj, env)
        check_type(env, 'table', 2)

        local t = type(obj)

        if type_blacklist[t] then
            error("'setfenv' cannot change environment of given object", 2)
        end

        if t == 'function' then
            local info = debug.getinfo(obj, 'S')

            if info.what == 'C' then
                env_registry[obj] = env
                return obj
            elseif not info.source or info.source == '=?' then
                error('debug info was stripped', 2)
            end
        else
            env_registry[obj] = env
            return obj
        end

        return setfenv(obj, env)
    end

    function M.debug.getfenv(f)
        if type(f) == 'number' then
            return nil
        end

        local _, env = env_helper(f)
        return env or _G
    end
end

function M.getenvironment(level)
    if level == nil then
        level = 1
    end

    check_type(level, 'number', 1)

    local _, env = env_helper(level, false, true)
    return env
end

return M
