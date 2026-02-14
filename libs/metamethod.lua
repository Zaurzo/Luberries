
local luberry = require('luberries.luberry')
local metamethods = luberry.create()

local metamethod do
    local applier_meta = {}

    function applier_meta:__call()
        if self.applied then return end

        self.apply()
        self.applied = true
    end

    function metamethod(apply)
        return setmetatable({ apply = apply }, applier_meta)
    end
end

local getmetafield do
    local getrawmetatable = require('debug').getmetatable

    function getmetafield(obj, field_name)
        local mt = getrawmetatable(obj)
        return mt and mt[field_name]
    end
end

--#region __type metamethod

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
---@type fun(use_name: boolean)
---@diagnostic disable-next-line
metamethods.type = metamethod(mm_type)

--#endregion

--#region __insert metamethod

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
---@type function
---@diagnostic disable-next-line
metamethods.insert = metamethod(mm_insert)

--#endregion

--#region __remove metamethod

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
---@type function
---@diagnostic disable-next-line
metamethods.remove = metamethod(mm_remove)

--#endregion

--#region __move metamethod

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
---@type function
---@diagnostic disable-next-line
metamethods.move = metamethod(mm_move)

--#endregion

--#region __format metamethod

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
metamethods.format = metamethod(mm_format)

--#endregion

return metamethods