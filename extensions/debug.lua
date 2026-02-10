
local luberry = require('luberries.luberry')
local debug = luberry.create('debug')

debug.upvalue = require('luberries.libs.upvalue')

---Returns true if `func` was defined in Lua.
---@param func function The function to check.
---@return boolean
function debug.islua(func)
    return debug.getinfo(func, 'S').what == 'Lua'
end

---Returns an array of all declared parameters in `func`.
---@param func function The function to get the parameters of.
---@return table params
---@return number count The amount of parameters. `...` is only counted as one.
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

return debug