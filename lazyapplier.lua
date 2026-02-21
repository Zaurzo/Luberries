
return function(apply)
    local applied

    return function(...)
        if applied then return end

        if apply() ~= false then
            applied = true
        end
    end
end