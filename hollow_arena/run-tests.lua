-- Make project modules visible.
package.path = table.concat({
  "src/game/?.lua",
  "test/unit/?.lua",
  "../libs/luaunit/?.lua",
  "../libs/debugger/?.lua",
  package.path,
}, ";")

local lu = require("luaunit")

-- Require each test file here.
require("test_my_module")

os.exit(lu.LuaUnit.run())
