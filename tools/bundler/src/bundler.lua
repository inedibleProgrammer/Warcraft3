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
  output_file:close()
end

return Bundler
