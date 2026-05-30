local script_path = arg and arg[0] or "tools/bundler/run-tests.lua"
local script_dir = script_path:match("^(.*)[/\\][^/\\]*$") or "."

package.path = table.concat({
  script_dir .. "/src/?.lua",
  script_dir .. "/test/?.lua",
  script_dir .. "/../../libs/luaunit/?.lua",
  package.path,
}, ";")

require("bundler_tests")
