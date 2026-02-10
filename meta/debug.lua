---@meta debug.upvalue

---Returns the cell of upvalue `uv_index` in `func`.
---@param func function The function to get the upvalue of.
---@param uv_index number The index of the upvalue to get.
---@return upvalue? uv
---@return string? name The debug name of the upvalue in `func`.
function debug.upvalue.get(func, uv_index) end