local refuel = require("lib.refuel")
local log = require("lib.log").as("safebot")

---@param tryMoveFunc fun(): boolean
---@param breakFunc fun(): boolean
---@param attackFunc fun(): boolean
---@param refuelStrategy RefuelStrategy
---@param timeout number
---@param breakBlocks boolean
---@param attackEntities boolean
---@return boolean _ false only if the timeout was reached
local function _doDirection(tryMoveFunc, breakFunc, attackFunc, refuelStrategy, timeout, breakBlocks, attackEntities)
	local start = os.clock()
	while not tryMoveFunc() do
		refuel.ensureFueled(refuelStrategy)
		if breakBlocks then
			if not breakFunc() then
				log.blocked("I appear to be obstructed")
			end
		end
        if attackEntities then
            attackFunc()
        end
		if os.clock() - start > timeout then
			return false
		end
	end
	return true
end

--- Create a context for safe movement operations
---@param refuelStrategy RefuelStrategy
---@return SafebotContext
local function newContext(refuelStrategy)
	---@class SafebotContext
	local context = {
		--- Moves forward and blocks until any obstruction is cleared. Breaks blocks if
		--- breakBlocks is set to true. Attack entities if attackEntities is set to
		--- true.
		---@param timeout number
		---@param breakBlocks boolean
		---@param attackEntities boolean
		---@return boolean _ false only if the timeout was reached
		forward = function (timeout, breakBlocks, attackEntities)
			return _doDirection(turtle.forward, turtle.dig, turtle.attack, refuelStrategy, timeout, breakBlocks, attackEntities)
		end,

		--- Moves up and blocks until any obstruction is cleared. Breaks blocks if
		--- breakBlocks is set to true. Attack entities if attackEntities is set to
		--- true.
		---@param timeout number
		---@param breakBlocks boolean
		---@param attackEntities boolean
		---@return boolean _ false only if the timeout was reached
		up = function (timeout, breakBlocks, attackEntities)
			return _doDirection(turtle.up, turtle.digUp, turtle.attackUp, refuelStrategy, timeout, breakBlocks, attackEntities)
		end,

		--- Moves down and blocks until any obstruction is cleared. Breaks blocks if
		--- breakBlocks is set to true. Attack entities if attackEntities is set to
		--- true.
		---@param timeout number
		---@param breakBlocks boolean
		---@param attackEntities boolean
		---@return boolean _ false only if the timeout was reached
		down = function (timeout, breakBlocks, attackEntities)
			return _doDirection(turtle.down, turtle.digDown, turtle.attackDown, refuelStrategy, timeout, breakBlocks, attackEntities)
		end,

		--- Moves back and blocks until any obstruction is cleared. Breaks blocks if
		--- breakBlocks is set to true. Attack entities if attackEntities is set to
		--- true.
		---@param timeout number
		---@param breakBlocks boolean
		---@param attackEntities boolean
		---@return boolean _ false only if the timeout was reached
		back = function (timeout, breakBlocks, attackEntities)
			local start = os.clock()
			while not turtle.back() do
				refuel.ensureFueled(refuelStrategy)
				if breakBlocks or attackEntities then
					turtle.turnLeft()
					turtle.turnLeft()
					if breakBlocks then
						turtle.dig()
					end
					if attackEntities then
						turtle.attack()
					end
					turtle.turnLeft()
					turtle.turnLeft()
				end
				if os.clock() - start > timeout then
					return false
				end
			end
			return true
		end,
	}
	return context
end

return {
	newContext = newContext
}