local Logger = {}

Logger.DEBUG    = "DEBUG"
Logger.INFO     = "INFO"
Logger.WARNING  = "WARNING"
Logger.FAILURE  = "FAILURE"
Logger.CRITICAL = "CRITICAL"

-- name is a string
-- get_time is a function returning number of seconds
function Logger.new(name, get_time)
  local logger = {
    name = name,
    entries = {},
  }

  -- levels: DEBUG < INFO < WARNING < FAILURE < CRITICAL
  function logger:log(level, message)
    local entry = {
      index = 1 + #self.entries,
      time = get_time(),
      level = level,
      message = message,
    }

    table.insert(self.entries, entry)
  end

  function logger:format(entry)
    local formatted_message =
      "[" .. tostring(entry.index) .. "] " ..
      "[" .. tostring(entry.time) .. "] " ..
      "[" .. entry.level .. "] " ..
      entry.message
    return formatted_message
  end

  -- Pre-bound callback suitable for xpcall.
  logger.error_handler = function(err)
    local message = tostring(err)

    logger:log(Logger.FAILURE, message)

    return message
  end

  return logger
end

return Logger
