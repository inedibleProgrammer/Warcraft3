local Bundler = {}

local string_util = require("string_util")

local function try_read_file(file_api, file_name)
    local file_data = {}
    file_data.success = false

    local file_handle, file_error = file_api.open(file_name, "r")

    if not file_handle then
        file_data.file_error = file_error
        error("Could not read file: ", file_data.file_error)
    else
        file_data.success = true
        file_data.file_contents = file_handle:read("*a")

        file_data.file_handle = file_handle
        file_data.file_error = file_error

        file_handle:close()
    end

    return file_data
end

function Bundler.bundle(file_api, os_api, config_file_path)
  local config_file_data = try_read_file(file_api, config_file_path)

  print(config_file_data.file_contents)
  local config_file_chunk, config_file_load_error = load(config_file_data.file_contents)

  if not config_file_chunk then
    error(config_file_load_error)
  end

  local config = config_file_chunk()

  print(config.output)
end

  -- config_file_dir, config_file_name = string_util.split_path(config_file_path)



  -- os_api.execute("mkdir -p " .. con)


return Bundler
