-- BrinyBestTest: dev-only simulation commands. Lives in tools/ so the packager
-- never ships it — install by copying this folder into Interface/AddOns.
--
-- /bbtest improve [name]  - rewind a fish's stored score/rank so the next update
--                           fires a real improvement notification
-- /bbtest trophy [name]   - rewind a Trophy fish's stored rank to re-fire the real
--                           celebration path (falls back to any Trophy fish you have)
-- /bbtest fake            - fire the celebration toast directly with fake data
--                           (works anywhere, no fish data needed)

local function chat(msg)
  print("|cffff9933BrinyBestTest:|r " .. msg)
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

  else
    chat("commands: /bbtest improve [name] | /bbtest trophy [name] | /bbtest fake")
  end
end

chat("loaded — /bbtest fake for a quick celebration preview")
