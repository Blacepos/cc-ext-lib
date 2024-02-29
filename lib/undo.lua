local safebot = require("lib.safebot")

--- Create a context for logging primitive moves, providing the ability to undo
--- them.
---@param refuelStrategy RefuelStrategy A strategy for how to refuel the robot
---@return UndoContext _
local function newContext(refuelStrategy)
    ---@class UndoContext
	local undoContext = {
		_safebotCtx = safebot.newContext(refuelStrategy),
		_history = {},

        --- Move forward one block
        ---@param self UndoContext
        ---@param timeout number
        ---@param breakBlocks boolean
        ---@param attackEntities boolean
		forward = function(self, timeout, breakBlocks, attackEntities)
			self._safebotCtx.forward(timeout, breakBlocks, attackEntities)
			table.insert(self._history, self._safebotCtx.back)
		end,

        --- Move backward one block
        ---@param self UndoContext
        ---@param timeout number
        ---@param breakBlocks boolean
        ---@param attackEntities boolean
		back = function(self, timeout, breakBlocks, attackEntities)
			self._safebotCtx.back(timeout, breakBlocks, attackEntities)
			table.insert(self._history, self._safebotCtx.forward)
		end,

        --- Move up one block
        ---@param self UndoContext
        ---@param timeout number
        ---@param breakBlocks boolean
        ---@param attackEntities boolean
		up = function(self, timeout, breakBlocks, attackEntities)
			self._safebotCtx.up(timeout, breakBlocks, attackEntities)
			table.insert(self._history, self._safebotCtx.down)
		end,

        --- Move down one block
        ---@param self UndoContext
        ---@param timeout number
        ---@param breakBlocks boolean
        ---@param attackEntities boolean
		down = function(self, timeout, breakBlocks, attackEntities)
			self._safebotCtx.down(timeout, breakBlocks, attackEntities)
			table.insert(self._history, self._safebotCtx.up)
		end,

        --- Turn right
        ---@param self UndoContext
		turnRight = function(self)
			turtle.turnRight()
			table.insert(self._history, turtle.turnLeft)
		end,

        --- Turn left
        ---@param self UndoContext
		turnLeft = function(self)
			turtle.turnLeft()
			table.insert(self._history, turtle.turnRight)
		end,

		--- Undo the last operation
		---@param self UndoContext
        ---@param timeout number
        ---@param breakBlocks boolean
        ---@param attackEntities boolean
		undo = function(self, timeout, breakBlocks, attackEntities)
			table.remove(self._history)(timeout, breakBlocks, attackEntities)
		end
	}

    return undoContext
end

return {
	newContext = newContext
}