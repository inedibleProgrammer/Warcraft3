local script = arg[0]
local script_dir = script:match("^(.*[/\\])") or "./"
package.path = package.path
  .. ";" .. script_dir .. "src/?.lua"
  .. ";" .. script_dir .. "test/?.lua"
  .. ";" .. script_dir .. "../../libs/luaunit/?.lua"
  .. ";" .. script_dir .. "../../libs/debugger/?.lua"

-- print(package.path)

local os1, os2, os3 = os.execute("luacheck " .. script_dir .. "test")

local lu = require("luaunit")
-- require("bundler_tests")

require("test_bundler")

os.exit(lu.LuaUnit.run())
