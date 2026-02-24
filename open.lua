
local patch do
    local function add(tab, additions, name)
        local names, n
        local pos = 1
        
        while true do
            local start = string.find(name, '.', pos, true)
            if not start then break end

            names = names or {}
            n = (n or 0) + 1

            names[n] = string.sub(name, pos, start - 1)
            pos = start + 1
        end

        -- Handle sub-libaries (e.g. "upvalue.swap")
        if names then
            n = n + 1
            names[n] = string.sub(name, pos)

            local lib_name = names[1]
            local current = additions[lib_name]

            if current == nil then return end

            local lib = tab[lib_name] or {}
            local lib_current = lib

            if n > 2 then
                for i = 2, n - 1 do
                    local addname = names[i]
                    current = current[addname]

                    if current == nil then
                        return
                    end

                    lib_current[addname] = lib_current[addname] or {}
                    lib_current = lib_current[addname]
                end
            end

            local addname = names[n]
            local addition = current[addname]

            if addition == nil then return end

            lib_current[addname] = addition
            tab[lib_name] = lib
        else
            local addition = additions[name]
            
            if addition ~= nil then
                tab[name] = addition
            end
        end
    end

    function patch(self, ...)
        local n = select('#', ...)
        local mt = getmetatable(self)

        local tab = mt.__index
        local additions = mt.__additions

        if n > 0 then
            for i = 1, n do
                local name = select(i, ...)
                add(tab, additions, name)
            end
        else
            for k, v in pairs(additions) do
                tab[k] = v
            end
        end
    end
end

local function open(name, inherit)
    local ok, berry = pcall(require, name)
    if not ok then error('attempt to open a non-existent berry', 2) end

    local mt = getmetatable(berry) or {}

    if inherit then
        local tab = _G[inherit]

        if not tab then
            local ok, res = pcall(require, inherit)
            tab = ok and res or nil
        end

        if not tab then
            error(tab, 'attempt to inherit a missing library (' .. inherit .. ')', 2)
        end

        if type(tab) ~= 'table' then
            error('attempt to inherit a non-table', 2)
        end

        local additions = {}

        for k, v in pairs(berry) do
            additions[k] = v
        end

        mt.__index = tab
        mt.__additions = additions
        mt.__call = patch

        -- Add all functions from inherited table to the berry
        for k, v in pairs(tab) do
            if berry[k] == nil then
                berry[k] = v
            end
        end
    end

    local call = berry.__call --[[@as function]]

    if call then
        local old_call = mt.__call

        function mt:__call(...)
            if old_call then
                old_call(self, ...)
            end

            return call(self, ...)
        end
    end

    return setmetatable(berry, mt)
end

return open