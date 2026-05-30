local Person = {}
Person.__index = Person

function Person.new(name, age)
  local obj = setmetatable({}, Person)

  obj.name = name
  obj.age = age

  return obj
end

function Person:talk()
  print("Hello, I am " .. self.name)
end

return Person
