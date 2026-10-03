function LuaInit()
  xpcall(InitCustomRequire, print, _G)
  xpcall(InitModules, print, _G)

  local function run()
    local Person = require("person")
    local People = require("people")

    local joe = Person.new("Joe", 14)

    joe:talk()

    People.person1:talk()
  end

  xpcall(run, print)

end
