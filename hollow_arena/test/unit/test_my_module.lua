-- luacheck: globals TestMyModule

local lu = require("luaunit")
local my_module = require("my_module")

TestMyModule = {}

-- luacheck: ignore 212
function TestMyModule:test_add_numbers()
  lu.assertEquals(my_module.add_numbers(2, 3), 5)
end
