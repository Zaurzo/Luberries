
local applier_meta = {}

function applier_meta:__call()
    if self.applied then return end

    if self.apply() ~= false then
        self.applied = true
    end
end

return function(apply)
    return setmetatable({ apply = apply }, applier_meta)
end