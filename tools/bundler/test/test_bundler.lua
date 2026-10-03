-- luacheck: globals TestBundler
local lu = require("luaunit")
local bundler = require("bundler")
-- local dbg = require("debugger")

TestBundler = {}

function TestBundler.test_wrap_module()
  local source = [[local person = {}

function person.name()
  return "Joe"
end

return person]]
  local expected = [[__custom_require.modules["person"] = function()
local person = {}

function person.name()
  return "Joe"
end

return person
end
]]

  lu.assertEquals(bundler.wrap_module("person", source), expected)
end

function TestBundler.test_bundler_evaluates_lua_config()
  local files = {
    ["bundler_config.lua"] = [[
      local output_dir = "build/"
      return {
        output = output_dir .. "map.lua",
        custom_require = "custom_require.lua",
        modules = {},
        init = "init.lua",
      }
    ]],
    ["custom_require.lua"] = "",
    ["init.lua"] = "",
  }
  local output_path
  local file_api = {
    open = function(path, mode)
      if mode == "w" then
        output_path = path
        return {
          write = function() end,
          close = function() end,
        }
      end

      return {
        read = function()
          return assert(files[path], "Unexpected input file: " .. path)
        end,
        close = function() end,
      }
    end,
  }
  local os_api = {
    execute = function() return true end,
  }

  bundler.bundle(file_api, os_api, "bundler_config.lua")

  lu.assertEquals(output_path, "build/map.lua")
end

function TestBundler.test_bundler_writes_wrapped_module()
  local files = {
    ["bundler_config.lua"] = [[
      return {
        output = "build/map.lua",
        custom_require = "custom_require.lua",
        modules = { "person.lua" },
        init = "init.lua",
      }
    ]],
    ["custom_require.lua"] = "",
    ["person.lua"] = 'return { name = "Joe" }',
    ["init.lua"] = "",
  }
  local output = ""
  local file_api = {
    open = function(path, mode)
      if mode == "w" then
        lu.assertEquals(path, "build/map.lua")
        return {
          write = function(_, ...)
            output = output .. table.concat({ ... })
          end,
          close = function() end,
        }
      end

      return {
        read = function()
          return assert(files[path], "Unexpected input file: " .. path)
        end,
        close = function() end,
      }
    end,
  }
  local os_api = {
    execute = function() return true end,
  }
  local expected = [[function InitModules()
__custom_require.modules["person"] = function()
return { name = "Joe" }
end
end
]]

  bundler.bundle(file_api, os_api, "bundler_config.lua")

  lu.assertEquals(output, expected)
end
