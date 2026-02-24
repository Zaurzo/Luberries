
--[[---------------------------------
    Luberries (Stem)
-----------------------------------]]

local luberries = {}
local open = require('luberries.open')

-- Extensions
luberries.base          = open('luberries.extensions.base', '_G')
luberries.table         = open('luberries.extensions.table', 'table')
luberries.debug         = open('luberries.extensions.debug', 'debug')

-- New libraries
luberries.args          = open('luberries.libs.args')

-- Appliers
luberries.metamethods   = open('luberries.libs.metamethods')

if require('luberries.debug').disabled then
    print('[Luberries] "debug" library is missing. Some features may be limited, or even made no-ops.')
end

function luberries.environment()
    local env = luberries.base

    if setfenv then
        setfenv(2, env)
    end

    return env
end

return luberries