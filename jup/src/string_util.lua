local string_util = {}

-- Example:
-- local directories, filename = string_util.split_path(file_name)
function string_util.split_path(path)
    local directories, filename = path:match("^(.*)/([^/]+)$")

    -- Handle filenames with no directory
    if not filename then
        return "", path
    end

    return directories, filename
end

function string_util.lua_module_name(path)
  return path:match("([^/]+)%.lua$")
end

return string_util
