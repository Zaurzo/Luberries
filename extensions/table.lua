
local luberry = require('luberries.luberry')
local table = luberry.create('table')
local _table = {}

local getmetafield do
    local getrawmetatable = require('debug').getmetatable

    function getmetafield(obj, field_name)
        local mt = getrawmetatable(obj)
        return mt and mt[field_name]
    end
end

for k, v in pairs(require('table')) do
    _table[k] = v
end

function table.inherit(to, from)
    for k, v in pairs(from) do
        if to[k] == nil then
            to[k] = v
        end
    end

    return to
end

function table.merge(to, from, start_index, end_index)
    local mm_merge = getmetafield(to, '__merge')
    if mm_merge then mm_merge(to, from, start_index, end_index) return to end

    if start_index then
        end_index = end_index or #from

        for i = start_index, end_index do
            to[i] = from[i]
        end

        return to
    end

    for k, v in pairs(from) do
        to[k] = v
    end

    return to
end

function table.assign(to, ...)
    local mm_assign = getmetafield(to, '__assign')
    if mm_assign then mm_assign(to, ...) return to end

    for i = 1, select('#', ...) do
        to[i] = select(i, ...)
    end

    return to
end

function table.packrange(start_pos, end_pos, ...)
    local pack = {}
    local n = 0

    for i = start_pos, end_pos do
        n = n + 1
        pack[n] = select(i, ...)
    end

    pack.n = n

    return pack
end

function table.slice(tbl, start_pos, end_pos)
    if start_pos < 1 then error('start position lower than 1', 2) end
    
    if start_pos > end_pos then
        error('start position greater than end position', 2)
    end

    local slice = {}
    local n = 0

    for i = start_pos, end_pos do
        n = n + 1
        slice[n] = tbl[i]
    end

    return slice
end

function table.retain(tbl, start_pos, end_pos)
    if start_pos < 1 then error('start position lower than 1', 2) end
    
    if start_pos > end_pos then
        error('start position greater than end position', 2)
    end

    local mm_retain = getmetafield(tbl, '__retain')
    if mm_retain then mm_retain(tbl, start_pos, end_pos) return tbl end

    _table.move(tbl, start_pos, end_pos, 1, tbl)

    for i = (end_pos - start_pos) + 2, #tbl do
        tbl[i] = nil
    end

    return tbl
end

function table.reindex(tbl)
    local sequence, n = {}, 0

    for k, v in pairs(tbl) do
        if type(k) == 'number' then
            n = n + 1
            sequence[n] = v
            tbl[k] = nil
        end
    end

    for i = 1, n do
        tbl[i] = sequence[i]
    end

    return tbl
end

return table