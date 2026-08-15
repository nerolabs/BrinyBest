-- BrinyBest: shows Midnight Anglin' fish scores and catch ranks for your current zone.
-- Data source: each journal fish is a dummy tradeskill recipe whose spell description
-- carries "Anglin' Score: N.N points", "Catch Rank: <rank>", areas, pools, and rates.
-- /bb toggles the panel; /bb help for options.

local SCORE_SPELL = 1303630   -- The Briny Best of 'Em (warband score in description)
local ACHIEVEMENT_ID = 63510  -- The Briny Best (criteria qty = integer score / 2500)

-- Midnight Fishing journal fish (recipe/spell IDs from the tradeskill dump, 12.1)
local FISH = {
  -- Common Fish
  { id = 1225282, cat = 1 }, -- Arcane Wyrmfish
  { id = 1295409, cat = 1 }, -- Dirty Darter
  { id = 1225275, cat = 1 }, -- Gore Guppy
  { id = 1225270, cat = 1 }, -- Lynxfish
  { id = 1225269, cat = 1 }, -- Root Crab
  { id = 1225245, cat = 1 }, -- Sin'dorei Swarmer
  { id = 1295404, cat = 1 }, -- Spotted Killifish
  { id = 1295405, cat = 1 }, -- Toxic Tlhapi
  -- Uncommon Fish
  { id = 1225266, cat = 2 }, -- Bloomtail Minnow
  { id = 1225276, cat = 2 }, -- Fungalskin Pike
  { id = 1225267, cat = 2 }, -- Hollow Grouper
  { id = 1295410, cat = 2 }, -- Polluted Puffer
  { id = 1225277, cat = 2 }, -- Restored Songfish
  { id = 1225272, cat = 2 }, -- Shimmer Spinefish
  { id = 1225271, cat = 2 }, -- Shimmersiren
  { id = 1295407, cat = 2 }, -- Sulfurous Sludgefish
  { id = 1225278, cat = 2 }, -- Sunwell Fish
  { id = 1225281, cat = 2 }, -- Tender Lumifin
  -- Rare Fish
  { id = 1295411, cat = 3 }, -- Blightswarmer
  { id = 1225274, cat = 3 }, -- Blood Hunter
  { id = 1295408, cat = 3 }, -- Coiled Stargorger
  { id = 1225283, cat = 3 }, -- Eversong Trout
  { id = 1225284, cat = 3 }, -- Lucky Loa
  { id = 1225268, cat = 3 }, -- Null Voidfish
  { id = 1225273, cat = 3 }, -- Ominous Octopus
  { id = 1225280, cat = 3 }, -- Twisted Tetra
  { id = 1295406, cat = 3 }, -- Ula'tek Snakehead
  { id = 1225279, cat = 3 }, -- Warping Wise
  -- Cursed Oddities
  { id = 1305973, cat = 4 }, -- Giggling Skull
  { id = 1305975, cat = 4 }, -- Grotesque Sturgeon
  { id = 1305979, cat = 4 }, -- Loathsome Anglerfish
  { id = 1305976, cat = 4 }, -- Many-Eyed Flounder
  { id = 1305972, cat = 4 }, -- Oozing Goby
  { id = 1305978, cat = 4 }, -- Twin-Headed Snipefish
}

local CAT_HEX = { "ffffff", "1eff00", "0070dd", "a335ee" }
local CAT_RGB = { { 1, 1, 1 }, { 0.12, 1, 0 }, { 0, 0.44, 0.87 }, { 0.64, 0.21, 0.93 } }
local RANK_NUM = { Guppy = 1, Minnow = 2, Pike = 3, Shark = 4, Trophy = 5 }
local RANK_HEX = { Guppy = "9d9d9d", Minnow = "1eff00", Pike = "0070dd", Shark = "a335ee", Trophy = "ff8000" }

local ROW_HEIGHT = 15
local FRAME_WIDTH = 320

local function chat(msg)
  print("|cff33ff99BrinyBest:|r " .. msg)
end

-- ---------------------------------------------------------------- parsing

local function stripCodes(s)
  s = s:gsub("|H(.-)|h(.-)|h", "%2")
  s = s:gsub("|c%x%x%x%x%x%x%x%x", "")
  s = s:gsub("|cn.-:", "")
  s = s:gsub("|r", "")
  s = s:gsub("|T.-|t", "")
  s = s:gsub("|A.-|a", "")
  return s
end

local function parseFish(fdef)
  local desc = C_Spell.GetSpellDescription(fdef.id)
  if not desc or desc == "" then return nil end
  desc = stripCodes(desc)
  local si = C_Spell.GetSpellInfo(fdef.id)
  local info = {
    id = fdef.id,
    cat = fdef.cat,
    name = (si and si.name) or ("spell " .. fdef.id),
    icon = si and si.iconID,
    areas = {},
    pools = {},
    rates = {},
  }
  info.score = tonumber(desc:match("Anglin' Score:%s*([%d%.]+)")) or 0
  local rankLine = desc:match("Catch Rank:%s*([^\n\r]+)")
  if rankLine and not rankLine:find("%[") then
    local word = rankLine:match("%a+")
    if word and RANK_NUM[word] then info.rank = word end
  end
  info.rankNum = info.rank and RANK_NUM[info.rank] or 0

  local mode, lastHeader
  for rawLine in desc:gmatch("[^\n\r]+") do
    local line = rawLine:match("^%s*(.-)%s*$")
    if line:find("^Areas you can find") then
      mode = "areas"
    elseif line:find("^Fishing Pools:") then
      mode = "pools"
    elseif line:find("^Rates:") then
      mode = "rates"
    elseif line:find("^Description:") then
      mode = nil
    elseif line:find("^Special:") then
      mode = "special"
      lastHeader = true
    elseif line:sub(1, 1) == "-" then
      local v = line:match("^%-+%s*(.+)$")
      if v then
        if mode == "areas" then
          info.areas[#info.areas + 1] = v
        elseif mode == "pools" then
          info.pools[#info.pools + 1] = v
        elseif mode == "rates" then
          info.rates[#info.rates + 1] = v
        end
      end
    elseif mode == "special" and lastHeader and line ~= "" then
      info.special = line
      lastHeader = false
      mode = nil
    end
  end

  -- All Midnight fish can be caught in both open water and pools; the Rates text
  -- only expresses where the catch rate is better, so the tag shows bias, not exclusivity.
  local rateText = table.concat(info.rates, " "):lower()
  local mentionsOpen = rateText:find("open water") ~= nil
  local mentionsPool = rateText:find("pool") ~= nil
  if mentionsPool and rateText:find("only") then
    info.bias = "poolsonly"
  elseif mentionsOpen and mentionsPool then
    info.bias = "both"
  elseif mentionsOpen then
    info.bias = "open"
  elseif mentionsPool then
    info.bias = "pools"
  end
  return info
end

local function sourceSuffix(info)
  if info.bias == "open" then
    return " |cff69ccf0(open)|r"
  elseif info.bias == "pools" then
    return " |cffffcc00(pool)|r"
  elseif info.bias == "poolsonly" then
    return " |cffff7f3f(pool only)|r"
  elseif info.bias == "both" then
    return " |cff1eff00(either)|r"
  end
  return ""
end

-- ---------------------------------------------------------------- warband score

local function warbandScore()
  local ok, _, _, _, qty = pcall(GetAchievementCriteriaInfo, ACHIEVEMENT_ID, 1)
  local critQty = ok and qty or nil
  local desc = C_Spell.GetSpellDescription(SCORE_SPELL)
  local precise = desc and desc:match("([%d%.]+)%s*points")
  return precise or (critQty and tostring(critQty)) or "?", critQty
end

-- ---------------------------------------------------------------- zone matching

local function currentZoneNames()
  local names = {}
  local z = GetZoneText()
  if z and z ~= "" then names[z:lower()] = true end
  local sub = GetSubZoneText()
  if sub and sub ~= "" then names[sub:lower()] = true end
  local mapID = C_Map.GetBestMapForUnit("player")
  local hops = 0
  while mapID and hops < 6 do
    local mi = C_Map.GetMapInfo(mapID)
    if not mi then break end
    if mi.name then names[mi.name:lower()] = true end
    mapID = (mi.parentMapID and mi.parentMapID > 0) and mi.parentMapID or nil
    hops = hops + 1
  end
  return names
end

-- ---------------------------------------------------------------- UI

local frame = CreateFrame("Frame", "BrinyBestFrame", UIParent, "BackdropTemplate")
frame:SetWidth(FRAME_WIDTH)
frame:SetFrameStrata("MEDIUM")
frame:SetClampedToScreen(true)
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetBackdrop({
  bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
  edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
  tile = true, tileSize = 16, edgeSize = 12,
  insets = { left = 3, right = 3, top = 3, bottom = 3 },
})
frame:SetBackdropColor(0, 0, 0, 0.75)
frame:Hide()

frame:SetScript("OnDragStart", function(self)
  if not BrinyBestDB.locked then self:StartMoving() end
end)
frame:SetScript("OnDragStop", function(self)
  self:StopMovingOrSizing()
  local point, _, relPoint, x, y = self:GetPoint()
  BrinyBestDB.point = { point, relPoint, x, y }
end)

local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
title:SetPoint("TOPLEFT", 10, -8)
title:SetJustifyH("LEFT")

local scoreLine = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
scoreLine:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -2)
scoreLine:SetJustifyH("LEFT")

local footer = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
footer:SetJustifyH("LEFT")

local legend = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
legend:SetJustifyH("LEFT")
legend:SetText("|cff69ccf0(open)|r / |cffffcc00(pool)|r / |cff1eff00(either)|r shows where catch rates are best")

local rows = {}
local function getRow(i)
  if rows[i] then return rows[i] end
  local row = CreateFrame("Frame", nil, frame)
  row:SetSize(FRAME_WIDTH - 20, ROW_HEIGHT)
  row.left = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  row.left:SetPoint("LEFT", 0, 0)
  row.left:SetJustifyH("LEFT")
  row.left:SetWidth(200)
  row.left:SetWordWrap(false)
  row.right = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  row.right:SetPoint("RIGHT", 0, 0)
  row.right:SetJustifyH("RIGHT")
  row.right:SetWidth(96)
  row:EnableMouse(true)
  row:SetScript("OnEnter", function(self)
    local info = self.info
    if not info then return end
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    local r, g, b = unpack(CAT_RGB[info.cat] or CAT_RGB[1])
    GameTooltip:AddLine(info.name, r, g, b)
    GameTooltip:AddLine(("Anglin' Score: %.1f points"):format(info.score), 1, 1, 1)
    if info.rank then
      GameTooltip:AddLine(("Catch Rank: |cff%s%s|r (%d of 5)"):format(RANK_HEX[info.rank], info.rank, info.rankNum), 1, 1, 1)
    else
      GameTooltip:AddLine("Catch Rank: |cff9d9d9dnot caught yet|r", 1, 1, 1)
    end
    if info.special then
      GameTooltip:AddLine("Special: " .. info.special, 0.4, 0.85, 0.4)
    end
    if #info.pools > 0 then
      GameTooltip:AddLine(" ")
      GameTooltip:AddLine("Fishing Pools:", 0.4, 0.85, 0.4)
      for _, p in ipairs(info.pools) do
        GameTooltip:AddLine("  - " .. p, 1, 1, 1)
      end
    end
    for _, rate in ipairs(info.rates) do
      GameTooltip:AddLine(rate, 0.8, 0.8, 0.6, true)
    end
    GameTooltip:AddLine("All fish can be caught in open water or pools; the tag shows the better rate.", 0.5, 0.5, 0.5, true)
    GameTooltip:Show()
  end)
  row:SetScript("OnLeave", function() GameTooltip:Hide() end)
  rows[i] = row
  return row
end

-- ---------------------------------------------------------------- update

local pendingLoads = 0
local currentList = {}

local function requestSpellData()
  for _, fdef in ipairs(FISH) do
    pcall(C_Spell.RequestLoadSpellData, fdef.id)
  end
  pcall(C_Spell.RequestLoadSpellData, SCORE_SPELL)
end

local function render(zoneLabel, list)
  title:SetText("BrinyBest — " .. zoneLabel)
  local precise, critQty = warbandScore()
  -- global max is 2700 (fish shared across zones only count once), so 2500 leaves little slack
  scoreLine:SetText(("Warband Anglin' Score: |cffffd100%s|r / 2500  |cff9d9d9d(2700 max)|r"):format(precise))

  local total, trophies = 0, 0
  for i, info in ipairs(list) do
    local row = getRow(i)
    row:ClearAllPoints()
    row:SetPoint("TOPLEFT", 10, -40 - (i - 1) * ROW_HEIGHT)
    local nameCol = ("|cff%s%s|r"):format(CAT_HEX[info.cat] or "ffffff", info.name)
    row.left:SetText(nameCol .. sourceSuffix(info))
    if info.rank then
      row.right:SetText(("%.1f  |cff%s%s|r"):format(info.score, RANK_HEX[info.rank], info.rank))
    else
      row.right:SetText(("%.1f  |cff9d9d9d—|r"):format(info.score))
    end
    row.info = info
    row:Show()
    total = total + info.score
    if info.rankNum >= 5 then trophies = trophies + 1 end
  end
  for i = #list + 1, #rows do rows[i]:Hide() end

  footer:ClearAllPoints()
  footer:SetPoint("TOPLEFT", 10, -42 - #list * ROW_HEIGHT)
  if #list > 0 then
    -- Trophy-rank fish sit at exactly 100.0, so zone max = 100 per fish
    footer:SetText(("Zone: |cffffd100%.1f|r / %d pts   Trophies: |cffff8000%d|r/%d"):format(total, #list * 100, trophies, #list))
  else
    footer:SetText("No Midnight fish recorded for this zone.")
  end
  legend:ClearAllPoints()
  legend:SetPoint("TOPLEFT", footer, "BOTTOMLEFT", 0, -2)

  frame:SetHeight(40 + #list * ROW_HEIGHT + 34)
end

local function update()
  if BrinyBestDB.hidden then
    frame:Hide()
    return
  end
  local zones = currentZoneNames()
  wipe(currentList)
  pendingLoads = 0
  for _, fdef in ipairs(FISH) do
    local info = parseFish(fdef)
    if info then
      for _, area in ipairs(info.areas) do
        if zones[area:lower()] then
          currentList[#currentList + 1] = info
          break
        end
      end
    else
      pendingLoads = pendingLoads + 1
    end
  end
  table.sort(currentList, function(a, b)
    if a.score ~= b.score then return a.score > b.score end
    return a.name < b.name
  end)

  if #currentList == 0 and not frame.manualShow then
    frame:Hide()
    return
  end
  render(GetZoneText() or "?", currentList)
  frame:Show()
end

local updatePending
local function queueUpdate(delay)
  if updatePending then return end
  updatePending = true
  C_Timer.After(delay or 0.8, function()
    updatePending = false
    update()
  end)
end

-- ---------------------------------------------------------------- events

local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_ENTERING_WORLD")
events:RegisterEvent("ZONE_CHANGED_NEW_AREA")
events:RegisterEvent("ZONE_CHANGED")
events:RegisterEvent("ZONE_CHANGED_INDOORS")
events:RegisterEvent("CRITERIA_UPDATE")
pcall(events.RegisterEvent, events, "SPELL_TEXT_UPDATE")

events:SetScript("OnEvent", function(_, event, arg1)
  if event == "ADDON_LOADED" and arg1 == "BrinyBest" then
    BrinyBestDB = BrinyBestDB or {}
    if BrinyBestDB.point then
      frame:ClearAllPoints()
      frame:SetPoint(BrinyBestDB.point[1], UIParent, BrinyBestDB.point[2], BrinyBestDB.point[3], BrinyBestDB.point[4])
    else
      frame:SetPoint("RIGHT", -80, 60)
    end
  elseif event == "PLAYER_ENTERING_WORLD" then
    requestSpellData()
    queueUpdate(1.5)
  elseif event == "SPELL_TEXT_UPDATE" then
    queueUpdate(0.5)
  elseif event == "CRITERIA_UPDATE" then
    -- fires in bursts on each catch; re-request so descriptions refresh, then re-render
    if frame:IsShown() then
      requestSpellData()
      queueUpdate(1.2)
    end
  else -- zone changes
    queueUpdate(0.3)
  end
end)

-- ---------------------------------------------------------------- slash commands

local HELP = [[
/bb              - toggle the panel
/bb lock         - lock position (click-through drag disabled)
/bb unlock       - unlock position
/bb reset        - reset position
/bb refresh      - force a data refresh
/bb debug        - print parse state for this zone to chat
]]

SLASH_BRINYBEST1 = "/bb"
SLASH_BRINYBEST2 = "/brinybest"
SlashCmdList.BRINYBEST = function(msg)
  local cmd = (msg or ""):lower():match("^%s*(%S*)")
  if cmd == "" then
    BrinyBestDB.hidden = not BrinyBestDB.hidden
    frame.manualShow = not BrinyBestDB.hidden
    if BrinyBestDB.hidden then
      frame:Hide()
      chat("hidden — /bb to show")
    else
      requestSpellData()
      update()
      if not frame:IsShown() then
        frame.manualShow = true
        update()
      end
      chat("shown")
    end
  elseif cmd == "lock" then
    BrinyBestDB.locked = true
    chat("position locked")
  elseif cmd == "unlock" then
    BrinyBestDB.locked = false
    chat("position unlocked — drag to move")
  elseif cmd == "reset" then
    BrinyBestDB.point = nil
    frame:ClearAllPoints()
    frame:SetPoint("RIGHT", -80, 60)
    chat("position reset")
  elseif cmd == "refresh" then
    requestSpellData()
    queueUpdate(0.5)
    chat("refreshing")
  elseif cmd == "debug" then
    local zones = currentZoneNames()
    local zlist = {}
    for z in pairs(zones) do zlist[#zlist + 1] = z end
    chat("zone names: " .. table.concat(zlist, ", "))
    local parsed, missing = 0, 0
    for _, fdef in ipairs(FISH) do
      local info = parseFish(fdef)
      if info then parsed = parsed + 1 else missing = missing + 1 end
    end
    chat(("parsed %d fish, %d descriptions still loading, %d in this zone"):format(parsed, missing, #currentList))
  else
    chat("commands:")
    print(HELP)
  end
end
