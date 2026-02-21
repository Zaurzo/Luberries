
local luberries = {}

-- Extensions
luberries.base          = require('luberries.extensions.base')
luberries.table         = require('luberries.extensions.table')
luberries.debug         = require('luberries.extensions.debug')

-- New libraries
luberries.args          = require('luberries.libs.args')

-- Appliers
luberries.metamethods   = require('luberries.libs.metamethods')

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