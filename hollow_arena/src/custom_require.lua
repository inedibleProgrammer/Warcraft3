-- luacheck: globals WORLD_EDITOR
local WORLD_EDITOR = true
local function InitCustomRequire(global_table)
  global_table.__custom_require = {}
  global_table.__custom_require.modules = {}
  global_table.__custom_require.loaded = {}
  global_table.__custom_require.loading = {}
  local function custom_require(name)
    local modules = global_table.__custom_require.modules
    local loaded = global_table.__custom_require.loaded
    local loading = global_table.__custom_require.loading

    if loaded[name] ~= nil then
      return loaded[name]
    end

    if loading[name] then
      error("circular dependency while loading '" .. name .. "'", 2)
    end

    local loader = modules[name]

    if not loader then
      error("module '" .. name .. "' not found", 2)
    end

    loading[name] = true

    local result = loader(name)

    loading[name] = nil

    if result ~= nil then
      loaded[name] = result
    elseif loaded[name] == nil then
      loaded[name] = true
    end

    return loaded[name]
  end
  global_table.require = custom_require
end

-- WORLD_EDITOR should always be nil, even in wc3 since we use the bundler to paste the code
if not WORLD_EDITOR then
  local custom_require = {}

  custom_require.init_custom_require = InitCustomRequire

  return custom_require
-- We only need to return something for unit testing
-- else
--   local function xpcall_init_custom_require()
--     InitCustomRequire(_G)
--   end
--   xpcall(xpcall_init_custom_require, print)
end
