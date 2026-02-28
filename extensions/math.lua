
--#region Setup Extension Base

local math = {}

for k, v in pairs(require('math')) do
    math[k] = v
end

--#endregion

function math.isdecimal(num)
    return math.floor(num) ~= num
end

function math.clamp(num, min, max)
    return math.min(math.max(num, min), max)
end

function math.randomf(min, max)
    return min + (max - min) * math.random()
end

function math.rand(min, max)
    if math.isdecimal(min) or math.isdecimal(max) then
        return math.randomf(min, max)
    end

    return math.random(min, max)
end

return math
