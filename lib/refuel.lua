--[[
A module that defines ways to refuel a turtle.
The main idea is to create a `RefuelStrategy` that can be used to determine if
the turtle is low on fuel and how to respond. The `ensureFueled` function simply
invokes the functions in the `RefuelStrategy` to keep the turtle fueled.

Some default strategies are provided, such as `defaultHardcoded` which uses a
hardcoded constant to determine if the fuel is low and
`awaitRefuelFromCurrentSlot` to block until a player refuels the turtle.
]]
local log = require("lib.log").as("refuel")

local LOW_FUEL_CONSTANT = 5

---@alias LowFuelResponseFunc fun()
---@alias IsLowFuelFunc fun(): boolean

--- Curried function that returns a `LowFuelResponseFunc`
---@param fuelIsLow IsLowFuelFunc Function to check if fuel is still low
---@return LowFuelResponseFunc
local function awaitRefuelFromCurrentSlot(fuelIsLow)
    return function ()
        local function awaitKey()
            local _, k, _ = os.pullEvent("key")
            return k
        end
        local awaitEnter = function ()
            repeat until awaitKey() == keys.enter
        end

        repeat
            if not turtle.refuel() then
                log.blocked("Place more fuel in the current slot then press enter")
                awaitEnter()
            else
                log.info("Fuel level is now " .. turtle.getFuelLevel())
            end
        until not fuelIsLow()
    end
end

---@type LowFuelResponseFunc
local function ignoreLowFuel()
    log.warn("Low fuel was detected, but is explicitly ignored")
end


--- Determines if fuel is low by checking against a hardcoded constant
---@type IsLowFuelFunc
local function isFuelBelowHardcoded()
    return turtle.getFuelLevel() <= LOW_FUEL_CONSTANT
end

--- Determines if fuel is low by checking against a hardcoded constant
---comment
---@param value number
---@return IsLowFuelFunc
local function isFuelBelowValue(value)
    return function ()
        return turtle.getFuelLevel() <= value
    end
end

--- Create a new `RefuelStrategy`
---@param isLowFuelFunc IsLowFuelFunc A function to determine if the fuel is considered low
---@param lowFuelResponseFunc LowFuelResponseFunc A function to respond to the low fuel. After this function is called, the turtle is assumed to be refueled
---@return RefuelStrategy _
local function newRefuelStrategy(isLowFuelFunc, lowFuelResponseFunc)
    ---@class RefuelStrategy
    local stategy = {
        isLowFuel = isLowFuelFunc,
        lowFuelResponse = lowFuelResponseFunc
    }
    return stategy
end

--- A function to ensure the turtle is sufficiently fueled
---@param refuelStrategy RefuelStrategy
local function ensureFueled(refuelStrategy)
    if refuelStrategy.isLowFuel() then
        refuelStrategy.lowFuelResponse()
    end
end

--- Create a default `RefuelStrategy` using `isFuelBelowHardcoded` and `awaitRefuelFromCurrentSlot`
---@return RefuelStrategy _
local function defaultHardcoded()
    return newRefuelStrategy(isFuelBelowHardcoded, awaitRefuelFromCurrentSlot(isFuelBelowHardcoded))
end

return {
    awaitRefuelFromCurrentSlot = awaitRefuelFromCurrentSlot,
    ignoreLowFuel = ignoreLowFuel,
    isFuelBelowHardcoded = isFuelBelowHardcoded,
    isFuelBelowValue = isFuelBelowValue,

    ensureFueled = ensureFueled,
    newRefuelStrategy = newRefuelStrategy,
    defaultHardcoded = defaultHardcoded
}