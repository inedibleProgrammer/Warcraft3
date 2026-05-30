local luaunit = require("luaunit")
local Bundler = require("bundler")

local function make_fs(files)
  local fs = {
    writes = {},
  }

  function fs.read(path)
    local text = files[path]

    if text == nil then
      error("missing mock file: " .. path, 2)
    end

    return text
  end

  function fs.write(path, text)
    fs.writes[path] = text
  end

  return fs
end

local function index_of(text, needle)
  local index = text:find(needle, 1, true)

  luaunit.assertNotNil(index, "missing text: " .. needle)

  return index
end

TestBundler = {}

function TestBundler:test_bundle_writes_world_editor_file()
  local fs = make_fs({
    ["hollow_arena/src/map/custom_require.lua"] = [[
function InitCustomRequire()
  _G.require = function(name)
    return _G.__custom_require.modules[name]()
  end
end
]],

    ["hollow_arena/src/game/person.lua"] = [[
local Person = {}

function Person.new(name)
  return {
    name = name,
  }
end

return Person
]],

    ["hollow_arena/src/map/init.lua"] = [[
function InitLua()
  InitCustomRequire()
  InitModules()

  local Person = require("person")
  local joe = Person.new("Joe")

  print(joe.name)
end
]],
  })

  local config = {
    output = "build/hollow_arena.wc3.lua",
    custom_require = "src/map/custom_require.lua",
    modules = {
      {
        name = "person",
        path = "src/game/person.lua",
      },
    },
    init = "src/map/init.lua",
  }

  local text, output = Bundler.bundle("hollow_arena/bundler-config.lua", {
    fs = fs,
    config = config,
  })

  luaunit.assertEquals(output, "hollow_arena/build/hollow_arena.wc3.lua")
  luaunit.assertEquals(fs.writes[output], text)

  luaunit.assertTrue(index_of(text, "function InitCustomRequire()") < index_of(text, "function InitModules()"))
  luaunit.assertTrue(index_of(text, "function InitModules()") < index_of(text, "function InitLua()"))

  luaunit.assertStrContains(text, '_G.__custom_require.modules["person"] = function()')
  luaunit.assertStrContains(text, "local Person = {}")
  luaunit.assertStrContains(text, 'local Person = require("person")')
end

function TestBundler:test_bundle_supports_multiple_modules_in_config_order()
  local fs = make_fs({
    ["map/src/map/custom_require.lua"] = "function InitCustomRequire() end",
    ["map/src/game/a.lua"] = "return 'a'",
    ["map/src/game/b.lua"] = "return 'b'",
    ["map/src/map/init.lua"] = "function InitLua() end",
  })

  local config = {
    output = "build/map.wc3.lua",
    custom_require = "src/map/custom_require.lua",
    modules = {
      {
        name = "a",
        path = "src/game/a.lua",
      },
      {
        name = "b",
        path = "src/game/b.lua",
      },
    },
    init = "src/map/init.lua",
  }

  local text = Bundler.bundle("map/bundler-config.lua", {
    fs = fs,
    config = config,
  })

  luaunit.assertTrue(
    index_of(text, '_G.__custom_require.modules["a"] = function()')
      < index_of(text, '_G.__custom_require.modules["b"] = function()')
  )
end

function TestBundler:test_build_rejects_missing_required_config()
  local err = luaunit.assertErrorMsgContains(
    "missing config.custom_require",
    function()
      Bundler.build({
        init = "src/map/init.lua",
      })
    end
  )

  luaunit.assertNil(err)
end

os.exit(luaunit.LuaUnit.run())
