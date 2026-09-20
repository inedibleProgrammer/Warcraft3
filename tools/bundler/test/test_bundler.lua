-- luacheck: globals TestBundler
local lu = require("luaunit")
local bundler = require("bundler")
-- local dbg = require("debugger")

TestBundler = {}

function TestBundler.test_add_numbers()
  lu.assertEquals(2+3, 5)
end


function TestBundler.test_something()
  local file_io = {
    
  }

  local 
end
