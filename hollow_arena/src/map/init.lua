function InitLua()
  InitCustomRequire()
  InitModules()

  local Person = require("person")
  local People = require("people")

  local joe = Person.new("Joe", 14)

  joe:talk()

  People.person1:talk()

end
