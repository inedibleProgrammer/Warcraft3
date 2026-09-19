local script = arg[0]
local script_dir = script:match("^(.*[/\\])") or "./"
package.path = package.path
  .. ";" .. script_dir .. "src/?.lua"
  .. ";" .. script_dir .. "test/unit/?.lua"
  .. ";" .. script_dir .. "../libs/luaunit/?.lua"
  .. ";" .. script_dir .. "../libs/debugger/?.lua"

local os1, os2, os3 = os.execute("luacheck " .. script_dir .. "src " .. script_dir .. "test")

local lu = require("luaunit")

require("test_custom_require")
require("test_logger")

os.exit(lu.LuaUnit.run())
