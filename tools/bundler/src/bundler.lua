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

--[[
^        start of string
(.*)     capture any characters, greedily
[/\\]    match either / or \
[^/\\]*  match the final filename part, containing no / or \
$        end of string

“Find the last slash or backslash in the path, return everything before it. If there is no directory part, return .”
]]
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

  return text, output
end

return Bundler
