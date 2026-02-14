
local luberry = {}

function luberry.create(name)
    local berry = {}

    if name then
        local lib = _ENV[name]

        if not lib then
            local ok, loaded_lib = pcall(require, name)
            lib = ok and loaded_lib or nil
        end

        if lib then
            for k, v in pairs(lib) do
                berry[k] = v
            end

            berry.__lib = lib
        end
    end

    return setmetatable(berry, luberry)
end

function luberry:__index(k)
    local lib = rawget(self, '__lib')

    if lib then
        return lib[k]
    end
end

function luberry:__newindex(k, v)
    if self.__lib then
        self.__lib[k] = v
    end

    rawset(self, k, v)
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