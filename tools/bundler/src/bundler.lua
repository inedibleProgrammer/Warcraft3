local Bundler = {}

function Bundler.wrap_module(name, source)
  return '__custom_require.modules["' .. name .. '"] = function()\n' .. source .. '\nend\n'
end

function Bundler.bundle(file_api, _os_api, config_file_path)
  local config_file = assert(file_api.open(config_file_path, "r"))
  local config_source = config_file:read("*a")
  config_file:close()

  local config = assert(load(config_source))()
  local output_file = assert(file_api.open(config.output, "w"))
  output_file:write("function InitModules()\n")
  for _, path in ipairs(config.modules) do
    local module_file = assert(file_api.open(path, "r"))
    local source = module_file:read("*a")
    module_file:close()

    local name = path:match("([^/]+)%.lua$")
    output_file:write(Bundler.wrap_module(name, source))
  end
  output_file:write("end\n")
  output_file:close()
end

return Bundler
