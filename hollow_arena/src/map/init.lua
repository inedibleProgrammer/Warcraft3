function InitLua()
  InitCustomRequire()
  InitModules()

  local MessageLog = require("message_log")
  local Wc3LogReporter = require("wc3_log_reporter")
  local SafeCall = require("safe_call")

  local log = MessageLog.new()
  local reporter = Wc3LogReporter.new(log, print)

  SafeCall.try("InitGame", function()
    -- game init here

    local Person = require("person")
    local People = require("people")

    local joe = Person.new("Joe", 14)

    joe:talk()

    People.person1:talk()
  end, {
    log = log,
    screenPrint = print,
  })

  reporter:printLatestPage()
end
