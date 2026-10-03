return {
  output = "build/hollow_arena_bundled.lua",

  custom_require = "src/custom_require.lua",

  modules = {
    "src/person.lua",
    "src/people.lua",
    "src/dummy_module.lua",
  },

  init = "src/init.lua",
}
