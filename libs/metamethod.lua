
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

local getrawmetatable = require('debug').getmetatable

--#region __type metamethod

local function mm_type()
    local _type = type
    local select = select

    function type(...)
        if select('#', ...) < 1 then
            return 'no value'
        end

        local obj = ...
        local mt = getrawmetatable(obj)

        if mt and mt.__type then
            return mt.__type(obj)
        end
        
        return _type(obj)
    end
end

metamethods.type = metamethod(mm_type)

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
            local mt = getrawmetatable(obj)

            if mt and mt.__format then
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
                        local mt = getrawmetatable(obj)

                        if mt and mt.__format then
                            local res = mt.__format(obj, string_sub(spec, 2))

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

metamethods.format = metamethod(mm_format)

--#endregion

return metamethods