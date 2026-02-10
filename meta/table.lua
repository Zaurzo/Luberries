---@meta table

---Puts everything in table `from` to table `to`.
---Does not overwrite existing values.
---@param to table The table to merge to.
---@param from table The table to merge from.
---@return table to
function table.inherit(to, from) end

---Merges everything in table `from` to table `to`. 
---@param to table The table to join to.
---@param from table The table to join from.
---@param start_index number The index in `from` to start at.
---@param end_index number The index in `from` to end at.
---@return table to
function table.merge(to, from, start_index, end_index) end

---Assigns everything in `...` to table `to`.
---@param to table The table to join to.
---@param ... any The items to join into `to`.
function table.assign(to, ...) end