local Bundler = {}

local default_fs = {}

function default_fs.read(path)
  local file, err = io.open(path, "rb")

  if not file then
    error(err, 2)
  end

  local text = file:read("*a")
  file:close()

  return text
end

function default_fs.write(path, text)
  local file, err = io.open(path, "wb")

  if not file then
    error(err, 2)
  end

  file:write(text)
  file:close()
end

function default_fs.popen(command)
  local file, err = io.popen(command, "r")

  if not file then
    error(err, 2)
  end

  local text = file:read("*a")
  local ok, close_reason, code = file:close()

  return text, ok, close_reason, code
end

local function dirname(path)
  local dir = path:match("^(.*)[/\\][^/\\]*$")

  if dir == nil or dir == "" then
    return "."
  end

  return dir
end

local function is_absolute(path)
  return path:sub(1, 1) == "/" or path:match("^%a:[/\\]") ~= nil
end

local function join(base, path)
  if base == "." or is_absolute(path) then
    return path
  end

  return base .. "/" .. path
end

local function indent(text, prefix)
  text = text:gsub("\r\n", "\n")

  if text:sub(-1) ~= "\n" then
    text = text .. "\n"
  end

  return prefix .. text:gsub("\n", "\n" .. prefix)
end

local function trim(text)
  return (text:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function shell_quote(path)
  return "'" .. path:gsub("'", "'\\''") .. "'"
end

local function git_output(fs, base_dir, args)
  local command = ("git -C %s %s"):format(shell_quote(base_dir), args)
  local text, ok = fs.popen(command)

  if not ok then
    return nil
  end

  return trim(text)
end

function Bundler.get_build_info(fs, base_dir)
  fs = fs or default_fs
  base_dir = base_dir or "."

  local git_hash_full = git_output(fs, base_dir, "rev-parse HEAD")
  local git_hash = git_output(fs, base_dir, "rev-parse --short HEAD")
  local status = git_output(fs, base_dir, "status --porcelain")

  if git_hash_full == nil or git_hash_full == "" then
    git_hash_full = "unknown"
  end

  if git_hash == nil or git_hash == "" then
    git_hash = "unknown"
  end

  return {
    git_hash = git_hash,
    git_hash_full = git_hash_full,
    git_dirty = status ~= nil and status ~= "",
  }
end

function Bundler.render_build_info(build_info)
  return table.concat({
    "return {",
    ("  git_hash = %q,"):format(build_info.git_hash),
    ("  git_hash_full = %q,"):format(build_info.git_hash_full),
    ("  git_dirty = %s,"):format(tostring(build_info.git_dirty)),
    "}",
    "",
  }, "\n")
end

function Bundler.load_config(path)
  local chunk, err = loadfile(path)

  if not chunk then
    error(err, 2)
  end

  local config = chunk()

  if type(config) ~= "table" then
    error("bundler config must return a table", 2)
  end

  return config
end

function Bundler.build(config, fs, base_dir)
  fs = fs or default_fs
  base_dir = base_dir or "."

  assert(config.custom_require, "missing config.custom_require")
  assert(config.init, "missing config.init")

  local parts = {}

  parts[#parts + 1] = fs.read(join(base_dir, config.custom_require))
  parts[#parts + 1] = ""
  parts[#parts + 1] = "function InitModules()"

  for _, module in ipairs(config.modules or {}) do
    assert(module.name, "module is missing name")
    assert(module.path, "module is missing path")

    local source = fs.read(join(base_dir, module.path))

    parts[#parts + 1] = ("  _G.__custom_require.modules[%q] = function()"):format(module.name)
    parts[#parts + 1] = indent(source, "    ")
    parts[#parts + 1] = "  end"
    parts[#parts + 1] = ""
  end

  parts[#parts + 1] = "end"
  parts[#parts + 1] = ""
  parts[#parts + 1] = fs.read(join(base_dir, config.init))

  return table.concat(parts, "\n")
end

function Bundler.bundle(config_path, options)
  options = options or {}

  local fs = options.fs or default_fs
  local config = options.config or Bundler.load_config(config_path)
  local base_dir = options.base_dir or dirname(config_path)

  local text = Bundler.build(config, fs, base_dir)
  local output = join(base_dir, config.output or "build/map.wc3.lua")

  fs.write(output, text)

  local build_info_path = join(base_dir, config.build_info_output or "build/build_info.lua")
  local build_info = options.build_info or Bundler.get_build_info(fs, base_dir)
  local build_info_text = Bundler.render_build_info(build_info)

  fs.write(build_info_path, build_info_text)

  return text, output, build_info_path
end

return Bundler
