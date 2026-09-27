-- luacheck: globals TestBundler
local lu = require("luaunit")
local bundler = require("bundler")
-- local dbg = require("debugger")

TestBundler = {}

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
  local fake_os_api = {}
  fake_os_api.execute = function()
    return nil, "exit", 1
  end

  local fake_file_api = {}

  fake_file_api.open = function()
    return {
      write = function() end,
      read = function() return "hello world" end,
      close = function() end,
    }
  end

  local config_file = "/some/path/bundler_config.lua"
  local file_name = "dir1/dir2/file.txt"
  local directories, filename = file_name:match("^(.-)([^/]+)$")
  bundler.bundle(file_io, config_file)
end
