-- luacheck: globals TestLogger


local lu = require("luaunit")
local logger = require("logger")
-- local dbg = require("debugger")

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
  testlogger:log(logger.INFO, "first info message")

  lu.assertEquals(testlogger.entries[1].index, 1)
  lu.assertEquals(testlogger.entries[1].time, 10)
  lu.assertEquals(testlogger.entries[1].level, "INFO")
  lu.assertEquals(testlogger.entries[1].message, "first info message")
  lu.assertEquals(#testlogger.entries, 1)

  testlogger:log(logger.INFO, "second info message")
  lu.assertEquals(testlogger.entries[2].index, 2)
  lu.assertEquals(#testlogger.entries, 2)

  lu.assertEquals(testlogger:format(testlogger.entries[1]), "[1] [10] [INFO] first info message")
end

