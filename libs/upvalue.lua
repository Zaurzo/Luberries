
local debug = require('luberries.debug')

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
                ref = upvalue(obj, index, id)
                uv_map[ref._id] = ref
            end
        else
            ref = upvalue(obj)
            uv_map[ref._id] = ref
        end

        return ref
    end
end

local upvalue = {}

function upvalue.create(value)
    return get_upvalue_ref(value)
end

function upvalue.get(func, uv_index)
    local name = debug.getupvalue(func, uv_index)
    if not name then return end

    return get_upvalue_ref(func, uv_index), name
end

function upvalue.getall(func)
    local uvs = {}
    local n = 0

    for i = 1, math.huge do
        local uv = upvalue.get(func, i)
        if not uv then break end

        uvs[i] = uv
        n = i
    end

    return uvs, n
end

function upvalue.find(func, name)
    for i = 1, math.huge do
        local k = debug.getupvalue(func, i)
        if not k then break end

        if k == name then
            return i
        end
    end
end

function upvalue.swap(func1, uv_index1, func2, uv_index2)
    local uv1 = upvalue.get(func1, uv_index1)
    if not uv1 then return end

    local uv2 = upvalue.get(func2, uv_index2)
    if not uv2 then return end

    uv1:join(func2, uv_index2)
    uv2:join(func1, uv_index1)
end

return upvalue