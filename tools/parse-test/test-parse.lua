-- Offline parse verification: load the real BrinyBest.lua with a stubbed WoW API
-- and run its parser against real localized description text per locale.

local ADDON = (os.getenv("BRINYBEST_LUA") or "../../BrinyBest.lua")
local DIR = ADDON:match("^(.*[\\/])") or "./"
local SEP = DIR:find("\\", 1, true) and "\\" or "/"
local LOCALEDIR = DIR .. "Locales" .. SEP

-- Outside the client there is no addon table to hand out, so stand in for it: the locale
-- files fill ns.Locale, then BrinyBest.lua reads it, exactly as the .toc order does in-game.
-- That order is read out of BrinyBest.toc rather than kept as a second copy here -- in-game
-- the client reads that same file, so the two cannot drift apart.
local function tocLocaleOrder(path)
  local f, err = io.open(path, "rb")
  if not f then return nil, err end
  local text = f:read("*a")
  f:close()
  local order = {}
  for line in (text .. "\n"):gmatch("([^\n]*)\n") do
    local code = line:match("^%s*Locales[\\/]([%a%d_]+)%.lua%s*$")
    if code then order[#order + 1] = code end
  end
  return order
end

local LOCALE_ORDER, terr = tocLocaleOrder(DIR .. "BrinyBest.toc")
if not LOCALE_ORDER or #LOCALE_ORDER == 0 then
  print("no Locales\\ entries in BrinyBest.toc: " .. tostring(terr or "found none"))
  os.exit(1)
end

-- What to run: every locale the .toc loads that fetch-descs.py left a fixture for, so the
-- list needs no maintenance of its own. A locale the fetch hasn't covered yet shows up in
-- the skipped line below, and a run with nothing left to do fails rather than passing.
local LOCALES, skipped = {}, {}
for _, code in ipairs(LOCALE_ORDER) do
  local f = io.open("descs_" .. code .. ".lua", "rb")
  if f then
    f:close()
    LOCALES[#LOCALES + 1] = code
  else
    skipped[#skipped + 1] = code
  end
end
if #LOCALES == 0 then
  print("no descs_*.lua fixtures in the working directory -- run fetch-descs.py first")
  os.exit(1)
end

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

  local ns = {}
  for _, code in ipairs(LOCALE_ORDER) do
    local lchunk, lerr = loadfile(LOCALEDIR .. code .. ".lua", "t", env)
    if not lchunk then return nil, "locale " .. code .. " load: " .. tostring(lerr) end
    local lok, lrerr = pcall(lchunk, "BrinyBest", ns)
    if not lok then return nil, "locale " .. code .. " run: " .. tostring(lrerr) end
  end

  local chunk, err = loadfile(ADDON, "t", env)
  if not chunk then return nil, "load: " .. tostring(err) end
  local ok, rerr = pcall(chunk, "BrinyBest", ns)
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

if #skipped > 0 then
  print(("not parsed (no descs fixture): %s"):format(table.concat(skipped, " ")))
end
for _, loc in ipairs(LOCALES) do
  local res, err = runLocale(loc)
  print(("%-5s %s"):format(loc, res or ("FAIL " .. err)))
end
