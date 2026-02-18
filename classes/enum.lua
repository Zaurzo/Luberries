
---A class representing an enum.
---@class enum
local enum = {}

enum.__index = enum
enum.__type = 'enum' -- utilize custom type metamethod if it's enabled
enum.__name = 'enum'

local function build_table(values, tbl)
    local items, n = {}, 0

    for k, v in pairs(tbl) do
        n = n + 1
        items[n] = values and v or k
    end

    items.n = n

    return items
end

function enum:getnames()
    local names = build_table(false, self)
    return names
end

function enum:getvalues()
    local values = build_table(true, self)
    return values
end

function enum:unpack()
    local values = build_table(true, self)
    return table.unpack(values, 1, values.n)
end

local function enum__newindex()
    error('cannot add to an existing enum', 2)
end

return function(tbl)
    local enm, n = {}, 0
    local lookup = setmetatable({}, enum)

    for k, v in pairs(tbl) do
        local name, value = k, v

        if type(k) == 'number' then
            name, value = v, k
        end

        if type(name) ~= 'string' then
            error('enum name is not a string', 2)
        end

        if type(value) ~= 'number' then
            error(string.format('value for enum \'%s\' is not a number', name), 2)
        end

        if enm[name] then
            error(string.format('enum clash (%s)', name), 2)
        end

        n = n + 1
        enm[name] = value
        lookup[value] = name
    end

    local mt = {
        __index = lookup,
        __newindex = enum__newindex,
        __len = function() return n end
    }

    return setmetatable(enm, mt)
end
