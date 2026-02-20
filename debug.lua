
-- Debug library management

local ok, debug = pcall(require, 'debug')

if not ok then -- Respect debug library stripping
    debug = { no = true }
    debug.getmetatable = getmetatable

    setmetatable(debug, {
        __index = function(self, k)
            self[k] = function() end
        end
    })
else -- Do not use the global table
    local shallow_copy = {}

    for k, v in pairs(debug) do
        shallow_copy[k] = v
    end

    debug = shallow_copy
end

return debug
