
local luberries = {}

-- Extensions
luberries.base          = require('luberries.extensions.base')
luberries.table         = require('luberries.extensions.table')
luberries.debug         = require('luberries.extensions.debug')

-- New libraries
luberries.args          = require('luberries.libs.args')

-- Appliers
luberries.compat        = require('luberries.libs.compat')
luberries.metamethods   = require('luberries.libs.metamethods')

return luberries