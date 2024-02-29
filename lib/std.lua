local function tableClone(original)
    local copy = {}
    for k, v in pairs(original) do
        if type(v) == "table" then
            v = tableClone(v)
        end
        copy[k] = v
    end
    return copy
end

return {
    tableClone = tableClone
}