-- BrinyProbe: in-game API probe for the Midnight Anglin' / Fishing Journal score system.
-- All output accumulates in a copyable window: /briny show, click "Select All", Cmd+C.

local ADDON_NAME = ...
local VERSION = "0.5.0"
local MAX_LINES = 6000
local ACHIEVEMENT_ID = 63510 -- The Briny Best
local DEFAULT_SPELLS = { 1225340, 1303630 } -- Midnight Anglin', The Briny Best of 'Em

local BP = CreateFrame("Frame")
local lines = {}

local function chat(msg)
  print("|cff33ff99BrinyProbe:|r " .. msg)
end

local function out(msg, ...)
  if select("#", ...) > 0 then
    local ok, formatted = pcall(string.format, msg, ...)
    msg = ok and formatted or (tostring(msg) .. " <format error>")
  end
  lines[#lines + 1] = tostring(msg)
  if #lines > MAX_LINES then
    table.remove(lines, 1)
  end
end

-- ---------------------------------------------------------------- safe access

local function safeget(t, k)
  local ok, v = pcall(function() return t[k] end)
  if ok then return v end
end

local function safepairs(t)
  local ok, iter, state, ctrl = pcall(pairs, t)
  if ok then return iter, state, ctrl end
  return function() end
end

local function shortval(v)
  local tv = type(v)
  if tv == "string" then
    if #v > 140 then v = v:sub(1, 137) .. "..." end
    v = v:gsub("|", "||") -- keep UI escape codes visible/copyable
    return string.format("%q", v)
  elseif tv == "table" then
    local ok, s = pcall(tostring, v)
    return "<table " .. (ok and s or "?") .. ">"
  elseif tv == "function" then
    return "<function>"
  end
  return tostring(v)
end

local function dumpTable(t, depth, prefix, seen)
  seen = seen or {}
  if seen[t] then out(prefix .. "<cycle>") return end
  seen[t] = true
  local keys = {}
  for k in safepairs(t) do keys[#keys + 1] = k end
  table.sort(keys, function(a, b) return tostring(a) < tostring(b) end)
  local shown = 0
  for _, k in ipairs(keys) do
    if shown >= 250 then
      out(prefix .. ("... (%d more keys)"):format(#keys - shown))
      break
    end
    shown = shown + 1
    local v = safeget(t, k)
    if type(v) == "table" and depth > 1 then
      out(prefix .. tostring(k) .. " = {")
      dumpTable(v, depth - 1, prefix .. "    ", seen)
      out(prefix .. "}")
    else
      out(prefix .. tostring(k) .. " = " .. shortval(v))
    end
  end
  if shown == 0 then out(prefix .. "(empty or unreadable)") end
end

-- ---------------------------------------------------------------- output window

local win
local function ensureWindow()
  if win then return win end
  win = CreateFrame("Frame", "BrinyProbeWindow", UIParent, "BackdropTemplate")
  win:SetSize(780, 540)
  win:SetPoint("CENTER")
  win:SetMovable(true)
  win:EnableMouse(true)
  win:RegisterForDrag("LeftButton")
  win:SetScript("OnDragStart", win.StartMoving)
  win:SetScript("OnDragStop", win.StopMovingOrSizing)
  win:SetFrameStrata("DIALOG")
  win:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 8, right = 8, top = 8, bottom = 8 },
  })

  local title = win:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  title:SetPoint("TOP", 0, -16)
  title:SetText("BrinyProbe — Select All, then Cmd/Ctrl+C to copy")

  local scroll = CreateFrame("ScrollFrame", "BrinyProbeScroll", win, "UIPanelScrollFrameTemplate")
  scroll:SetPoint("TOPLEFT", 16, -38)
  scroll:SetPoint("BOTTOMRIGHT", -36, 46)

  local eb = CreateFrame("EditBox", nil, scroll)
  eb:SetMultiLine(true)
  eb:SetFontObject(ChatFontNormal)
  eb:SetWidth(720)
  eb:SetAutoFocus(false)
  eb:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
  eb:SetScript("OnTextChanged", function(self) self:SetWidth(720) end)
  scroll:SetScrollChild(eb)
  win.editBox = eb

  local selectBtn = CreateFrame("Button", nil, win, "UIPanelButtonTemplate")
  selectBtn:SetSize(110, 24)
  selectBtn:SetPoint("BOTTOMLEFT", 16, 14)
  selectBtn:SetText("Select All")
  selectBtn:SetScript("OnClick", function()
    eb:SetFocus()
    eb:HighlightText()
  end)

  local clearBtn = CreateFrame("Button", nil, win, "UIPanelButtonTemplate")
  clearBtn:SetSize(110, 24)
  clearBtn:SetPoint("LEFT", selectBtn, "RIGHT", 8, 0)
  clearBtn:SetText("Clear Log")
  clearBtn:SetScript("OnClick", function()
    wipe(lines)
    eb:SetText("")
  end)

  local closeBtn = CreateFrame("Button", nil, win, "UIPanelCloseButton")
  closeBtn:SetPoint("TOPRIGHT", -6, -6)

  return win
end

local function refreshWindow()
  local w = ensureWindow()
  w.editBox:SetText(table.concat(lines, "\n"))
  w:Show()
end

-- ---------------------------------------------------------------- probes

local function matchesAny(name, patterns)
  local l = name:lower()
  for _, p in ipairs(patterns) do
    if l:find(p, 1, true) then return true end
  end
  return false
end

local CORE_PATTERNS = { "fish", "angl", "briny" }

local function probeGlobals(patterns, dumpNamespaces)
  out("== _G SCAN: %s ==", table.concat(patterns, "/"))
  local hits = {}
  for k in safepairs(_G) do
    if type(k) == "string" and matchesAny(k, patterns) then
      hits[#hits + 1] = k
    end
  end
  table.sort(hits)
  for _, k in ipairs(hits) do
    local v = safeget(_G, k)
    out("%s  [%s]", k, type(v))
    if dumpNamespaces and type(v) == "table" and k:sub(1, 2) == "C_" then
      dumpTable(v, 1, "    ")
    end
  end
  out("(%d global matches)", #hits)
end

local function probeStringValues(pattern)
  out("== GLOBAL STRING *VALUE* SCAN: '%s' ==", pattern)
  local pat = pattern:lower()
  local found = 0
  for k, v in safepairs(_G) do
    if type(k) == "string" and type(v) == "string" and #v < 400 and v:lower():find(pat, 1, true) then
      found = found + 1
      if found <= 120 then
        out("  %s = %s", k, (v:gsub("|", "||")))
      end
    end
  end
  out("(%d string-value matches%s)", found, found > 120 and ", first 120 shown" or "")
end

local function loadDocs()
  if APIDocumentation then return true end
  pcall(C_AddOns.LoadAddOn, "Blizzard_APIDocumentation")
  pcall(C_AddOns.LoadAddOn, "Blizzard_APIDocumentationGenerated")
  return APIDocumentation ~= nil
end

local function docFuncName(f)
  local ok, s = pcall(function() return f:GetSingleOutputLine() end)
  if ok and s then return s end
  ok, s = pcall(function() return f:GetFullName(false, false) end)
  if ok and s then return s end
  return tostring(safeget(f, "Name"))
end

local function probeDocs(pattern)
  out("== API DOC SCAN: '%s' ==", pattern)
  if not loadDocs() then
    out("APIDocumentation not available (Blizzard_APIDocumentation failed to load)")
    return
  end
  local pat = pattern:lower()
  local found = 0
  for _, system in ipairs(APIDocumentation.systems or {}) do
    local sysName = tostring(safeget(system, "Namespace") or safeget(system, "Name") or "?")
    local sysMatch = sysName:lower():find(pat, 1, true) ~= nil
    local buf = {}
    for _, f in ipairs(safeget(system, "Functions") or {}) do
      local name = docFuncName(f)
      if sysMatch or name:lower():find(pat, 1, true) then
        buf[#buf + 1] = "  fn:    " .. name
      end
    end
    for _, e in ipairs(safeget(system, "Events") or {}) do
      local name = tostring(safeget(e, "LiteralName") or safeget(e, "Name"))
      if sysMatch or name:lower():find(pat, 1, true) then
        buf[#buf + 1] = "  event: " .. name
      end
    end
    for _, t in ipairs(safeget(system, "Tables") or {}) do
      local name = tostring(safeget(t, "Name"))
      if sysMatch or name:lower():find(pat, 1, true) then
        buf[#buf + 1] = "  table: " .. name
      end
    end
    if #buf > 0 then
      found = found + #buf
      out("system %s:", sysName)
      for _, line in ipairs(buf) do out(line) end
    end
  end
  out("(%d doc matches)", found)
end

local function probeEnums(pattern)
  out("== Enum SCAN: '%s' ==", pattern)
  local pat = pattern:lower()
  local found = 0
  for k, v in safepairs(Enum) do
    if type(k) == "string" and k:lower():find(pat, 1, true) then
      found = found + 1
      out("Enum.%s:", k)
      if type(v) == "table" then dumpTable(v, 1, "    ") end
    end
  end
  out("(%d enum matches)", found)
end

local function probeAchievement(id)
  id = id or ACHIEVEMENT_ID
  out("== ACHIEVEMENT %d ==", id)
  local ok, aid, name, points, completed, _, _, _, desc, _, _, reward = pcall(GetAchievementInfo, id)
  if not ok or not aid then
    out("GetAchievementInfo(%d) failed or returned nil", id)
    return
  end
  out("name=%s points=%s completed=%s", tostring(name), tostring(points), tostring(completed))
  out("desc=%s", tostring(desc))
  out("reward=%s", tostring(reward))
  local num = GetAchievementNumCriteria(id) or 0
  out("criteria count: %d", num)
  for i = 1, num do
    local ok2, cs, ctype, ccomp, qty, req, _, cflags, assetID, qtyStr, critID = pcall(GetAchievementCriteriaInfo, id, i)
    if ok2 then
      out("  [%d] %s | type=%s asset=%s qty=%s/%s (%s) done=%s flags=%s critID=%s",
        i, tostring(cs), tostring(ctype), tostring(assetID), tostring(qty), tostring(req),
        tostring(qtyStr), tostring(ccomp), tostring(cflags), tostring(critID))
    else
      out("  [%d] <error reading criteria>", i)
    end
  end
end

local function probeCurrencies()
  out("== CURRENCY SCAN (ids 1..6000, name matching fish/angl/briny/score) ==")
  local found = 0
  for id = 1, 6000 do
    local ok, info = pcall(C_CurrencyInfo.GetCurrencyInfo, id)
    if ok and info and info.name and info.name ~= "" then
      local l = info.name:lower()
      if l:find("fish", 1, true) or l:find("angl", 1, true) or l:find("briny", 1, true) or l:find("score", 1, true) then
        found = found + 1
        out("  id=%d name=%s qty=%s max=%s discovered=%s",
          id, info.name, tostring(info.quantity), tostring(info.maxQuantity), tostring(info.discovered))
      end
    end
  end
  out("(%d currency matches)", found)
end

local function probeSpell(id)
  out("== SPELL %d ==", id)
  local info = C_Spell and C_Spell.GetSpellInfo and C_Spell.GetSpellInfo(id)
  if type(info) == "table" then
    dumpTable(info, 1, "  ")
  else
    out("  no spell info")
  end
  if C_Spell and C_Spell.RequestLoadSpellData then
    pcall(C_Spell.RequestLoadSpellData, id)
  end
  if C_Spell and C_Spell.GetSpellDescription then
    local desc = C_Spell.GetSpellDescription(id)
    out("  desc=%s", tostring(desc or "<not cached yet — rerun /briny spell " .. id .. ">"))
  end
  local aura = C_UnitAuras and C_UnitAuras.GetPlayerAuraBySpellID and C_UnitAuras.GetPlayerAuraBySpellID(id)
  if aura then
    out("  player aura present:")
    dumpTable(aura, 1, "    ")
  else
    out("  no player aura with this spellID")
  end
end

local function probeItem(arg)
  if not arg or arg == "" then
    out("usage: /briny item <itemID or shift-clicked item link>")
    return
  end
  out("== ITEM PROBE: %s ==", (arg:gsub("|", "||")))
  local name, link, quality, ilvl, _, itemType, itemSubType, _, _, _, _, classID, subclassID = C_Item.GetItemInfo(arg)
  if name then
    out("  name=%s quality=%s ilvl=%s type=%s/%s classID=%s/%s",
      tostring(name), tostring(quality), tostring(ilvl), tostring(itemType),
      tostring(itemSubType), tostring(classID), tostring(subclassID))
    out("  link=%s", tostring(link):gsub("|", "||"))
  else
    out("  GetItemInfo returned nil (item not cached yet — try the command again)")
  end
  local idNum = tonumber(arg)
  local data
  if idNum then
    data = C_TooltipInfo and C_TooltipInfo.GetItemByID and C_TooltipInfo.GetItemByID(idNum)
  else
    data = C_TooltipInfo and C_TooltipInfo.GetHyperlink and C_TooltipInfo.GetHyperlink(arg)
  end
  if data and data.lines then
    for i, line in ipairs(data.lines) do
      out("  tooltip[%d]: %s | %s", i, tostring(safeget(line, "leftText")), tostring(safeget(line, "rightText")))
    end
  else
    out("  no tooltip data")
  end
end

local function probeZone()
  out("== ZONE ==")
  out("  GetZoneText=%s GetSubZoneText=%s", tostring(GetZoneText()), tostring(GetSubZoneText()))
  local mapID = C_Map.GetBestMapForUnit("player")
  out("  best mapID=%s", tostring(mapID))
  if mapID then
    local info = C_Map.GetMapInfo(mapID)
    while info do
      out("    mapID=%s name=%s mapType=%s", tostring(info.mapID), tostring(info.name), tostring(info.mapType))
      info = info.parentMapID and info.parentMapID > 0 and C_Map.GetMapInfo(info.parentMapID) or nil
    end
  end
end

local function dumpGlobal(name, depth)
  depth = depth or 2
  local v = _G
  for part in name:gmatch("[^%.]+") do
    if type(v) ~= "table" then v = nil break end
    v = safeget(v, part)
  end
  out("== DUMP %s [%s] depth=%d ==", name, type(v), depth)
  if type(v) == "table" then
    dumpTable(v, depth, "  ")
  else
    out("  " .. shortval(v))
  end
end

-- ---------------------------------------------------------------- addon discovery

local CANDIDATE_ADDONS = {
  "Blizzard_FishingJournal", "Blizzard_FishingJournalUI", "Blizzard_Fishing",
  "Blizzard_FishingBook", "Blizzard_AnglinJournal", "Blizzard_Anglin",
  "Blizzard_ProfessionsBook", "Blizzard_Professions", "Blizzard_GatheringJournal",
}

local function probeAddons(pattern)
  local pats = (pattern and pattern ~= "") and { pattern:lower() } or { "fish", "angl", "journal", "profession" }
  out("== ADDON LIST matching %s ==", table.concat(pats, "/"))
  local n = C_AddOns.GetNumAddOns()
  local found = 0
  for i = 1, n do
    local ok, name, title, _, loadable, reason = pcall(C_AddOns.GetAddOnInfo, i)
    if ok and name then
      local hay = (tostring(name) .. " " .. tostring(title)):lower()
      for _, p in ipairs(pats) do
        if hay:find(p, 1, true) then
          found = found + 1
          out("  %s | loaded=%s loadable=%s reason=%s | %s", tostring(name),
            tostring(C_AddOns.IsAddOnLoaded(name)), tostring(loadable), tostring(reason), tostring(title))
          break
        end
      end
    end
  end
  out("(%d of %d listed addons matched)", found, n)
  out("candidate Blizzard load-on-demand addons:")
  for _, name in ipairs(CANDIDATE_ADDONS) do
    local exists = C_AddOns.DoesAddOnExist and C_AddOns.DoesAddOnExist(name)
    out("  %s: exists=%s loaded=%s", name, tostring(exists), tostring(C_AddOns.IsAddOnLoaded(name)))
  end
end

-- ---------------------------------------------------------------- achievement/statistic scans

local ACH_PATTERNS = { "fish", "angl", "briny", "lure", "pool ", "whopper" }

local function achScan(from, to)
  from, to = from or 63000, to or 64200
  out("== ACHIEVEMENT ID SCAN %d..%d (fishing-related names/descs) ==", from, to)
  local found = 0
  for id = from, to do
    local ok, aid, name, _, completed, _, _, _, desc = pcall(GetAchievementInfo, id)
    if ok and aid and name then
      local hay = (name .. " " .. tostring(desc or "")):lower()
      for _, p in ipairs(ACH_PATTERNS) do
        if hay:find(p, 1, true) then
          found = found + 1
          out("  %d: %s | done=%s | %s", aid, name, tostring(completed), tostring(desc))
          local num = GetAchievementNumCriteria(aid) or 0
          for i = 1, math.min(num, 40) do
            local ok2, cs, ctype, ccomp, qty, req, _, _, assetID, _, critID = pcall(GetAchievementCriteriaInfo, aid, i)
            if ok2 and (cs or critID) then
              out("      [%d] %s type=%s asset=%s qty=%s/%s done=%s critID=%s",
                i, tostring(cs), tostring(ctype), tostring(assetID), tostring(qty),
                tostring(req), tostring(ccomp), tostring(critID))
            end
          end
          break
        end
      end
    end
  end
  out("(%d achievements matched)", found)
end

local function dumpAchievementBrief(id)
  local num = GetAchievementNumCriteria(id) or 0
  for c = 1, math.min(num, 40) do
    local ok2, cs, ctype, ccomp, qty, req, _, _, assetID, _, critID = pcall(GetAchievementCriteriaInfo, id, c)
    if ok2 and (cs or critID) then
      out("      [%d] %s type=%s asset=%s qty=%s/%s done=%s critID=%s",
        c, tostring(cs), tostring(ctype), tostring(assetID), tostring(qty),
        tostring(req), tostring(ccomp), tostring(critID))
    end
  end
end

local function probeAchCategories()
  out("== ACHIEVEMENT CATEGORY TREE (fishing/anglin categories) ==")
  local cats = GetCategoryList() or {}
  local shown = 0
  for _, catID in ipairs(cats) do
    local name, parentID = GetCategoryInfo(catID)
    local parentName = (parentID and parentID > 0) and (GetCategoryInfo(parentID)) or ""
    local hay = (tostring(name) .. " " .. tostring(parentName)):lower()
    if hay:find("fish", 1, true) or hay:find("angl", 1, true) then
      shown = shown + 1
      local total = GetCategoryNumAchievements(catID, true)
      out("category %d: %s (parent=%s) achievements=%s", catID, tostring(name), tostring(parentName), tostring(total))
      for i = 1, tonumber(total) or 0 do
        local ok, id, aname, _, comp, _, _, _, desc = pcall(GetAchievementInfo, catID, i)
        if ok and id then
          out("  %d: %s | done=%s | %s", id, tostring(aname), tostring(comp), tostring(desc))
          dumpAchievementBrief(id)
        end
      end
    end
  end
  out("(%d categories matched)", shown)
end

local function probeStats()
  out("== STATISTICS SCAN (fish/angl) ==")
  local cats = GetStatisticsCategoryList() or {}
  local found = 0
  for _, catID in ipairs(cats) do
    local catName = GetCategoryInfo(catID)
    local catMatch = tostring(catName):lower():find("fish", 1, true)
      or tostring(catName):lower():find("angl", 1, true)
    local num = GetCategoryNumAchievements(catID) or 0
    for i = 1, num do
      local ok, id, name = pcall(GetAchievementInfo, catID, i)
      if ok and id and name then
        local l = name:lower()
        if catMatch or l:find("fish", 1, true) or l:find("angl", 1, true) then
          found = found + 1
          out("  [%s] statID=%d %s = %s", tostring(catName), id, name, tostring(GetStatistic(id)))
        end
      end
    end
  end
  out("(%d statistics matched)", found)
end

-- ---------------------------------------------------------------- frames / professions / spell scans

-- 12.1 "secret" strings throw on any string op; forcing a concat inside pcall filters them out
local function frameNameSafe(f)
  local ok, n = pcall(function()
    local name = f:GetDebugName()
    if issecretvalue and issecretvalue(name) then return nil end
    if type(name) ~= "string" then return nil end
    return name .. ""
  end)
  if ok then return n end
end

local function probeFrames(pattern)
  out("== FRAME SCAN: '%s' ==", pattern)
  local pat = pattern:lower()
  local f = EnumerateFrames()
  local found = 0
  while f do
    local name = frameNameSafe(f)
    if name and name:lower():find(pat, 1, true) then
      found = found + 1
      if found <= 200 then
        local ok2, objType, shown = pcall(function() return f:GetObjectType(), f:IsShown() end)
        out("  %s [%s] shown=%s", name, ok2 and tostring(objType) or "?", ok2 and tostring(shown) or "?")
      end
    end
    f = EnumerateFrames(f)
  end
  out("(%d frames matched%s)", found, found > 200 and ", first 200 shown" or "")
end

local function probeMouse()
  out("== MOUSE FOCUS PROBE ==")
  local foci
  if GetMouseFoci then
    foci = GetMouseFoci()
  elseif GetMouseFocus then
    foci = { GetMouseFocus() }
  end
  if not foci or #foci == 0 then
    out("  nothing under the mouse")
    return
  end
  for i, f in ipairs(foci) do
    out("focus[%d]: %s", i, tostring(frameNameSafe(f)))
    local okED, ed = pcall(function() return f:GetElementData() end)
    if okED and type(ed) == "table" then
      out("  elementData:")
      dumpTable(ed, 3, "    ")
    end
    out("  keys:")
    pcall(dumpTable, f, 2, "    ")
    -- walk up the parent chain for context
    local p = f
    for depth = 1, 4 do
      local okP, parent = pcall(function() return p:GetParent() end)
      if not okP or not parent then break end
      out("  parent^%d: %s", depth, tostring(frameNameSafe(parent)))
      p = parent
    end
  end
end

local function probeProfessions()
  out("== PROFESSIONS / SPELLBOOK ==")
  local profs = { GetProfessions() }
  for slot = 1, 6 do
    local idx = profs[slot]
    if idx then
      local ok, name, _, skillLevel, maxSkill, numAbilities, spellOffset, skillLine =
        pcall(GetProfessionInfo, idx)
      if ok and name then
        out("  prof[%d] %s skill=%s/%s abilities=%s offset=%s skillLine=%s",
          slot, tostring(name), tostring(skillLevel), tostring(maxSkill),
          tostring(numAbilities), tostring(spellOffset), tostring(skillLine))
        local isFishing = tostring(name):lower():find("fish", 1, true)
        for i = 1, tonumber(numAbilities) or 0 do
          local bookSlot = (tonumber(spellOffset) or 0) + i
          local nameA, nameB, spellID
          if C_SpellBook and C_SpellBook.GetSpellBookItemName then
            local okA, n = pcall(C_SpellBook.GetSpellBookItemName, bookSlot, Enum.SpellBookSpellBank.Player)
            if okA then nameA = n end
          end
          if GetSpellBookItemName then
            local okB, n = pcall(GetSpellBookItemName, bookSlot, "professions")
            if okB then nameB = n end
          end
          if C_SpellBook and C_SpellBook.GetSpellBookItemInfo then
            local okC, si = pcall(C_SpellBook.GetSpellBookItemInfo, bookSlot, Enum.SpellBookSpellBank.Player)
            if okC and type(si) == "table" then spellID = si.spellID end
          end
          if isFishing or nameA or nameB then
            out("      slot %d: player-bank=%s prof-book=%s spellID=%s",
              bookSlot, tostring(nameA), tostring(nameB), tostring(spellID))
          end
        end
      end
    end
  end
end

local function spellScan(from, to)
  if not (from and to) or to < from then
    chat("usage: /briny spellscan <fromID> <toID>")
    return
  end
  if to - from > 3000 then to = from + 3000 end
  out("== SPELL ID SCAN %d..%d ==", from, to)
  local found = 0
  for id = from, to do
    local info = C_Spell.GetSpellInfo(id)
    if info and info.name then
      found = found + 1
      out("  %d: %s", id, info.name)
    end
  end
  out("(%d spells found)", found)
end

-- ---------------------------------------------------------------- tradeskill (fishing journal) probe

local FISH_RECIPE_TEST = 1295409 -- Dirty Darter

local function probeTradeSkill()
  out("== C_TradeSkillUI PROBE (works best with the Midnight Fishing journal OPEN) ==")
  if C_TradeSkillUI.GetChildProfessionInfo then
    local ok, prof = pcall(C_TradeSkillUI.GetChildProfessionInfo)
    if ok and type(prof) == "table" then
      out("child profession info:")
      dumpTable(prof, 1, "  ")
    end
  end
  if C_TradeSkillUI.GetBaseProfessionInfo then
    local ok, base = pcall(C_TradeSkillUI.GetBaseProfessionInfo)
    if ok and type(base) == "table" then
      out("base profession info:")
      dumpTable(base, 1, "  ")
    end
  end

  local catNames = {}
  local function catName(id)
    if not id then return "?" end
    if catNames[id] == nil then
      local ok, ci = pcall(C_TradeSkillUI.GetCategoryInfo, id)
      if ok and type(ci) == "table" then
        catNames[id] = ("%s <%d parent=%s>"):format(tostring(ci.name), id, tostring(ci.parentCategoryID))
      else
        catNames[id] = "cat" .. id
      end
    end
    return catNames[id]
  end

  local okIDs, recipeIDs = pcall(C_TradeSkillUI.GetAllRecipeIDs)
  recipeIDs = (okIDs and recipeIDs) or {}
  out("recipes: %d", #recipeIDs)
  for _, rid in ipairs(recipeIDs) do
    local ok, ri = pcall(C_TradeSkillUI.GetRecipeInfo, rid)
    if ok and type(ri) == "table" then
      out("  %d: %s | cat=%s | learned=%s dummy=%s icon=%s",
        rid, tostring(ri.name), catName(ri.categoryID), tostring(ri.learned),
        tostring(ri.isDummyRecipe), tostring(ri.icon))
    else
      out("  %d: <no recipe info>", rid)
    end
  end

  if C_TradeSkillUI.GetRecipeDescription then
    local ok, desc = pcall(C_TradeSkillUI.GetRecipeDescription, FISH_RECIPE_TEST, {})
    out("GetRecipeDescription(%d) ok=%s:", FISH_RECIPE_TEST, tostring(ok))
    out("  %s", tostring(desc))
  end
  if C_TradeSkillUI.GetRecipeSchematic then
    local ok, schem = pcall(C_TradeSkillUI.GetRecipeSchematic, FISH_RECIPE_TEST, false)
    if ok and type(schem) == "table" then
      out("GetRecipeSchematic(%d):", FISH_RECIPE_TEST)
      dumpTable(schem, 2, "  ")
    end
  end
end

-- ---------------------------------------------------------------- score reading / watching

local SCORE_SPELL = 1303630 -- The Briny Best of 'Em: desc contains "Midnight Anglin' Score: N.N points."

local function getScores()
  local ok, _, _, _, qty = pcall(GetAchievementCriteriaInfo, ACHIEVEMENT_ID, 1)
  local critQty = ok and qty or nil
  pcall(C_Spell.RequestLoadSpellData, SCORE_SPELL)
  local desc = C_Spell.GetSpellDescription(SCORE_SPELL)
  local precise = desc and desc:match("([%d%.,]+)%s*points")
  return critQty, precise
end

local function probeScore()
  local critQty, precise = getScores()
  out("== SCORE == criteria=%s/2500  spellDesc=%s points  @ %.2f", tostring(critQty), tostring(precise), GetTime())
  chat(("Anglin' Score: %s (criteria %s/2500)"):format(tostring(precise), tostring(critQty)))
end

local watcher = CreateFrame("Frame")
local watchLastLoot, watchLastScore, watchPending
watcher:SetScript("OnEvent", function(_, event, msg)
  if event == "CHAT_MSG_LOOT" then
    if msg and msg:find("You receive") then watchLastLoot = msg end
  elseif event == "CRITERIA_UPDATE" then
    if watchPending then return end
    watchPending = true
    C_Timer.After(0.6, function()
      watchPending = false
      local critQty, precise = getScores()
      local key = tostring(critQty) .. "|" .. tostring(precise)
      if key ~= watchLastScore then
        local prev = watchLastScore
        watchLastScore = key
        local loot = tostring(watchLastLoot)
        out("%9.2f SCORE %s -> crit=%s precise=%s | last loot: %s",
          GetTime(), tostring(prev), tostring(critQty), tostring(precise), (loot:gsub("|", "||")))
        chat(("score -> %s (was %s) after %s"):format(tostring(precise), tostring(prev), loot))
      end
    end)
  end
end)

local function watchCmd(arg)
  if arg == "on" then
    local critQty, precise = getScores()
    watchLastScore = tostring(critQty) .. "|" .. tostring(precise)
    watchLastLoot = nil
    watcher:RegisterEvent("CRITERIA_UPDATE")
    watcher:RegisterEvent("CHAT_MSG_LOOT")
    out("== SCORE WATCH ON == baseline crit=%s precise=%s", tostring(critQty), tostring(precise))
    chat("score watch ON — fish away, deltas print live. /briny watch off to stop")
  elseif arg == "off" then
    watcher:UnregisterAllEvents()
    chat("score watch OFF")
    refreshWindow()
  else
    chat("usage: /briny watch on | off")
  end
end

-- ---------------------------------------------------------------- event logger

local logger = CreateFrame("Frame")
local counts, mode = {}, nil
local INTERESTING = { "FISH", "ANGL", "LOOT", "CURRENCY", "ACHIEVEMENT", "CRITERIA",
  "JOURNAL", "ITEM_PUSH", "BRINY", "PROFESSION", "TRADE_SKILL", "SCORE" }
local NOISY = {
  COMBAT_LOG_EVENT_UNFILTERED = true, UNIT_AURA = true, UNIT_POWER_UPDATE = true,
  UNIT_POWER_FREQUENT = true, UNIT_HEALTH = true, UNIT_TARGET = true,
  SPELL_UPDATE_COOLDOWN = true, SPELL_UPDATE_USABLE = true, SPELL_UPDATE_CHARGES = true,
  ACTIONBAR_UPDATE_COOLDOWN = true, CURSOR_CHANGED = true, UPDATE_UI_WIDGET = true,
  PLAYER_STARTED_MOVING = true, PLAYER_STOPPED_MOVING = true, UNIT_SPELLCAST_SENT = false,
}

logger:SetScript("OnEvent", function(_, event, ...)
  counts[event] = (counts[event] or 0) + 1
  local interesting = false
  for _, p in ipairs(INTERESTING) do
    if event:find(p, 1, true) then interesting = true break end
  end
  -- "all" mode: also log the first 5 occurrences of every non-noisy event
  if interesting or (mode == "all" and not NOISY[event] and counts[event] <= 5) then
    local n = select("#", ...)
    local args = {}
    for i = 1, math.min(n, 12) do
      args[i] = shortval((select(i, ...)))
    end
    out("%9.2f  %s(%s)", GetTime(), event, table.concat(args, ", "))
  end
end)

local function eventsCmd(arg)
  if arg == "on" or arg == "all" then
    wipe(counts)
    mode = arg
    logger:RegisterAllEvents()
    out("== EVENT LOG START (%s mode) @ %.2f ==", arg, GetTime())
    chat("event logging ON (" .. arg .. " mode) — go fish a few casts (open water AND a pool), then /briny events off")
  elseif arg == "off" then
    logger:UnregisterAllEvents()
    mode = nil
    out("== EVENT LOG END — event counts ==")
    local arr = {}
    for e, c in pairs(counts) do arr[#arr + 1] = { e, c } end
    table.sort(arr, function(a, b) return a[2] > b[2] end)
    for _, ec in ipairs(arr) do out("  %5d  %s", ec[2], ec[1]) end
    refreshWindow()
    chat("event logging OFF — results in window")
  else
    chat("usage: /briny events on | all | off")
  end
end

-- ---------------------------------------------------------------- run battery

local function runAll()
  local v, build, bdate, toc = GetBuildInfo()
  out("==================================================================")
  out("BrinyProbe v%s | WoW %s (build %s, %s) toc=%s | %s", VERSION, v, build, bdate, toc, date())
  out("==================================================================")
  probeZone()
  probeGlobals(CORE_PATTERNS, true)
  probeDocs("fish")
  probeDocs("angl")
  probeEnums("fish")
  probeEnums("angl")
  probeEnums("briny")
  probeAchievement(ACHIEVEMENT_ID)
  probeCurrencies()
  for _, id in ipairs(DEFAULT_SPELLS) do probeSpell(id) end
  out("== DONE — copy everything above ==")
  refreshWindow()
  chat("probe battery complete — window opened, Select All + Cmd/Ctrl+C")
end

-- ---------------------------------------------------------------- slash commands

local HELP = [[
/briny run           - full probe battery (start here)
/briny show          - open/refresh output window
/briny clear         - clear log
/briny events on     - log fishing-relevant events (then go fish!)
/briny events all    - log (almost) all events, first 5 of each
/briny events off    - stop logging, print summary
/briny find <text>   - search _G + API docs + Enums for <text>
/briny dumpg <name> [depth] - dump a global, e.g. /briny dumpg C_FishingJournal 2
/briny strings <text>- find globals whose string VALUE contains <text> (e.g. anglin)
/briny score         - read current Anglin' Score (criteria + precise spell-desc value)
/briny watch on|off  - live-log score deltas per catch (the key experiment!)
/briny tradeskill    - dump ALL fishing journal recipes/categories via C_TradeSkillUI
/briny mouseover     - dump the UI element under the mouse (hover a fish, press Enter)
/briny achcat        - walk achievement category tree for fishing categories
/briny frames <pat>  - scan ALL live frames by name (run with journal OPEN)
/briny prof          - professions + fishing spellbook entries
/briny spellscan <from> <to> - scan spell IDs for names (fish entries may be spells)
/briny addons [pat]  - list addons incl. Blizzard load-on-demand candidates
/briny load <name>   - force-load a Blizzard addon, e.g. /briny load Blizzard_FishingJournal
/briny achscan [from] [to] - scan achievement IDs for fishing ones (default 63000-64200)
/briny stats         - scan statistics categories for fishing stats
/briny ach [id]      - achievement criteria dump (default 63510)
/briny cur           - currency scan
/briny spell <id>    - spell + player-aura probe
/briny item <id|link>- item + tooltip probe (shift-click a caught fish into the command)
/briny zone          - current zone/map IDs
]]

SLASH_BRINYPROBE1 = "/briny"
SLASH_BRINYPROBE2 = "/brinyprobe"
SlashCmdList.BRINYPROBE = function(msg)
  msg = msg or ""
  local cmd, rest = msg:match("^(%S*)%s*(.-)$")
  cmd = cmd:lower()

  if cmd == "" or cmd == "help" then
    chat("commands:")
    print(HELP)
  elseif cmd == "run" then
    runAll()
  elseif cmd == "show" then
    refreshWindow()
  elseif cmd == "clear" then
    wipe(lines)
    if win then win.editBox:SetText("") end
    chat("log cleared")
  elseif cmd == "events" then
    eventsCmd(rest:lower())
  elseif cmd == "find" then
    if rest == "" then chat("usage: /briny find <text>") return end
    probeGlobals({ rest:lower() }, true)
    probeDocs(rest)
    probeEnums(rest)
    refreshWindow()
  elseif cmd == "dumpg" then
    local name, depth = rest:match("^(%S+)%s*(%d*)$")
    if not name then chat("usage: /briny dumpg <globalName> [depth]") return end
    dumpGlobal(name, tonumber(depth) or 2)
    refreshWindow()
  elseif cmd == "strings" then
    if rest == "" then chat("usage: /briny strings <text>, e.g. /briny strings anglin") return end
    probeStringValues(rest)
    refreshWindow()
  elseif cmd == "score" then
    probeScore()
    refreshWindow()
  elseif cmd == "watch" then
    watchCmd(rest:lower())
  elseif cmd == "tradeskill" or cmd == "ts" then
    probeTradeSkill()
    refreshWindow()
  elseif cmd == "mouseover" or cmd == "mo" then
    probeMouse()
    refreshWindow()
  elseif cmd == "achcat" then
    probeAchCategories()
    refreshWindow()
  elseif cmd == "frames" then
    if rest == "" then chat("usage: /briny frames <pattern>") return end
    probeFrames(rest)
    refreshWindow()
  elseif cmd == "prof" then
    probeProfessions()
    refreshWindow()
  elseif cmd == "spellscan" then
    local from, to = rest:match("^(%d+)%s+(%d+)$")
    spellScan(tonumber(from), tonumber(to))
    refreshWindow()
  elseif cmd == "addons" then
    probeAddons(rest)
    refreshWindow()
  elseif cmd == "load" then
    if rest == "" then chat("usage: /briny load <addonName>") return end
    local ok, loadedOrErr = pcall(C_AddOns.LoadAddOn, rest)
    out("== LOAD ADDON %s: ok=%s result=%s ==", rest, tostring(ok), tostring(loadedOrErr))
    chat("load attempt done — now run /briny find fishing to see what appeared")
    refreshWindow()
  elseif cmd == "achscan" then
    local from, to = rest:match("^(%d*)%s*(%d*)$")
    achScan(tonumber(from), tonumber(to))
    refreshWindow()
  elseif cmd == "stats" then
    probeStats()
    refreshWindow()
  elseif cmd == "ach" then
    probeAchievement(tonumber(rest))
    refreshWindow()
  elseif cmd == "cur" then
    probeCurrencies()
    refreshWindow()
  elseif cmd == "spell" then
    local id = tonumber(rest)
    if not id then chat("usage: /briny spell <spellID>") return end
    probeSpell(id)
    refreshWindow()
  elseif cmd == "item" then
    probeItem(rest)
    refreshWindow()
  elseif cmd == "zone" then
    probeZone()
    refreshWindow()
  else
    chat("unknown command '" .. cmd .. "' — /briny help")
  end
end

-- ---------------------------------------------------------------- init / persistence

BP:RegisterEvent("ADDON_LOADED")
BP:RegisterEvent("PLAYER_LOGOUT")
BP:SetScript("OnEvent", function(_, event, arg1)
  if event == "ADDON_LOADED" and arg1 == ADDON_NAME then
    BrinyProbeDB = BrinyProbeDB or {}
    chat("v" .. VERSION .. " loaded — /briny run to start, /briny help for commands")
  elseif event == "PLAYER_LOGOUT" then
    -- log also lands in WTF/.../SavedVariables/BrinyProbe.lua as a copyable fallback
    BrinyProbeDB.log = lines
    BrinyProbeDB.savedAt = date()
  end
end)
