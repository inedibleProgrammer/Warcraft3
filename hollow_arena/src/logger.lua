local Logger = {}

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
      time = get_time(),
      level = level,
      message = message,
    }

    table.insert(self.entries, entry)
  end

  return logger
end

return Logger
