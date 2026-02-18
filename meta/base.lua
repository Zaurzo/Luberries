---@meta _

---Returns true if `obj` can be called. (`obj()`)
---@param obj any The object to check.
---@return boolean callable
function iscallable(obj) end

---Calls `require` in protected mode. 
---If the given module is not found, `nil` will be returned instead of an error being thrown.
---@param name string The module to load.
---@return any
function prequire(name) end

---Calls `require`, but shallow copies the result if it's a table.
---@param name string The module to load.
---@return any
function requirecopy(name) end

---Returns true if `tbl` has a protected metatable.
---@param tbl table The table to check.
---@return boolean protected
function isprotected(tbl) end

---Similiar to `error`, but does not halt execution.
---@param msg string The error message to throw.
---@param level? number The stack level to throw the error at.
function softerror(msg, level) end

---Extended version of `pcall`.
---Calls `func` with the passed arguments (`...`) in protected mode.
---If an error happens in `func`, it won't be thrown, but instead its error message will be returned.
---If the `func` executes successfully, `on_success` will be called with its results.
---@param func function The function to call in protected mode.
---@param err_handler function? The function to call if `func` errors. Return result will be the error message `pcallex` returns.
---@param on_success function? The function to call if `func` is successful. If any, the return results of this will be used instead of the results of `func`.
---@param ... any The arguments to pass to `func`.
---@return boolean status If the function executed correctly.
---@return any ... The return results of `func`, or the results of `on_success` if any. This will be the error message if `func` fails.
function pcallex(func, err_handler, on_success, ...) end

---Creates a class with the given name. 
---@param name string The name of the class.
---@param base table The base the class should inherit from.
---@return table class
function class(name, base) end

---Returns true if `class` ultimately inherits from `base`.
---@param class table
---@param base table The base to check for.
---@return boolean
function instanceof(class, base) end

---Creates a tuple from the passed arguments.
---@param ... any The values to pass into the tuple.
---@return tuple
function tuple(...) end

---Creates an enum from the passed table.
---@param tbl table
---@return enum
function enum(tbl) end