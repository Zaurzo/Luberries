# Luberries
Luberries is a library for Lua that provides useful extensions to the default Lua libraries.

This library is a **work-in-progress**. I add things to this as I go.

## Example Usage
This example isn't particularly useful, but it demonstrates how the library should be used.
```lua
local luberries = require('luberries')
local table = luberries.table ---@module "table"

local numbers = { 1, 2, 3, 4, 5 }
table.assign(numbers, 6, 7, 8)

for k, v in ipairs(numbers) do
    print(k, v)
end
```
The `---@module` tells LuaLS that it should treat the `table` local variable as the actual table module. Luberry extensions are basically proxies to the original modules they are extending, so you should always add this annotation.
### Output
```
1       6
2       7
3       8
4       4
5       5
```

## Example Usage 2
```lua
local luberries = require('luberries')
local _ENV = luberries.base

local tbl = setmetatable({}, { __metatable = false })
print(isprotected(tbl))
```
### Output
```
true
```