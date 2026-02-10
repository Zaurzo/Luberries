
local luberry = require('luberries.luberry')
local table = luberry.create('table')

function table.inherit(to, from)
    for k, v in pairs(from) do
        if to[k] == nil then
            to[k] = v
        end
    end

    return to
end

function table.merge(to, from, start_index, end_index)
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
    for i = 1, select('#', ...) do
        to[i] = select(i, ...)
    end

    return to
end

return table