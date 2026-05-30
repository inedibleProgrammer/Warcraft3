package.path = table.concat({
  "../tools/bundler/src/?.lua",
  package.path,
}, ";")

local Bundler = require("bundler")

local config_path = "bundler-config.lua"
local _, output = Bundler.bundle(config_path)

print("Bundled map Lua written to: " .. output)
