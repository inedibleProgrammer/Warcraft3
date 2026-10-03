-- luacheck: globals TestCustomRequire
local lu = require("luaunit")
local cr = require("custom_require")

TestCustomRequire = {}


function TestCustomRequire.test_add_numbers()
  lu.assertEquals(2+3, 5)
end

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

function TestCustomRequire.test_require_from_module()
  local fake_global_table = {}
  cr.init_custom_require(fake_global_table)

  fake_global_table.__custom_require.modules["module1"] = function()
    local module1 = {}

    function module1.module1_func()
      return "module1.module1_func"
    end

    return module1
  end

  fake_global_table.__custom_require.modules["module2"] = function()
    local module2 = {}
    local loaded_module1 = fake_global_table.require("module1")

    lu.assertEquals(
      loaded_module1.module1_func(),
      "module1.module1_func"
    )

    function module2.module2_func()
      return "module2.module2_func"
    end

    return module2
  end

  -- local loaded_module1 = fake_global_table.require("module1")
  local loaded_module2 = fake_global_table.require("module2")

  lu.assertEquals(
    loaded_module2.module2_func(),
    "module2.module2_func"
  )
end


function TestCustomRequire.test_circular_require()
  local fake_global_table = {}
  cr.init_custom_require(fake_global_table)

  -- luacheck: push ignore 211

  fake_global_table.__custom_require.modules["module1"] = function()
    local module1 = {}
    local module2 = fake_global_table.require("module2")

    function module1.module1_func()
      return "module1.module1_func"
    end

    return module1
  end

  fake_global_table.__custom_require.modules["module2"] = function()
    local module2 = {}
    local module1 = fake_global_table.require("module1")

    function module2.module2_func()
      return "module2.module2_func"
    end

    return module2
  end

  -- luacheck: pop

  lu.assertError(function()
      fake_global_table.require("module2")
  end)

end

