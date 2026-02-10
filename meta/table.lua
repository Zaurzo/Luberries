---@meta table

---Merges everything in table `from` to table `to`.
---@param to table The table to merge to.
---@param from table The table to merge from.
---@return table to
function table.merge(to, from) end

---Joins everything in table `from` to table `to`.
---@param to table The table to join to.
---@param from table The table to join from.
---@return table to
function table.join(to, from) end

---Joins everything from index 1 up to the first absent index in table `from` to table `to`.
---This is faster than `table.join`, so if both tables are sequential, `table.ijoin` should be used instead.
---@param to table The table to join to.
---@param from table The table to join from.
---@return table to
function table.ijoin(to, from) end

---Joins everything in `...` to table `to`.
---@param to table The table to join to.
---@param ... any The items to join into `to`.
function table.jointuple(to, ...) end