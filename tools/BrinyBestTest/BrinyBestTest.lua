-- BrinyBestTest: dev-only simulation commands. Lives in tools/ so the packager
-- never ships it — install by copying this folder into Interface/AddOns.
--
-- /bbtest improve [name]  - rewind a fish's stored score/rank so the next update
--                           fires a real improvement notification
-- /bbtest trophy [name]   - rewind a Trophy fish's stored rank to re-fire the real
--                           celebration path (falls back to any Trophy fish you have)
-- /bbtest fake            - fire the celebration toast directly with fake data
--                           (works anywhere, no fish data needed)
-- /bbtest list [copy]     - dump all scoreable fish grouped by zone (oddities noted
--                           separately); "copy" opens a copyable markdown window

local function chat(msg)
  print("|cffff9933BrinyBestTest:|r " .. msg)
end

local function buildRoster()
  local zones, zoneNames, oddities = {}, {}, {}
  local scoreable, uncached = 0, 0
  for _, fdef in ipairs(BrinyBest.fish) do
    local info = BrinyBest.ParseFish(fdef)
    if not info then
      uncached = uncached + 1
    elseif not info.scoreable then
      oddities[#oddities + 1] = info.name
    else
      scoreable = scoreable + 1
      for _, area in ipairs(info.areas) do
        if not zones[area] then
          zones[area] = {}
          zoneNames[#zoneNames + 1] = area
        end
        zones[area][#zones[area] + 1] = info.name
      end
    end
  end
  table.sort(zoneNames)
  for _, z in ipairs(zoneNames) do table.sort(zones[z]) end
  table.sort(oddities)
  return zones, zoneNames, oddities, scoreable, uncached
end

local copyFrame
local function showCopy(text)
  if not copyFrame then
    copyFrame = CreateFrame("Frame", "BrinyBestTestCopyFrame", UIParent, "BasicFrameTemplateWithInset")
    copyFrame:SetSize(560, 420)
    copyFrame:SetPoint("CENTER")
    copyFrame:SetMovable(true)
    copyFrame:EnableMouse(true)
    copyFrame:RegisterForDrag("LeftButton")
    copyFrame:SetScript("OnDragStart", copyFrame.StartMoving)
    copyFrame:SetScript("OnDragStop", copyFrame.StopMovingOrSizing)
    local title = copyFrame.TitleText or (copyFrame.TitleContainer and copyFrame.TitleContainer.TitleText)
    if title then title:SetText("BrinyBest fish roster") end
    local scroll = CreateFrame("ScrollFrame", nil, copyFrame, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 12, -32)
    scroll:SetPoint("BOTTOMRIGHT", -32, 12)
    local eb = CreateFrame("EditBox", nil, scroll)
    eb:SetMultiLine(true)
    eb:SetFontObject(ChatFontNormal)
    eb:SetWidth(490)
    eb:SetAutoFocus(false)
    eb:SetScript("OnEscapePressed", function() copyFrame:Hide() end)
    scroll:SetScrollChild(eb)
    copyFrame.editBox = eb
  end
  copyFrame.editBox:SetText(text)
  copyFrame:Show()
  copyFrame.editBox:HighlightText()
  copyFrame.editBox:SetFocus()
end

local function findFish(nameFilter, predicate)
  local fallback
  for _, fdef in ipairs(BrinyBest.fish) do
    local info = BrinyBest.ParseFish(fdef)
    if info and (not predicate or predicate(info)) then
      if nameFilter and nameFilter ~= "" then
        if info.name:lower():find(nameFilter:lower(), 1, true) then return info end
      else
        fallback = fallback or info
      end
    end
  end
  return fallback
end

SLASH_BRINYBESTTEST1 = "/bbtest"
SlashCmdList.BRINYBESTTEST = function(msg)
  local cmd, rest = (msg or ""):match("^%s*(%S*)%s*(.-)%s*$")
  cmd = cmd:lower()

  if cmd == "improve" then
    local info = findFish(rest, function(i) return i.score > 1 end)
    if not info then chat("no fish with score > 0 found (try in a Midnight zone)") return end
    BrinyBestDB.scores = BrinyBestDB.scores or {}
    BrinyBestDB.ranks = BrinyBestDB.ranks or {}
    BrinyBestDB.scores[info.id] = math.max(0, info.score - 25)
    BrinyBestDB.ranks[info.id] = math.max(0, info.rankNum - 1)
    chat(("rewound %s to %.1f (rank %d) — updating..."):format(info.name, BrinyBestDB.scores[info.id], BrinyBestDB.ranks[info.id]))
    BrinyBest.Update()

  elseif cmd == "trophy" then
    local info = findFish(rest, function(i) return i.rankNum >= 5 end)
    if not info then
      chat("no Trophy-rank fish found — use /bbtest fake for a synthetic celebration")
      return
    end
    BrinyBestDB.scores = BrinyBestDB.scores or {}
    BrinyBestDB.ranks = BrinyBestDB.ranks or {}
    BrinyBestDB.scores[info.id] = info.score - 10
    BrinyBestDB.ranks[info.id] = 4
    chat(("rewound %s to rank 4 — updating (real celebration path)..."):format(info.name))
    BrinyBest.Update()

  elseif cmd == "fake" then
    BrinyBest.Celebrate({
      id = 0,
      cat = 3,
      name = "Testfin the Magnificent",
      icon = 4554382,
      rank = "Trophy",
      rankNum = 5,
      score = 100,
    })

  elseif cmd == "list" then
    local zones, zoneNames, oddities, scoreable, uncached = buildRoster()
    if rest:lower() == "copy" then
      local out = {
        ("**All %d scoreable fish by zone** (%d x 100 pts = %d max; fish in multiple zones listed in each)"):format(scoreable, scoreable, scoreable * 100),
        "",
      }
      for _, z in ipairs(zoneNames) do
        out[#out + 1] = ("- **%s** (%d): %s"):format(z, #zones[z], table.concat(zones[z], ", "))
      end
      if #oddities > 0 then
        out[#out + 1] = ""
        out[#out + 1] = ("*Cursed Oddities — no Anglin' Score, don't count toward the achievement (%d):* %s"):format(#oddities, table.concat(oddities, ", "))
      end
      if uncached > 0 then
        out[#out + 1] = ""
        out[#out + 1] = ("(%d fish not yet cached by the client — run again in a moment)"):format(uncached)
      end
      showCopy(table.concat(out, "\n"))
    else
      chat(("%d scoreable fish (%d max), %d oddities%s"):format(scoreable, scoreable * 100, #oddities,
        uncached > 0 and (", %d uncached — run again"):format(uncached) or ""))
      for _, z in ipairs(zoneNames) do
        print(("|cffffd100%s|r (%d): %s"):format(z, #zones[z], table.concat(zones[z], ", ")))
      end
      if #oddities > 0 then
        print(("|cff9d9d9dOddities (unscored)|r (%d): %s"):format(#oddities, table.concat(oddities, ", ")))
      end
    end

  else
    chat("commands: /bbtest improve [name] | /bbtest trophy [name] | /bbtest fake | /bbtest list [copy]")
  end
end

chat("loaded — /bbtest fake for a quick celebration preview")
