--[[
local pointrouting = require("lib.pointrouting")
local pointnav = require("lib.pointnav")
local refuel = require("lib.refuel")

-- a route is a set of points that can be traversed between
local route = pointrouting.newRoute()

-- indicate in the route how the turtle can make it from one point to another
route:addPath("storage", "shaft_top", move.newMove():forward(6):right(1)) -- addPath automatically uses `Move::invert` to determine the reverse path
route:addPath("shaft_top", "shaft_bottom", move.newMove():down(60))

-- setting up the context which will perform the move actions
local pnc = pointnav.newContext(route, refuel.defaultHardcoded())
pnc:hintCurrentLocation("storage")

-- traverse all the paths needed to get from "storage" to "shaft_bottom"
pnc:traverseRoute(route, "shaft_bottom", math.huge, false, false)
-- ... some time later when the turtle wants to return to the storage area
pnc:traverseRoute(route, "storage", math.huge, false, false)
]]