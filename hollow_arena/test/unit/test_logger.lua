-- luacheck: globals TestLogger


local lu = require("luaunit")
local logger = require("logger")

TestLogger = {}
TestLogger.fake_time = 0

local function fake_time_recorder()
  return TestLogger.fake_time
end


function TestLogger.test_add_numbers()
  lu.assertEquals(2+3, 5)
end

function TestLogger.test_logger_counter()
  local testlogger = logger.new("logger", fake_time_recorder)

  TestLogger.fake_time = 10
  testlogger:log("INFO", "first info message")

  lu.assertEquals(testlogger.entries[1].time, 10)
  lu.assertEquals(testlogger.entries[1].level, "INFO")
  lu.assertEquals(testlogger.entries[1].message, "first info message")
  lu.assertEquals(#testlogger.entries, 1)
end

