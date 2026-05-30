return {
  output = "build/hollow_arena.wc3.lua",

  custom_require = "src/map/custom_require.lua",

  modules = {
    {
      name = "person",
      path = "src/game/person.lua",
    },
    {
      name = "people",
      path = "src/game/people.lua",
    },
  },

  init = "src/map/init.lua",
}
