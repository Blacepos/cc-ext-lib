return {
	add = function(x, y) return x + y end,
	sub = function(x, y) return x - y end,
	mul = function(x, y) return x * y end,
	div = function(x, y) return x / y end,
	mod = function(x, y) return x % y end,
	idiv = function(x, y) return x // y end,
	neg = function(x) return -x end,

	eq = function(x, y) return x == y end,
	ne = function(x, y) return x ~= y end,
	gt = function(x, y) return x > y end,
	gte = function(x, y) return x >= y end,
	lt = function(x, y) return x < y end,
	lte = function(x, y) return x <= y end,

	logicAnd = function(a, b) return a and b end,
	logicOr = function(a, b) return a or b end,
	logicXor = function(a, b) return (a or b) and not (a and b) end,
	logicNot = function(a) return not a end,

	ternary = function(cond, a, b)
		if cond then return a else return b end
	end,

	band = function(x, y) return x & y end,
	bor = function(x, y) return x | y end,
	bxor = function(x, y) return x ~ y end,
	shl = function(x, y) return x << y end,
	shr = function(x, y) return x >> y end,
	bnot = function(x) return ~x end,

	len = function(a) return #a end,
	concat = function(a, b) return a..b end,
	index = function(a, i) return a[i] end
}