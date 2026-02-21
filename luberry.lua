
local luberry = {}

local function patch(self, ...)
    local lib = self.__lib
    if not lib then return end

    local count = select('#', ...)
    local blacklist = {
        __lib = true,
        __call = true
    }

    if count > 0 then
        local names = { ... }

        for i = 1, count do
            local name = names[i]
            
            if name ~= nil and not blacklist[name] then
                local func = self[name]

                if func then
                    lib[name] = func
                end
            end
        end
    else
        for name, func in pairs(self) do
            if not blacklist[name] then
                lib[name] = func
            end
        end
    end
end

function luberry.create(name)
    local berry = {}

    if name then
        local tbl = _G[name]

        if not tbl then
            local ok, lib = pcall(require, name)
            tbl = ok and lib or nil
        end

        if tbl then
            for k, v in pairs(tbl) do
                berry[k] = v
            end

            berry.__lib = tbl
            berry.__call = patch
        end
    end

    return setmetatable(berry, luberry)
end

function luberry:__index(k)
    local lib = rawget(self, '__lib')
    if not lib then return end

    local v = lib[k]
    self[k] = v

    return v
end

---@diagnostic disable-next-line
local _, tbl_err_msg = pcall({})

function luberry:__call(...)
    if self.__call then
        return self:__call(...)
    end

    return error(tbl_err_msg, 2) -- simulate "attempt to call a table value" error
end

return luberry