# Bundler

Lua inside of the warcraft 3 editor doesn't allow the use of `require`. So, I made my own custom require, which needs every module to be wrapped in some code to make it work.

The bundler concatenates files specified in a configuration file and makes sure modules are wrapped as needed, and then outputs one large lua file which can be copied and pasted into the editor.


# Warcraft 3 World Editor Entrypoint

The entry point is specified using the GUI in the world editor. I will set it to call `LuaInit` when the map starts.

```
function LuaInit()
  InitCustomRequire()
  InitModules() -- Wraps each module in the code to make `require` work

  -- Map code
end
```

# Bundler Config File

This is an example config file:

```
return {
    output = "build/pretend-bundler-output-bundled.lua",

    custom_require = "pretend_custom_require.lua",

    modules = {
        "person.lua",
    },

    init = "pretend_bundler_init.lua",
}
```

# Custom Require

```
-- luacheck: globals WORLD_EDITOR
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
```

# Modules

This is a test demonstrating how the custom require should work for each module


```
function TestCustomRequire.test_require_single_module()
  local fake_global_table = {}
  cr.init_custom_require(fake_global_table)

  fake_global_table.__custom_require.modules["module1"] = function()
    local module1 = {}

    function module1.module1_func()
      return "module1.module1_func"
    end

    return module1
  end

  local loaded_module = fake_global_table.require("module1")

  lu.assertEquals(
    loaded_module.module1_func(),
    "module1.module1_func"
  )
end
```




