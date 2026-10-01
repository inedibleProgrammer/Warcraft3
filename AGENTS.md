# Agents File

This repo is my warcraft 3 (wc3) custom map making Lua collection. I am prioritizing TDD and unit testing using the Lua Unit test framework. We also will be using luacheck frequently. 

The goal is to keep the code testable so that tests can be run outside of the world editor.

WC3 Lua programming has a number of problems

First, `require` cannot be used. So I have my own custom require. See `hollow_arena/src/custom_require.lua`

In order to make `custom_require` work, I need to wrap all of my modules in some helper code. This is the purpose of the bundler. See `tools/bundler`.

Another problem is the fact that desyncs are a common problem with custom maps. So we need to code a certain way:
 - Never use `pairs` only `ipairs`

# Bundler

The bundler takes in a configuration file. The configuration file is itself a Lua file and specifies:
 - An output file name
 - The custom_require.lua file
 - A table list of modules' paths
 - An init.lua file

Here is an example configuration file:

```
return {
    output = "build/pretend-bundler-output-bundled.lua"

    custom_require = "dir3/pretend_custom_require.lua"

    modules = {
        "dir1/dir2/person.lua",
    }

    init = "dir4/pretend_bundler_init.lua"
}
```

The bundler concatenates all of the files together into one output file which can then be copied and pasted into the world editor

This is an example output file:

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

function InitModules(global_table)
    global_table.__custom_require.modules["person"] = function()
        local Person = {}

        function Person.say_hello()
            print("Hello!")
        end

        return Person
    end
end

function LuaInit()
    print("LuaInit")
  InitCustomRequire(_G)
  InitModules(_G)

  local Person = require("person")

  Person.say_hello()

end

```

# Coding Standard

- Use 2 space indents


