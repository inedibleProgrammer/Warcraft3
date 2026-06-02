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
    {
      name = "build_info",
      path = "build/build_info.lua",
    },
    {
      name = "version",
      path = "src/game/version.lua",
    },
    {
      name = "message_log",
      path = "src/game/message_log.lua",
    },
    {
      name = "wc3_log_reporter",
      path = "src/game/wc3_log_reporter.lua",
    },
    {
      name = "safe_call",
      path = "src/game/safe_call.lua",
    },
  },

  init = "src/map/init.lua",
}
