
--#region Setup Extension Base

local string = {}

for k, v in pairs(require('string')) do
    string[k] = v
end

--#endregion

function string.startswith(str, with)
    return string.sub(str, 1, #with) == with
end

function string.endswith(str, with)
    return string.sub(str, -#with) == with
end

function string.trimr(str)
    return (string.gsub(str, '%s*$', ''))
end

function string.triml(str)
    return (string.gsub(str, '^%s*', ''))
end

function string.trim(str)
    return (string.gsub(string.gsub(str, '^%s*', ''), '%s*$', ''))
end

function string.split(str, seperator, ignore_pattern)
    seperator = seperator or ''

    local pack = {}

    if seperator == '' then
        local len = #str
        pack[0] = len

        for i = 1, len do
            pack[i] = string.sub(str, i, i)
        end
    else
        local pos, n = 1, 0
        local len = #str

        for _ = 1, len do
            local start, stop = string.find(str, seperator, pos, ignore_pattern)
            
            if not start then
                if n < 1 then
                    pack[0] = 0
                    return pack
                end

                break
            end

            n = n + 1
            pack[n] = string.sub(str, pos, start - 1)
            pos = stop + 1
        end

        n = n + 1
        pack[n], pack[0] = string.sub(str, pos, len), n
    end

    return pack
end

return string
