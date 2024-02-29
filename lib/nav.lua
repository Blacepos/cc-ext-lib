local undo = require("lib.undo")
local move = require("lib.move")

--- Create a new context for compound navigation
---@param refuelStrategy RefuelStrategy A strategy for how to refuel the robot
---@return NavContext _ 
local function newContext(refuelStrategy)
    ---@class NavContext
    local navContext = {
        --- A context to undo individual primitive moves
        _undoCtx = undo.newContext(refuelStrategy),
        --- The number of primitive moves in each previous compound move
        _numPrimInPrevMoves = {},
        --- Undo all the actions in the last compound move
        ---@param self NavContext
        ---@param timeout number
        ---@param breakBlocks boolean
        ---@param attackEntities boolean
        undoMove = function(self, timeout, breakBlocks, attackEntities)
            local lastMoveNumActions = table.remove(self._numPrimInPrevMoves)
			for i=1,lastMoveNumActions do
				self._undoCtx:undo(timeout, breakBlocks, attackEntities)
			end
        end,
        --- Execute a previously constructed compound move from lib.move
        ---@param self NavContext
        ---@param compundMove Move
        ---@param timeout number
        ---@param breakBlocks boolean
        ---@param attackEntities boolean
        exec = function(self, compundMove, timeout, breakBlocks, attackEntities)
            for i=1,#compundMove.moves do
                local nextMove = compundMove.moves[i]
                
                if nextMove.action == move.SegmentAction.FORWARD then
                    for _=1,nextMove.rep do
                        self._undoCtx:forward(timeout, breakBlocks, attackEntities)
                    end
                elseif nextMove.action == move.SegmentAction.LEFT then
                    self._undoCtx:turnLeft()
                    for _=1,nextMove.rep do
                        self._undoCtx:forward(timeout, breakBlocks, attackEntities)
                    end
                    self._undoCtx:turnRight()
                elseif nextMove.action == move.SegmentAction.BACK then
                    for _=1,nextMove.rep do
                        self._undoCtx:back(timeout, breakBlocks, attackEntities)
                    end
                elseif nextMove.action == move.SegmentAction.RIGHT then
                    self._undoCtx:turnRight()
                    for _=1,nextMove.rep do
                        self._undoCtx:forward(timeout, breakBlocks, attackEntities)
                    end
                    self._undoCtx:turnLeft()
                elseif nextMove.action == move.SegmentAction.UP then
                    for _=1,nextMove.rep do
                        self._undoCtx:up(timeout, breakBlocks, attackEntities)
                    end
                elseif nextMove.action == move.SegmentAction.DOWN then
                    for _=1,nextMove.rep do
                        self._undoCtx:down(timeout, breakBlocks, attackEntities)
                    end
                elseif nextMove.action == move.SegmentAction.TURNRIGHT then
                    for _=1,nextMove.rep do
                        self._undoCtx:turnRight()
                    end
                elseif nextMove.action == move.SegmentAction.TURNLEFT then
                    for _=1,nextMove.rep do
                        self._undoCtx:turnLeft()
                    end
                elseif nextMove.action == move.SegmentAction.TURNAROUND then
                    for _=1,nextMove.rep do
                        self._undoCtx:turnLeft()
                        self._undoCtx:turnLeft()
                    end
                end
            end
            table.insert(self._numPrimInPrevMoves, compundMove._numPrimitiveMoves)
        end,
        --- Start a compound move
        ---@param self NavContext
        ---@param timeout number
        ---@param breakBlocks boolean
        ---@param attackEntities boolean
        ---@return NavBuilder _ A builder for adding moves to the next compound move
        start = function(self, timeout, breakBlocks, attackEntities)
            -- ex: go forward 5, left 2, then end facing right (next "forward" is towards the right)
            -- context:start().forward(5).left(2).faceRight().finish()

            ---@alias PrimitiveMoveFunc fun(rep: integer): integer

            ---@type PrimitiveMoveFunc
            local multiForward = function(rep)
                for _=1,rep do
                    self._undoCtx:forward(timeout, breakBlocks, attackEntities)
                end
                return rep
            end

            ---@type PrimitiveMoveFunc
            local multiStrafeRight = function(rep)
                self._undoCtx:turnRight()
                for _=1,rep do
                    self._undoCtx:forward(timeout, breakBlocks, attackEntities)
                end
                self._undoCtx:turnLeft()
                return rep + 2
            end

            ---@type PrimitiveMoveFunc
            local multiStrafeLeft = function(rep)
                self._undoCtx:turnLeft()
                for _=1,rep do
                    self._undoCtx:forward(timeout, breakBlocks, attackEntities)
                end
                self._undoCtx:turnRight()
                return rep + 2
            end

            ---@type PrimitiveMoveFunc
            local multiBack = function(rep)
                for _=1,rep do
                    self._undoCtx:back(timeout, breakBlocks, attackEntities)
                end
                return rep
            end

            ---@type PrimitiveMoveFunc
            local multiUp = function(rep)
                for _=1,rep do
                    self._undoCtx:up(timeout, breakBlocks, attackEntities)
                end
                return rep
            end

            ---@type PrimitiveMoveFunc
            local multiDown = function(rep)
                for _=1,rep do
                    self._undoCtx:down(timeout, breakBlocks, attackEntities)
                end
                return rep
            end

            ---@type PrimitiveMoveFunc
            local faceRight = function(_)
                self._undoCtx:turnRight()
                return 1
            end

            ---@type PrimitiveMoveFunc
            local faceLeft = function(_)
                self._undoCtx:turnLeft()
                return 1
            end

            ---@type fun(builder: NavBuilder, primitiveMove: PrimitiveMoveFunc, rep: integer)
            local _addMove = function(builder, primitiveMove, rep)
                local performMove = function()
                    builder._numPrimitiveMoves = builder._numPrimitiveMoves + primitiveMove(rep)
                end
                table.insert(builder._moves, performMove)
            end

            ---@class NavBuilder
            local navBuilder = {
                _moves = {},
                ---@type integer
                _numPrimitiveMoves = 0,

                ---@param builder NavBuilder
                ---@param rep integer
                ---@return NavBuilder _
                forward   = function (builder, rep) _addMove(builder, multiForward, rep) return builder end,

                ---@param builder NavBuilder
                ---@param rep integer
                ---@return NavBuilder _
                right     = function (builder, rep) _addMove(builder, multiStrafeRight, rep) return builder end,

                ---@param builder NavBuilder
                ---@param rep integer
                ---@return NavBuilder _
                left      = function (builder, rep) _addMove(builder, multiStrafeLeft, rep) return builder end,

                ---@param builder NavBuilder
                ---@param rep integer
                ---@return NavBuilder _
                back      = function (builder, rep) _addMove(builder, multiBack, rep) return builder end,

                ---@param builder NavBuilder
                ---@param rep integer
                ---@return NavBuilder _
                up        = function (builder, rep) _addMove(builder, multiUp, rep) return builder end,

                ---@param builder NavBuilder
                ---@param rep integer
                ---@return NavBuilder _
                down      = function (builder, rep) _addMove(builder, multiDown, rep) return builder end,

                ---@param builder NavBuilder
                ---@param rep integer
                ---@return NavBuilder _
                faceRight = function (builder, rep) _addMove(builder, faceRight, rep) return builder end,

                ---@param builder NavBuilder
                ---@param rep integer
                ---@return NavBuilder _
                faceLeft  = function (builder, rep) _addMove(builder, faceLeft, rep) return builder end,

                ---@param builder NavBuilder
                finish  = function (builder)
                    for i=1,#builder._moves do
                        builder._moves[i]()
                    end
                    table.insert(self._numPrimInPrevMoves, builder._numPrimitiveMoves)
                end,
            }

            return navBuilder
        end
    }

    return navContext
end

return {
    newContext = newContext
}