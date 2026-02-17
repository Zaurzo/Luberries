
local luberry = require('luberries.luberry')
local applier = require('luberries.internal.lazy_applier')

local compat = luberry.create()

local function packing()
    unpack = table.unpack or unpack

    if table.pack then return end

    local select = select

    function table.pack(...)
        return { n = select('#', ...), ... }
    end
end

--- Adds `table.pack`, `table.unpack`, and `unpack` if they do not exist 
---@type function
---@diagnostic disable-next-line
compat.packing = applier(packing)

return compat