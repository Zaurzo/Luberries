
-- xpcall compatibility shim
-- Some versions of Lua have a version of xpcall that doesn't forward arguments
--
-- Based off of https://github.com/BlackMATov/xpcall.lua/tree/main
-- This implementation is a little bit slower, but it's negligible. I like readability

local a1, a2, a3, a4, a5, a6, a7, a8, a9, a10
local _args, _n
local _func_to_call
local _passer

local unpack = table.unpack or unpack

local function call()
    local func = _func_to_call
    _func_to_call = nil

    if _passer then
        local a, b, c, d, e, f, g, h, i, j = a1, a2, a3, a4, a5, a6, a7, a8, a9, a10

        -- We set these to nil to not hold a strong reference to anything
        a1, a2, a3, a4, a5, a6, a7, a8, a9, a10 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
    
        return func(_passer(a, b, c, d, e, f, g, h, i, j))
    end

    local args = _args
    _args = nil

    return func(unpack(args, 1, _n))
end

-- Functions that pass a static number of arguments are needed, so that
-- select('#', ...) will return the correct number
-- (This is ugly)
local argument_passers = {}
argument_passers[1] = function(a) return a end
argument_passers[2] = function(a, b) return a, b end
argument_passers[3] = function(a, b, c) return a, b, c end
argument_passers[4] = function(a, b, c, d) return a, b, c, d end
argument_passers[5] = function(a, b, c, d, e) return a, b, c, d, e end
argument_passers[6] = function(a, b, c, d, e, f) return a, b, c, d, e, f end
argument_passers[7] = function(a, b, c, d, e, f, g) return a, b, c, d, e, f, g end
argument_passers[8] = function(a, b, c, d, e, f, g, h) return a, b, c, d, e, f, g, h end
argument_passers[9] = function(a, b, c, d, e, f, g, h, i) return a, b, c, d, e, f, g, h, i end
argument_passers[10] = function(a, b, c, d, e, f, g, h, i, j) return a, b, c, d, e, f, g, h, i, j end

local select = select
local _xpcall = xpcall

local function xpcall(func, err_handler, ...)
    _n = select('#', ...)

    if _n < 1 then
        return _xpcall(func, err_handler)
    end

    _func_to_call = func

    --[[-----------------------------------------------------------
        Optimized for 10 arguments or less. Otherwise, fallback to unoptimized behavior.

        I chose 10 because it's a nice number and I can't think of any 
        reasonable case where you'd wanna pass more than 10 arguments...
    -------------------------------------------------------]]--
    if _n > 10 then
        _passer = nil
        _args = { ... }

        return _xpcall(call, err_handler)
    end

    a1, a2, a3, a4, a5, a6, a7, a8, a9, a10 = ...
    _passer = argument_passers[_n]

    return _xpcall(call, err_handler)
end

return xpcall