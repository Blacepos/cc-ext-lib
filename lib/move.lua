
---@enum SegmentAction
local SegmentAction = {
    FORWARD = 0,
    LEFT = 1,
    BACK = 2,
    RIGHT = 3,
    UP = 4,
    DOWN = 5,
    TURNRIGHT = 6,
    TURNLEFT = 7,
    TURNAROUND = 8,
}

---@type { [SegmentAction]: SegmentAction }
local Inverses = {
    [SegmentAction.FORWARD] = SegmentAction.BACK,
    [SegmentAction.LEFT] = SegmentAction.RIGHT,
    [SegmentAction.BACK] = SegmentAction.FORWARD,
    [SegmentAction.RIGHT] = SegmentAction.LEFT,
    [SegmentAction.UP] = SegmentAction.DOWN,
    [SegmentAction.DOWN] = SegmentAction.UP,
    [SegmentAction.TURNRIGHT] = SegmentAction.TURNLEFT,
    [SegmentAction.TURNLEFT] = SegmentAction.TURNRIGHT,
    [SegmentAction.TURNAROUND] = SegmentAction.TURNAROUND
}

---@class MoveSegment
---@field action SegmentAction
---@field rep integer

local function newMove()
    ---@class Move
    local move = {
        ---@type MoveSegment[]
        moves = {},

        ---@type integer
        _numPrimitiveMoves = 0,

        ---@param self Move
        ---@param rep integer
        ---@return Move _
        forward = function (self, rep)
            table.insert(self.moves, { action = SegmentAction.FORWARD, rep = rep })
            self._numPrimitiveMoves = self._numPrimitiveMoves + rep
            return self
        end,

        ---@param self Move
        ---@param rep integer
        ---@return Move _
        right = function (self, rep)
            table.insert(self.moves, { action = SegmentAction.RIGHT, rep = rep })
            self._numPrimitiveMoves = self._numPrimitiveMoves + rep + 2
            return self
        end,

        ---@param self Move
        ---@param rep integer
        ---@return Move _
        left = function (self, rep)
            table.insert(self.moves, { action = SegmentAction.LEFT, rep = rep })
            self._numPrimitiveMoves = self._numPrimitiveMoves + rep + 2
            return self
        end,

        ---@param self Move
        ---@param rep integer
        ---@return Move _
        back = function (self, rep)
            table.insert(self.moves, { action = SegmentAction.BACK, rep = rep })
            self._numPrimitiveMoves = self._numPrimitiveMoves + rep
            return self
        end,

        ---@param self Move
        ---@param rep integer
        ---@return Move _
        up = function (self, rep)
            table.insert(self.moves, { action = SegmentAction.UP, rep = rep })
            self._numPrimitiveMoves = self._numPrimitiveMoves + rep
            return self
        end,

        ---@param self Move
        ---@param rep integer
        ---@return Move _
        down = function (self, rep)
            table.insert(self.moves, { action = SegmentAction.DOWN, rep = rep })
            self._numPrimitiveMoves = self._numPrimitiveMoves + rep
            return self
        end,

        ---@param self Move
        ---@param rep integer
        ---@return Move _
        turnRight = function (self, rep)
            table.insert(self.moves, { action = SegmentAction.TURNRIGHT, rep = rep })
            self._numPrimitiveMoves = self._numPrimitiveMoves + rep
            return self
        end,

        ---@param self Move
        ---@param rep integer
        ---@return Move _
        turnLeft = function (self, rep)
            table.insert(self.moves, { action = SegmentAction.TURNLEFT, rep = rep })
            self._numPrimitiveMoves = self._numPrimitiveMoves + rep
            return self
        end,

        ---@param self Move
        ---@param rep integer
        ---@return Move _
        turnAround = function (self, rep)
            table.insert(self.moves, { action = SegmentAction.TURNAROUND, rep = rep })
            self._numPrimitiveMoves = self._numPrimitiveMoves + 2 * rep
            return self
        end,

        ---@param self Move
        ---@return Move _
        invert = function (self)
            ---@type MoveSegment[]
            local newMoves = {}
            for i = #self.moves, 1, -1 do
                local move = self.moves[i]
                table.insert(newMoves, { action = Inverses[move.action], rep = move.rep })
            end
            self.moves = newMoves
            return self
        end,
    }
    return move
end

return {
    newMove = newMove,
    SegmentAction = SegmentAction
}