--- An iterator over the given table with indices in the range [start, stop]
---@generic T: table, V
---@param vec T The table to iterate over
---@param start integer
---@param stop integer
---@return fun(table: V[], i?: integer):V
---@return T
---@return integer i
local function slice(vec, start, stop)
	local function iter(t, i)
		i = i + 1
		if i == stop+1 then return nil end
		return t[i]
	end
	return iter, vec, start-1
end

--- An iterator over the given table, yielding only the values that satisfy the given predicate
---@generic T: table, V
---@param vec T The table to iterate over
---@param pred fun(V): boolean A predicate to determine if an element should be included
---@return fun(table: V[], i?: integer):V
---@return T
---@return integer i
local function filter(vec, pred)
	local function _filter(s, i)
		local v
		repeat
			i = i + 1
			v = s[i]
			if v==nil then return end
		until pred(v)
		return v
	end
	return _filter, vec, 0
end

--- An iterator over adjacent elements in the given table
---@generic T: table, V
---@param vec T The table to iterate over
---@return fun(table: V[], i?: integer):V, V
---@return T
---@return integer i
local function adjacent(vec)
	if #vec < 2 then error("iadjacent requires a table of at least size 2") end
	local function iter(t, i)
		i = i + 1
		local n = t[i+1]
		if n==nil then return end
		return t[i], n
	end
	return iter, vec, 0
end

return {
    slice = slice,
    filter = filter,
    adjacent = adjacent,
}