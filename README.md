# 🫐 Luberries
Luberries is a pure-Lua library with the goal of providing useful or neat extensions/new libraries. Instead of modifying the original modules, each extension is a proxy wrapper to them. Most extensions or features do not rely on each other, so you should be able to separate them from Luberries without them erroring with little to no modifications, if you need to; however, it is recommended to use the main library.

Some functions in this library utilize the `debug` library. The library respects the decision to strip or modify the debug library, so some features may be limited or turned into no-ops if you do this. I could avoid this entirely by making a C module, but I wish to keep the library pure Lua.

Generally, no added function does type checking, unless absolutely needed. This is to maximize performance. Additionally, I prefer that all function names follow Lua's style of completely lowercase. Local variable names do not need to follow this standard.

This library is a **work-in-progress**. I add things to this as I go.

## Why The Name?
The name "Luberries" is a mix of "Lua" and "Berries". Berries are small, juicy fruits, usually with multiple bundled together. I was thinking of grapes when I came up with this name. Imagine this module is the stem, and each extension or new library is a berry part of that stem that you can pick from.

# How To Use
First, you require the library as normal.
```lua
local luberries = require('luberries')
```
From here, you should use the extensions/new libraries directly from this table. Although you can directly require them, it is recommended to use them from the `luberries` root table.
```lua
--- Intended way:
local luberries = require('luberries')
local table = luberries.table ---@module "table"

-- Not recommended way:
local table = require('luberries.extensions.table')
```
You may notice the `---@module` annotation at the end of the `table` local variable. This is to tell LuaLS that it should treat it as the actual `table` module. Since these extensions are supposed to be proxy wrappers to the original modules, all LuaLS annotations for the extension functions are defined under said modules. If you have LuaLS, it is recommended to add this.

Luberries also provides new utility libraries. The module annotation is not needed for these, as they are not extensions.
```lua
-- Example usage of args library
local luberries = require('luberries')
local args = luberries.args

print(args.count(1, 2, 3)) -- 3
```

Everything in Luberries, by default, does not mutate any existing library/module. The recommended way is to use the extensions/new libraries provided directly from the `luberries` table. However; each extension is callable, and will patch their associated functions into the original module they are extending if you really need to:
```lua
local luberries = require('luberries')

luberries.table()
-- Now all of the functions in the table extension are added to the real table module.
```
You may also pass in names to the functions you specifically need:
```lua
local luberries = require('luberries')

luberries.table('assign', 'packrange', 'merge') 
-- Now only table.assign, table.packrange, and table.merge were added to the real table module.
```
An alternative way is just setting the table module to the extension:
```lua
local luberries = require('luberries')

table = luberries.table
-- Now _G.table is luberries.table
```

The `luberries.base` table is an extension to the `_G` environment. The recommended way to use it is as follows:
```lua
local luberries = require('luberries')
local _ENV = luberries.environment()
```
The `luberries.environment` function returns `luberries.base`, so that _ENV points to it. For Lua 5.1, or runtimes without _ENV, it will call `setfenv` and set the current environment to `luberries.base`.