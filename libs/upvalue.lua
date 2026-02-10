
local debug = require('debug')

local get_upvalue_ref do
    local uv_map = setmetatable({}, { __mode = 'v' })
    local upvalue = require('luberries.classes.upvalue')

    ---@param obj function|any
    function get_upvalue_ref(obj, index)
        local ref

        if index then
            local id = debug.upvalueid(obj, index)
            local cached = uv_map[id]

            if cached then
                ref = cached
            else
                ref = upvalue:new(obj, index)
                uv_map[ref._id] = ref
            end
        else
            ref = upvalue:new(obj)
            uv_map[ref._id] = ref
        end

        return ref
    end
end

local upvalue = {}

function upvalue.get(func, uv_index)
    local name = debug.getupvalue(func, uv_index)
    if not name then return end

    return get_upvalue_ref(func, uv_index), name
end

return upvalue