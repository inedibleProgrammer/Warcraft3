-- luacheck: globals TestBundler
local lu = require("luaunit")
local bundler = require("bundler")
-- local dbg = require("debugger")

local string_util = require("string_util")

TestBundler = {}

local fake_bundler_config1 = [[
 return {
     output = "build/pretend_bundler_output_bundled.lua"

     custom_require = "pretend_custom_require.lua"

     modules = {
         "person.lua",
     }

     init = "pretend_bundler_init.lua"
 }
]]

local fake_custom_require1 = [[
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

if not WORLD_EDITOR then
  local custom_require = {}

  custom_require.init_custom_require = InitCustomRequire

  return custom_require
else
  local function xpcall_init_custom_require()
    InitCustomRequire(_G)
  end
  xpcall(xpcall_init_custom_require, print)
end
]]


local fake_lua_init1 = [[
function LuaInit()
  InitCustomRequire()
  InitModules()

  local Person = require("person")

  person1 = Person.new()
  person1.say_hello()

end
]]

local fake_person1 = [[
local Person = {}

function Person.say_hello()
  print("Hello!")
end

return Person
]]

local _fake_io_api = {}

function _fake_io_api.open()
    return {
        write = function() end,
        read = function() return "" end,
        close = function() end,
    }
end

local _fake_os_api = {}

function _fake_os_api.execute(command_string)
  local is_successful = true
  local termination_type = "exit"
  local exit_status_code = 0

  return is_successful, termination_type, exit_status_code
end


function TestBundler.test_add_numbers()
  lu.assertEquals(2+3, 5)
end


function TestBundler.test_bundler_reads_config()
  local config_file = "/some/path/bundler_config.lua"

  local fake_os_api = {}
  fake_os_api.execute = function()
    return nil, "exit", 1
  end

  local fake_file_api = {}
  fake_file_api.file_write_contents = nil

  fake_file_api.open = function(file_name, mode)
    return {
      write = function(contents) fake_file_api.file_write_contents = contents end,

      read = function(read_setting)
        if file_name == "bundler_config.lua" then
          return fake_bundler_config1
        elseif file_name == "pretend_custom_require.lua" then
          return fake_custom_require1
        elseif file_name == "pretend_bundler_init.lua" then
          return fake_lua_init1
        elseif file_name == "person.lua" then
          return fake_person1
        end
      end,
      close = function() end,
    }
  end

  bundler.bundle(fake_file_api, fake_os_api, config_file)

  print(fake_file_api.file_write_contents)
end
