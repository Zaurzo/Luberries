
-- xpcall compatibility shim
-- Some versions of Lua have a version of xpcall that doesn't forward arguments
-- Based off of https://github.com/BlackMATov/xpcall.lua/tree/main

-- Generate a bunch of argument passers
local argument_passers do
    local load = loadstring or load

    argument_passers = {}

    for i = 1, 10 do -- Optimized for ten arguments or less
        local args do
            local args_names = {}

            for j = 1, i do
                args_names[j] = 'a' .. j
            end

            args = table.concat(args_names, ',')
        end

        local code = string.format([[
            return function(%s)
                return %s
            end
        ]], args, args)

        argument_passers[i] = load(code)()
    end
end

local _xpcall = xpcall
local select = select
local unpack = table.unpack or unpack

local _func_to_call ---@type function
local _passer ---@type function

local a1, a2, a3, a4, a5, a6, a7, a8, a9, a10
local function call()
    return _func_to_call(_passer(a1, a2, a3, a4, a5, a6, a7, a8, a9, a10))
end

local function xpcall(func, err_handler, ...)
    local n = select('#', ...)

    if n < 1 then
        return _xpcall(func, err_handler)
    end

    if n > 10 then
        local args = { ... }
        local f = func

        function func()
            return f(unpack(args, 1, n))
        end

        return _xpcall(func, err_handler)
    end

    a1, a2, a3, a4, a5, a6, a7, a8, a9, a10 = ...

    _passer = argument_passers[n]
    _func_to_call = func

    return _xpcall(call, err_handler)
end

return xpcall