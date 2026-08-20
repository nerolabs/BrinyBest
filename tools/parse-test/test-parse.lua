-- Offline parse verification: load the real BrinyBest.lua with a stubbed WoW API
-- and run its parser against real localized description text per locale.

local ADDON = (os.getenv("BRINYBEST_LUA") or "../../BrinyBest.lua")
local LOCALES = { "enUS", "deDE", "esES", "esMX", "frFR", "itIT", "koKR", "ptBR", "ruRU", "zhCN", "zhTW" }

local function freshStubObj()
  local obj
  local mt = {}
  mt.__index = function(_, _) return function(...) return obj end end
  mt.__call = function(...) return obj end
  obj = setmetatable({}, mt)
  return obj
end

local function runLocale(loc)
  local descs = dofile("descs_" .. loc .. ".lua")
  local stub = freshStubObj()
  local env = setmetatable({
    GetLocale = function() return loc end,
    CreateFrame = function() return freshStubObj() end,
    UIParent = stub,
    GameTooltip = stub,
    SOUNDKIT = {},
    C_Timer = { After = function() end },
    C_Map = { GetBestMapForUnit = function() return nil end, GetMapInfo = function() return nil end },
    C_Spell = {
      GetSpellDescription = function(id) return descs[id] end,
      GetSpellInfo = function(id) return { name = "fish" .. id, iconID = 0 } end,
      RequestLoadSpellData = function() end,
    },
    C_AddOns = { GetAddOnMetadata = function() return "test" end },
    GetZoneText = function() return "" end,
    GetSubZoneText = function() return "" end,
    GetAchievementCriteriaInfo = function() return nil end,
    PlaySound = function() end,
    SlashCmdList = {},
    wipe = function(t) for k in pairs(t) do t[k] = nil end end,
    unpack = table.unpack,
    print = function() end,
  }, { __index = _G })
  env._G = env

  local chunk, err = loadfile(ADDON, "t", env)
  if not chunk then return nil, "load: " .. tostring(err) end
  local ok, rerr = pcall(chunk)
  if not ok then return nil, "run: " .. tostring(rerr) end
  local BB = env.BrinyBest
  if not BB then return nil, "no exports" end

  local scoreable, odd, unparsed, ranked = 0, 0, 0, 0
  local zones = {}
  for _, fdef in ipairs(BB.fish) do
    local info = BB.ParseFish(fdef)
    if not info then
      unparsed = unparsed + 1
    elseif not info.scoreable then
      odd = odd + 1
    else
      scoreable = scoreable + 1
      if info.rank then ranked = ranked + 1 end
      for _, area in ipairs(info.areas) do
        local key, disp = BB.NormalizeArea(area)
        zones[key] = zones[key] or { n = 0, disp = disp }
        zones[key].n = zones[key].n + 1
      end
    end
  end
  local zlist = {}
  for k, v in pairs(zones) do zlist[#zlist + 1] = ("%s(%d)"):format(v.disp, v.n) end
  table.sort(zlist)
  return ("scoreable=%d oddities=%d unparsed=%d rankword=%d | zones: %s"):format(
    scoreable, odd, unparsed, ranked, table.concat(zlist, " · "))
end

for _, loc in ipairs(LOCALES) do
  local res, err = runLocale(loc)
  print(("%-5s %s"):format(loc, res or ("FAIL " .. err)))
end
