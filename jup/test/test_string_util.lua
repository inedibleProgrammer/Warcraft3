-- luacheck: globals TestStringUtil


local lu = require("luaunit")
local string_util = require("string_util")
-- local dbg = require("debugger")

TestStringUtil = {}



function TestStringUtil.test_add_numbers()
  lu.assertEquals(2 + 3, 5)
end

function TestStringUtil.test_first()
  local path1 = "dir1/dir2/my_file.txt"
  local dirs, filename = string_util.split_path(path1)

  lu.assertEquals(dirs, "dir1/dir2")
  lu.assertEquals(filename, "my_file.txt")
end

function TestStringUtil.test_lua_module_name()
  lu.assertEquals(
    string_util.lua_module_name("src/game/person.lua"),
    "person"
  )
end
