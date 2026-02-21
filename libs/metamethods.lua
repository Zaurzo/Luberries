
local luberry = require('luberries.luberry')
local applier = require('luberries.lazyapplier')

local metamethods = luberry.create()

--#region Internal Helpers

local getmetafield do
    local getrawmetatable = require('luberries.debug').getmetatable

    function getmetafield(obj, field_name)
        local mt = getrawmetatable(obj)
        return mt and mt[field_name]
    end
end

local function methodexists(method_name, tester)
    local tbl, exists
    
    tbl = setmetatable({}, {
        [method_name] = function()
            exists = true
        end
    })

    pcall(tester, tbl)

    return exists
end

--#endregion

local function mm_type(use_name)
    local _type = type
    local select = select

    function type(...)
        if select('#', ...) < 1 then
            return 'no value'
        end

        local obj = ...
        local type_name = getmetafield(obj, '__type') or (use_name and getmetafield(obj, '__name'))

        return type_name or _type(obj)
    end
end

--- A metamethod (`__type`) that changes the return result of `type()`
metamethods.type = applier(mm_type)

local function mm_ipairs()
    if methodexists('__ipairs', ipairs) then return false end

    local _ipairs = ipairs

    function ipairs(t)
        local iterator = getmetafield(t, '__ipairs') or _ipairs
        return iterator(t)
    end
end

--- Adds the `__ipairs` metamethod if it doesn't exist already
metamethods.ipairs = applier(mm_ipairs)

local function mm_pairs()
    if methodexists('__pairs', pairs) then return false end

    local _pairs = pairs

    function pairs(t)
        local iterator = getmetafield(t, '__pairs') or _pairs
        return iterator(t)
    end
end

--- Adds the `__pairs` metamethod if it doesn't exist already
metamethods.pairs = applier(mm_pairs)

local function mm_setmetatable()
    local _setmetatable = setmetatable

    function setmetatable(tbl, mt)
        local set = getmetafield(tbl, '__setmetatable')

        if set then
            mt = set(tbl, mt) or mt
        end

        return _setmetatable(tbl, mt)
    end
end

--- A metamethod (`__setmetatable`) that changes the metatable set by `setmetatable`.
metamethods.setmetatable = applier(mm_setmetatable)

local function mm_getmetatable()
    local _getmetatable = getmetatable

    function getmetatable(tbl)
        local get = getmetafield(tbl, '__getmetatable') or _getmetatable
        return get(tbl)
    end
end

--- A metamethod (`__getmetatable`) that changes what `getmetatable` returns.
--- (Function version of `__metatable`)
metamethods.getmetatable = applier(mm_getmetatable)

local function mm_insert()
    local table_insert = table.insert
    table.rawinsert = table_insert

    function table.insert(tbl, value, ...)
        local insert = getmetafield(tbl, '__insert')
        if not insert then return table_insert(tbl, value, ...) end

        local pos = value

        if select('#', ...) > 0 then -- value is used as position
            value = ...
        else
            pos = #tbl + 1
        end

        return insert(tbl, value, pos)
    end
end

--- A metamethod (`__insert`) that overrides the behavior of `table.insert`
metamethods.insert = applier(mm_insert)

local function mm_remove()
    local table_remove = table.remove
    table.rawremove = table_remove

    function table.remove(tbl, pos)
        local remove = getmetafield(tbl, '__remove')
        if not remove then return table_remove(tbl, pos) end

        return remove(tbl, pos or #tbl)
    end
end

--- A metamethod (`__remove`) that overrides the behavior of `table.remove`
metamethods.remove = applier(mm_remove)

local function mm_move()
    local table_move = table.move
    table.rawmove = table_move

    function table.move(tbl, from, to, dest, dest_tbl)
        local move = getmetafield(tbl, '__move')
        if not move then return table_move(tbl, from, to, dest, dest_tbl) end

        return move(tbl, from, to, dest, dest_tbl)
    end
end

--- A metamethod (`__move`) that overrides the behavior of `table.move`
metamethods.move = applier(mm_move)

local function mm_format()
    local string_format = string.format
    local table_concat = table.concat
    local string_sub = string.sub
    local table_pack = table.pack
    local table_unpack = table.unpack
    local select = select
    local string_byte = string.byte
    local string_find = string.find

    local function has_custom_format(...)
        local n = select('#', ...)
        if n < 1 then return false end

        for i = 1, n do
            local obj = select(i, ...)

            if getmetafield(obj, '__format') then
                return true
            end
        end

        return false
    end

    function string.format(s, ...)
        if not has_custom_format(s, ...) then
            return string_format(s, ...)
        end
        
        local params = table_pack(...)
        local buffer, buffer_n = {}, 0

        local pos, last_pos = 1, 1
        local len, segment = #s, 0

        while pos <= len do
            if string_byte(s, pos, pos) == 37 then -- 37 is '%'
                if string_byte(s, pos + 1, pos + 1) == 37 then
                    pos = pos + 2
                else
                    if last_pos < pos then
                        buffer_n = buffer_n + 1
                        buffer[buffer_n] = string_sub(s, last_pos, pos - 1)
                    end

                    local start_pos, end_pos, spec = string_find(s, '(%%[%g%d]+)', pos)

                    buffer_n = buffer_n + 1

                    if start_pos and end_pos then
                        segment = segment + 1
                        pos = end_pos + 1

                        local obj = params[segment]
                        local format = getmetafield(obj, '__format')

                        if format then
                            local res = format(obj, string_sub(spec, 2))

                            if res ~= nil then
                                params[segment] = res
                                buffer[buffer_n] = '%s'
                            else
                                buffer[buffer_n] = spec
                            end
                        else
                            buffer[buffer_n] = spec
                        end
                    else
                        pos = pos + 1
                    end

                    last_pos = pos
                end
            else
                pos = pos + 1
            end
        end

        if last_pos <= len then
            buffer_n = buffer_n + 1
            buffer[buffer_n] = string_sub(s, last_pos)
        end

        return string_format(table_concat(buffer), table_unpack(params, 1, params.n))
    end
end

--- A metamethod (`__format`) that determines the format result when used in `string.format`.
---@type function
---@diagnostic disable-next-line
metamethods.format = applier(mm_format)

return metamethods