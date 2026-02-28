
local args = {}
local math = math

local select = select
local type = type
local table_unpack = table.unpack or unpack

local function table_pack(...)
    return { [0] = select('#', ...), ... }
end

---Returns the amount of arguments passed.
---@param ... any The arguments to pass.
---@return number count
function args.count(...)
    return select('#', ...)
end

---Returns true if `item` is inside the arguments passed.
---@param item any The item to check for.
---@param ... any The arguments to pass.
---@return boolean
function args.contains(item, ...)
    for i = 1, select('#', ...) do
        if select(i, ...) == item then
            return true
        end
    end

    return false
end

---Returns the type of every argument passed.
---@param ... any The arguments to pass.
---@return string ... The types of the arguments passed.
function args.type(...)
    local pack = table_pack(...)
    local n = pack[0]

    for i = 1, n do
        pack[i] = type(pack[i])
    end

    return table_unpack(pack, 1, n)
end

---Returns the arguments passed in the provided range.
---Negative indices are supported.
---@param start_pos number Start range.
---@param end_pos number End range.
---@param ... any The arguments starting from `start_pos` to `end_pos`.
function args.slice(start_pos, end_pos, ...)
    local pack = table_pack(...)
    local n = pack[0]

    if start_pos < 0 then
        start_pos = n + start_pos + 1
    end

    if end_pos < 0 then
        end_pos = n + end_pos + 1
    end

    end_pos = math.min(end_pos, n)

    if start_pos > end_pos then
        error('start index cannot be greater than end index', 2)
    end

    start_pos = math.max(start_pos, 1)

    return table_unpack(pack, start_pos, end_pos)
end

---Returns the arguments passed in reverse.
---@param ... any The arguments to reverse.
---@return any ... The reversed arguments.
function args.reverse(...)
    local pack = table_pack(...)
    local i, j = 1, pack[0]

    while i < j do
        pack[i], pack[j] = pack[j], pack[i]

        i = i + 1
        j = j - 1
    end

    return table_unpack(pack, 1, pack[0])
end

---Combines everything in `tbl` to the passed arguments.
---@param tbl table The table to combine with.
---@param ... any The arguments to combine with `tbl`.
---@return any ... The passed arguments combined with everything in `tbl`.
function args.concat(tbl, ...)
    local combined = table_pack(...)
    local tbl_n, args_n = #tbl, combined[0]

    for i = 1, tbl_n do
        combined[i + args_n] = tbl[i]
    end

    return table_unpack(combined, 1, args_n + tbl_n)
end

---Returns the passed arguments with nils filtered out.
---@param ... any The arguments to filter.
---@return any ... The passed arguments without any nils.
function args.clearnil(...)
    local pack = {}
    local n = 0

    for i = 1, select('#', ...) do
        local item = select(i, ...)

        if item ~= nil then
            n = n + 1
            pack[n] = item
        end
    end

    return table_unpack(pack, 1, n)
end

return args