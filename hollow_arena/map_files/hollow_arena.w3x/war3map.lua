gg_trg_InitLua = nil
function InitGlobals()
end

function CreateUnitsForPlayer0()
local p = Player(0)
local u
local unitID
local t
local life

u = BlzCreateUnitWithSkin(p, FourCC("hpea"), 603.6, 961.5, 6.328, FourCC("hpea"))
u = BlzCreateUnitWithSkin(p, FourCC("hpea"), 400.6, 979.3, 80.697, FourCC("hpea"))
end

function CreatePlayerBuildings()
end

function CreatePlayerUnits()
CreateUnitsForPlayer0()
end

function CreateAllUnits()
CreatePlayerBuildings()
CreatePlayerUnits()
end

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


function InitModules()
  _G.__custom_require.modules["person"] = function()
    local Person = {}
    Person.__index = Person
    
    function Person.new(name, age)
      local obj = setmetatable({}, Person)
    
      obj.name = name
      obj.age = age
    
      return obj
    end
    
    function Person:talk()
      print("Hello, I am " .. self.name)
    end
    
    return Person
    
  end

  _G.__custom_require.modules["people"] = function()
    local person = require("person")
    
    local People = {}
    
    People.person1 = person.new("person1", 1)
    People.person2 = person.new("person2", 2)
    
    
    return People
    
  end

end

function InitLua()
  InitCustomRequire()
  InitModules()

  local Person = require("person")
  local People = require("people")

  local joe = Person.new("Joe", 14)

  joe:talk()

  People.person1:talk()

end

function Trig_InitLua_Actions()
    InitLua()
end

function InitTrig_InitLua()
gg_trg_InitLua = CreateTrigger()
TriggerAddAction(gg_trg_InitLua, Trig_InitLua_Actions)
end

function InitCustomTriggers()
InitTrig_InitLua()
end

function RunInitializationTriggers()
ConditionalTriggerExecute(gg_trg_InitLua)
end

function InitCustomPlayerSlots()
SetPlayerStartLocation(Player(0), 0)
SetPlayerColor(Player(0), ConvertPlayerColor(0))
SetPlayerRacePreference(Player(0), RACE_PREF_HUMAN)
SetPlayerRaceSelectable(Player(0), true)
SetPlayerController(Player(0), MAP_CONTROL_USER)
end

function InitCustomTeams()
SetPlayerTeam(Player(0), 0)
end

function main()
SetCameraBounds(-3328.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), -3584.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM), 3328.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), 3072.0 - GetCameraMargin(CAMERA_MARGIN_TOP), -3328.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), 3072.0 - GetCameraMargin(CAMERA_MARGIN_TOP), 3328.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), -3584.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM))
SetDayNightModels("Environment\\DNC\\DNCLordaeron\\DNCLordaeronTerrain\\DNCLordaeronTerrain.mdl", "Environment\\DNC\\DNCLordaeron\\DNCLordaeronUnit\\DNCLordaeronUnit.mdl")
NewSoundEnvironment("Default")
SetAmbientDaySound("LordaeronSummerDay")
SetAmbientNightSound("LordaeronSummerNight")
SetMapMusic("Music", true, 0)
CreateAllUnits()
InitBlizzard()
InitGlobals()
InitCustomTriggers()
RunInitializationTriggers()
end

function config()
SetMapName("TRIGSTR_003")
SetMapDescription("TRIGSTR_005")
SetPlayers(1)
SetTeams(1)
SetGamePlacement(MAP_PLACEMENT_USE_MAP_SETTINGS)
DefineStartLocation(0, 1984.0, -704.0)
InitCustomPlayerSlots()
SetPlayerSlotAvailable(Player(0), MAP_CONTROL_USER)
InitGenericPlayerSlots()
end

