
local luberries = {}

-- Extensions
luberries.base          = require('luberries.extensions.base')
luberries.table         = require('luberries.extensions.table')
luberries.debug         = require('luberries.extensions.debug')

-- New libraries
luberries.args          = require('luberries.libs.args')

-- Appliers
luberries.metamethods   = require('luberries.libs.metamethods')

if require('luberries.debug').no then
    luberries.base.warn('"debug" library is missing. Some features in Luberries may be limited, or even made no-ops.')
end

function luberries.environment()
    local env = luberries.base

    if env.setfenv then
        env.setfenv(2, env)
    end

    return env
end

return luberries