
---A class representing a tuple.
---@class tuple
local tuple = {}

tuple.__index = tuple
tuple.__name = 'tuple'
tuple.__type = 'tuple' -- utilize custom type metamethod if enabled

---Packs all items in the current tuple into a table.
---@return table
function tuple:totable()
    local tbl = {}

    for i = 1, self.n do
        tbl[i] = self[i]
    end

    tbl.n = self.n
    
    return tbl
end

---Creates a new tuple containing a subset of items from the current tuple.
---@param start_pos number The starting index of the slice.
---@param end_pos number The ending index of the slice.
---@return tuple slice
function tuple:slice(start_pos, end_pos)
    local slice = {}
    local n = 0

    for i = math.max(start_pos, 1), math.min(end_pos, self.n) do
        n = n + 1
        slice[n] = self[i]
    end

    slice.n = n

    return setmetatable(slice, tuple)
end

---Unpacks and returns all items in the current tuple.
---@param start_pos? number The index to start unpacking at.
---@param end_pos? number The index to stop unpacking at.
---@return any ... The items.
function tuple:unpack(start_pos, end_pos)
    start_pos = start_pos and math.max(start_pos, 1) or 1
    end_pos = end_pos and math.min(end_pos, self.n) or self.n

    return table.unpack(self, start_pos, end_pos)
end

local function tuple_iterator(self, i)
    i = i + 1

    if i > self.n then
        return nil
    end

    return i, self[i]
end

---Returns the tuple iterator.
---@return function iterator
---@return tuple self
---@return number i
function tuple:pairs()
    return tuple_iterator, self, 0
end

---Returns the amount of items in the current tuple.
---@return number count
function tuple:count()
    return self.n
end

function tuple:__newindex()
    error('cannot add to an existing tuple', 2)
end

-- utilize custom table.remove metamethod if enabled
function tuple:__remove()
    error('cannot remove from an existing tuple', 2)
end

-- utilize custom table.move metamethod if enabled
function tuple:__move()
    error('cannot move items in an existing tuple', 2)
end

tuple.__pairs = tuple.pairs
tuple.__ipairs = tuple.pairs -- Lua 5.2/5.3 compat
tuple.__insert = tuple.__newindex -- utilize custom table.insert metamethod if enabled
tuple.__len = tuple.count

return function(...)
    return setmetatable(table.pack(...), tuple)
end
