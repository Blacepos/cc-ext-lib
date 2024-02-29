package.path = package.path .. ";../?.lua"

local nav = require("lib.nav")
local refuel = require("lib.refuel")
local move = require("lib.move")
local std = require("lib.std")

-- Create a `NavContext` for compound navigation (i.e., performing multiple
-- moves in sequence).
-- The argument is a `RefuelStrategy` that specifies how to handle refueling the
-- turtle. More info is in the module docstring for refuel.lua.
local nc = nav.newContext(refuel.defaultHardcoded())

-- `newMove` creates a new compound move, which you can execute in the
-- `NavContext` with `exec`.
local m1 = move.newMove():forward(5):right(2):back(1):up(3):left(2):down(3):turnRight(1):forward(2)

-- Once you have constructed a move, you can execute it as many times as you
-- want.
nc:exec(m1, math.huge, false, false)
nc:exec(m1, math.huge, false, false)

-- `invert` reverses the move so going from A to B now goes from B to A.
-- `invert` is an in-place operation, so we need to copy m1 if we don't want to
-- modify it.
local m2 = std.tableClone(m1)
m2:invert()
nc:exec(m2, math.huge, false, false)

-- We can undo an entire compound move using `undoMove`, this 
nc:undoMove(math.huge, false, false)

--[[
net movement in above examples:

m1:
. . E
.
.
.
S

m2:
. . S
.
.
.
E
]]