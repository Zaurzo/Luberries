---@meta debug

---A sub-library for upvalue management.
debug.upvalue = {}

---Returns the field in `obj`'s metatable with the given name.
---This ignores `__metatable`. 
function debug.getmetafield(obj, field_name) end

---Returns the string literal of `obj`.
---This ignores `__metatable`. 
function debug.tostring(obj) end

---Returns true if `func` was defined in Lua.
---@param func function The function to check.
---@return boolean
function debug.islua(func) end

---Returns an array of all declared parameters in `func`.
---@param func function The function to get the parameters of.
---@return table params
---@return number count The amount of parameters. `...` is only counted as one.
function debug.getparams(func) end

---Creates a new standalone upvalue.
---@param value any The value to create the upvalue with.
---@return upvalue uv
function debug.upvalue.create(value) end

---Returns the identity of upvalue `uv_index` in `func`.
---@param func function The function to get the upvalue of.
---@param uv_index number The index of the upvalue to get.
---@return upvalue? uv
---@return string? name The debug name of the upvalue in `func`.
function debug.upvalue.get(func, uv_index) end

---Returns a list of identities of all upvalues in `func`.
---@param func function The function to get the upvalue of.
---@return upvalue[] uv
function debug.upvalue.getall(func, uv_index) end

---Finds the index of an upvalue by name
---@param func1 function
---@param uv_name string The name of the upvalue to look for.
---@return number index The upvalue index.
function debug.upvalue.find(func1, uv_name) end

---Swaps an upvalue in `func1` with an upvalue in `func2`.
---@param func1 function
---@param uv_index1 number
---@param func2 function
---@param uv_index2 number
function debug.upvalue.swap(func1, uv_index1, func2, uv_index2) end