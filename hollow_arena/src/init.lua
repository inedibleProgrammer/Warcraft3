-- luacheck: globals InitCustomRequire
-- luacheck: globals InitModules

function LuaInit()
  InitCustomRequire(_G)
  InitModules(_G)

  local Person = require("person")
  local People = require("people")

  local joe = Person.new("Joe", 14)

  joe:talk()

  People.person1:talk()

end
