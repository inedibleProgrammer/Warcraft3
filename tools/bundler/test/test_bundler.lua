-- luacheck: globals TestBundler
local lu = require("luaunit")
-- local dbg = require("debugger")

TestBundler = {}

function TestBundler.test_add_numbers()
  lu.assertEquals(2+3, 5)
end


function TestBundler.test_something()
  lu.assertEquals(2+3, 5)
end
