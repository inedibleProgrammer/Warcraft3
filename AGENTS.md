# Agents File

This repo is my warcraft 3 (wc3) custom map making Lua collection. I am prioritizing TDD and unit testing using the Lua Unit test framework. We also will be using luacheck frequently. 

The goal is to keep the code testable so that tests can be run outside of the world editor. This means we should use the hexagonal ports and adapters architecture when possible.

WC3 Lua programming has a number of problems in the world editor:
- `require` cannot be used. So I have my own custom require. See `hollow_arena/src/custom_require.lua`
- In order to make `custom_require` work, I need to wrap all of my modules in some helper code. This is the purpose of the bundler. See `tools/bundler`.

There are also problems related to things causing "desync" which we must always be careful to avoid:
 - Never use `pairs` only `ipairs`

There are problems related to memory leaks which we must be careful to avoid

# Directory Structure




# Coding Standard

- Use 2 space indents


