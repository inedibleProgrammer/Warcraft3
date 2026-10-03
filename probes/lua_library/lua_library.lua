function LoggerInit()
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
        "[" .. tostring(entry.level) .. "] " ..
        tostring(entry.message)
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
end

function LuaInit()
  print("lua_library map start")
  local logger = LoggerInit()
  local function dummy_get_time()
    return 0
  end
  local log = logger.new("test_log", dummy_get_time)

  local function map_runner()
    log:log(logger.INFO, _G._VERSION)
    log:log(logger.INFO, VersionGet())
  end
  xpcall(map_runner, log.error_handler)
  print("after")
  -- print(require) -- nil
  -- print(_G.require) -- nil
  -- print(_VERSION) -- 5.3
  -- print(_G._VERSION) -- 5.3

  -- print("some change")
  -- log:log(logger.INFO, "run 0")

  -- print("here1")
  -- local function dummy(param1)
  --   -- print("dummy called: " .. tostring(param1))
  --   log:log(logger.INFO, "dummy called: " .. tostring(param1))

  --   error("This is an error inside of dummy")
  --   -- Never gets called
  --   -- error("This is a second error inside of dummy")
  -- end
  -- xpcall(dummy, log.error_handler, 8)
  -- print("here2")

  -- Errors like this fail silently
  -- error("this is a final error test")

  print(tostring(#log.entries))
  -- Print all logged messages
  for k, v in ipairs(log.entries) do
    print(log:format(v))
  end

  print("lua_library map end")
end
