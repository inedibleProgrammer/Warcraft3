local Bundler = {}

local string_util = require("string_util")

local function try_read_file(file_api, file_name)
    local file_data = {}
    file_data.success = false

    local file_handle, file_error = file_api.open(file_name, "r")

    if not file_handle then
        file_data.file_error = file_error
        print("Could not read file: ", file_error)
    else
        file_data.success = true
        file_data.file_contents = file_handle:read("*a")

        file_data.file_handle = file_handle
        file_data.file_error = file_error
    end

    return file_data
end

function Bundler.bundle(file_api, os_api, config_file_name)
  dir, file_name = string_util.split_path(config_file_name)

  local config_file_data = try_read_file(file_api, config_file_name)
end


return Bundler
