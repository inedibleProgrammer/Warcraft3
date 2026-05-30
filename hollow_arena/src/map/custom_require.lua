function InitCustomRequire()
  _G.__custom_require = _G.__custom_require or {}

  _G.__custom_require.modules = _G.__custom_require.modules or {}
  _G.__custom_require.cache = _G.__custom_require.cache or {}
  _G.__custom_require.loading = _G.__custom_require.loading or {}

  local state = _G.__custom_require
  local modules = state.modules
  local cache = state.cache
  local loading = state.loading

  local function custom_require(name)
    if cache[name] ~= nil then
      return cache[name]
    end

    if loading[name] then
      error("Circular require detected for module: " .. tostring(name), 2)
    end

    local moduleFn = modules[name]

    if moduleFn == nil then
      error("Module not found: " .. tostring(name), 2)
    end

    loading[name] = true

    local ok, result = pcall(moduleFn)

    loading[name] = nil

    if not ok then
      error(result, 2)
    end

    if result == nil then
      result = true
    end

    cache[name] = result

    return result
  end

  _G.require = custom_require
end
