
---@enum LogLevel
local LogLevel = {
    ERROR = 0,
    WARN = 1,
    INFO = 2,
    DEBUG = 3
}

if LOGLEVEL == nil then
    LOGLEVEL = LogLevel.DEBUG
end

LOG_FILE_DIRECTORY = "logs/"
LOG_FILE_NAME = "log"
LOG_FILE_EXTENSION = ".log"

--- Opens a new log file. This function will terminate the program if it cannot
--- be opened, so the handle returned is guaranteed to be valid
---@return file*
local function _openNewLogFile()
    local prefix = LOG_FILE_DIRECTORY .. LOG_FILE_NAME
    local postfix = LOG_FILE_EXTENSION

    local i = 0
    while fs.exists(prefix .. string.format("%02d", i) .. postfix) do
        i = i + 1
    end

    local f = io.open(prefix .. string.format("%02d", i) .. postfix, "w")
    if f ~= nil then
        return f
    end

    local curColor = term.getTextColor()
    term.setTextColor(colors.red)
    print("[Critical <log>] Unable to open log file")
    term.setTextColor(curColor)
    error("Unable to open log file")
end

if CURRENT_LOG_FILE == nil then
    CURRENT_LOG_FILE = _openNewLogFile()
end

local function _printAndLog(...)
    CURRENT_LOG_FILE:write(...)
    CURRENT_LOG_FILE:write("\n")
    CURRENT_LOG_FILE:flush()
    print(...)
end

--- Set the global log level
---@param level LogLevel
local function setLogLevel(level)
    LOGLEVEL = level
end

--- Create a scoped logger
---@param scopeName string The name of the scope.
---@return Logger _
local function as(scopeName)

    ---@alias LogFn fun(...)

    ---@class Logger
    local logger = {
        ---@type LogFn
        blocked = function(...)
            local curColor = term.getTextColor()
            term.setTextColor(colors.red)
            _printAndLog("[Action Required <"..scopeName..">]:", ...)
            term.setTextColor(curColor)
        end,

        ---@type LogFn
        error = function(...)
            if LOGLEVEL >= LogLevel.ERROR then
                local curColor = term.getTextColor()
                term.setTextColor(colors.red)
                _printAndLog("[Error <"..scopeName..">]:", ...)
                term.setTextColor(curColor)
            end
        end,

        ---@type LogFn
        warn = function(...)
            if LOGLEVEL >= LogLevel.WARN then
                local curColor = term.getTextColor()
                term.setTextColor(colors.yellow)
                _printAndLog("[Warn <"..scopeName..">]:", ...)
                term.setTextColor(curColor)
            end
        end,

        ---@type LogFn
        info = function(...)
            if LOGLEVEL >= LogLevel.INFO then
                local curColor = term.getTextColor()
                term.setTextColor(colors.blue)
                _printAndLog("[Info <"..scopeName..">]:", ...)
                term.setTextColor(curColor)
            end
        end,

        ---@type LogFn
        debug = function(...)
            if LOGLEVEL >= LogLevel.DEBUG then
                local curColor = term.getTextColor()
                term.setTextColor(colors.purple)
                _printAndLog("[Debug <"..scopeName..">]:", ...)
                term.setTextColor(curColor)
            end
        end,

        --- Set the global log level
        ---@type fun(level: LogLevel)
        setLogLevel = setLogLevel,
        LogLevel = LogLevel,
    }

    return logger
end

return {
    LogLevel = LogLevel,
    setLogLevel = setLogLevel,
    as = as
}
-- log = require("lib.log").as("my_module")