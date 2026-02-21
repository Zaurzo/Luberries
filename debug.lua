
-- Debug library management

local ok, debug = pcall(require, 'debug')

if not ok then -- Respect debug library stripping
    debug = { disabled = true }
else
    local shallow_copy = {} -- Do not use the global debug table

    for k, v in pairs(debug) do
        shallow_copy[k] = v
    end

    debug = shallow_copy
end

-- Use the most powerful getmetatable that is available 
debug.getmetatable = debug.getmetatable or getmetatable

-- Any functions stripped from the debug library will fallback to no-ops
setmetatable(debug, {
    __index = function(self, k)
        self[k] = function() end
    end
})

return debug
