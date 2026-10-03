local script = arg[0]
local script_dir = script:match("^(.*[/\\])") or "./"
package.path = package.path
  .. ";" .. script_dir .. "../tools/bundler/src/?.lua"
  .. ";" .. script_dir .. "../jup/src/?.lua"

local Bundler = require("bundler")

local FileApi = io
local OSApi = os

Bundler.bundle(FileApi, OSApi, "bundler_config.lua")





