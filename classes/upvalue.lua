
local debug = require('luberries.debug')

---A class representing an upvalue cell.
---@class upvalue
local upvalue = {}
upvalue.__index = upvalue
upvalue.__name = 'upvalue'
upvalue.__type = 'upvalue'

---Assigns `value` to this upvalue.
---@param value any The value to assign.
function upvalue:setvalue(value)
    self.__setupvalue(value)
end

---Returns the current value of this upvalue.
---@return any value
function upvalue:getvalue()
    return self.__getupvalue()
end

---Joins this upvalue to `func` in its upvalue slot `uv_index`.
---@param func function The function to join.
---@param uv_index number The index of the upvalue to replace.
function upvalue:join(func, uv_index)
    debug.upvaluejoin(func, uv_index, self.__getupvalue, 1)
end

---Returns true if this upvalue is from Lua.
---@return boolean
function upvalue:islua()
    return self._is_lua
end

---Returns the pointer of this upvalue.
---@return string
function upvalue:getpointer()
    return string.format('%p', self._id)
end

function upvalue:__eq(uv2)
    if rawequal(self, uv2) then
        return true
    end

    return debug.getmetatable(uv2) == upvalue and uv2._id == self._id
end

function upvalue:__tostring()
    local ok, value_str = pcall(tostring, self:getvalue())

    if ok then
        return 'upvalue (' .. value_str .. ')'
    end

    return string.format('upvalue: %p', self._id)
end

return function(func, uv_index, uv_id)
    local self = {}

    self._is_lua = not uv_index or debug.getinfo(func, 'S').what == 'Lua'

    if self._is_lua then
        local variable = func

        function self.__setupvalue(value)
            variable = value
        end

        function self.__getupvalue()
            return variable
        end

        if uv_index then
            debug.upvaluejoin(self.__setupvalue, 1, func, uv_index)
            debug.upvaluejoin(self.__getupvalue, 1, func, uv_index)
        end

        self._id = uv_id or debug.upvalueid(self.__getupvalue, 1)
    else
        function self.__setupvalue(value)
            debug.setupvalue(func, uv_index, value)
        end

        function self.__getupvalue()
            local _, value = debug.getupvalue(func, uv_index)
            return value
        end

        self._id = uv_id
    end

    return setmetatable(self, upvalue)
end