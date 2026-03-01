
--#region Setup Extension Base

local package = {}

for k, v in pairs(require('package')) do
    package[k] = v
end

--#endregion

local function split(str, seperator)
    local pack = {}
    local pos, n = 1, 0
    local len = #str

    for _ = 1, len do
        local start, stop = string.find(str, seperator, pos, true)
        
        if not start then
            if n < 1 then
                return pack, 0
            end

            break
        end

        n = n + 1
        pack[n] = string.sub(str, pos, start - 1)
        pos = stop + 1
    end

    n = n + 1
    pack[n] = string.sub(str, pos, len)

    return pack, n
end

local function load_lib(name, sub_field)
    local ok, M = pcall(require, name)
    
    if not ok then
        return nil, 'The specified module could not be found.'
    end

    if sub_field then
        if type(M) == 'table' then
            local current

            if string.find(sub_field, '.', 1, true) then
                local names, n = split(sub_field, '.')

                for i = 1, n do
                    local name = names[i]
                    current = current ~= nil and current[name] or M[name]

                    if current == nil then
                        break
                    end
                end
            else
                current = M[sub_field]
            end

            if current == nil then
                return nil, "Could not find field '" .. sub_field .. "' in the module."
            end

            return current
        else
            return nil, "Could not find field '" .. sub_field .. "' in the module."
        end
    end

    return M
end

local loaded = package.loaded
local unloaders = {}

local function unload_lib(name)
    local unloader = unloaders[name]

    if unloader then
        local M = loaded[name]
        loaded[name] = nil
        
        return unloader(M)
    end

    loaded[name] = nil
end

function package.load(name, sub_field)
    return load_lib(name, sub_field)
end

function package.unload(name)
    return unload_lib(name)
end

function package.reload(name, sub_field)
    unload_lib(name)
    return load_lib(name, sub_field)
end

function package.setunloader(name, callback)
    unloaders[name] = callback
    return callback
end

return package
