local Bundler = {}
local string_util = require("string_util")

function Bundler.wrap_module(name, source)
  return '__custom_require.modules["' .. name .. '"] = function()\n' .. source .. '\nend\n'
end

function Bundler.bundle(file_api, _os_api, config_file_path)
  local config_file = assert(file_api.open(config_file_path, "r"))
  local config_source = config_file:read("*a")
  config_file:close()

  local config = assert(load(config_source))()
  local output_file = assert(file_api.open(config.output, "w"))

  local custom_require_file = assert(file_api.open(config.custom_require, "r"))
  local custom_require_source = custom_require_file:read("*a")
  custom_require_file:close()
  output_file:write(custom_require_source)

  output_file:write("function InitModules()\n")
  for _, path in ipairs(config.modules) do
    local module_file = assert(file_api.open(path, "r"))
    local source = module_file:read("*a")
    module_file:close()

    local name = string_util.lua_module_name(path)
    output_file:write(Bundler.wrap_module(name, source))
  end
  output_file:write("end\n")

  local init_file = assert(file_api.open(config.init, "r"))
  local init_source = init_file:read("*a")
  init_file:close()
  output_file:write(init_source)
  output_file:close()
end

return Bundler
