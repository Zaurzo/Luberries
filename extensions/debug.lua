
--#region Setup Extension Base

local debug = {} do
    local ok, tab = pcall(require, 'debug')

    if ok then
        for k, v in pairs(tab) do
            debug[k] = v
        end
    end

    ok, tab = pcall(require, 'luberries.libs.upvalue')

    if ok then
        debug.upvalue = tab
    end
end

--#endregion

function debug.getmetafield(obj, field_name)
    local mt = debug.getmetatable(obj)
    return mt and rawget(mt, field_name)
end

function debug.tostring(obj)
    local mt = debug.getmetatable(obj)
    debug.setmetatable(obj, nil)

    local str = tostring(obj)
    debug.setmetatable(obj, mt)

    return str
end

function debug.islua(func)
    return debug.getinfo(func, 'S').what == 'Lua'
end

function debug.getparams(func)
    if not debug.islua(func) then
        error('cannot get parameters of a non-Lua function', 2)
    end

    local params = {}
    local count = 0

    for i = 1, math.huge do
        local name = debug.getlocal(func, i)
        if not name then break end

        count = i
    end

    if debug.getinfo(func, 'u').isvararg then
        count = count + 1
        params[count] = '...'
    end

    return params, count
end

function debug.currentf()
    local info = debug.getinfo(2, 'f')
    return info and info.func or nil
end

return debug