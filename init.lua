
--[[---------------------------------
    Luberries (Stem)
-----------------------------------]]

local luberries = {}

--#region Build Stem

local open = require('luberries.open')

-- Extensions
luberries.base          = open('extensions.base', '_G')
luberries.math          = open('extensions.math', 'math')
luberries.string        = open('extensions.string', 'string')
luberries.table         = open('extensions.table', 'table')
luberries.debug         = open('extensions.debug', 'debug')

-- New libraries
luberries.args          = open('libs.args')

-- Appliers
luberries.metamethods   = open('libs.metamethods')

--#endregion

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