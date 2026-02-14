
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

--#region __format metamethod

local function mm_format()
    local string_format = string.format
    local string_gsub = string.gsub
    local string_sub = string.sub
    local table_pack = table.pack
    local table_unpack = table.unpack

    function string.format(s, ...)
        local params = table_pack(...)
        local segment = 0

        s = string_gsub(s, '(%%[%g%d]+)', function(specifier)
            specifier = string_sub(specifier, 2)
            if specifier == '%' then return end

            segment = segment + 1
            
            local obj = params[segment]
            local mt = getrawmetatable(obj)

            if mt and mt.__format then
                local res = mt.__format(obj, specifier)
                if res == nil then return end

                params[segment] = res

                return '%s'
            end
        end)

        return string_format(s, table_unpack(params, 1, params.n))
    end
end

metamethods.format = metamethod(mm_format)

--#endregion

return metamethods