-- BrinyBest: shows Midnight Anglin' fish scores and catch ranks for your current zone.
-- Data source: each journal fish is a dummy tradeskill recipe whose spell description
-- carries "Anglin' Score: N.N points", "Catch Rank: <rank>", areas, pools, and rates.
-- /bbf toggles the panel; /bbf help for options.

-- Addon table shared with the Locales\<code>.lua files, which the client loads before
-- this one (see BrinyBest.toc for the order). They fill ns.Locale; the localization
-- section below reads it back out.
local addonName, ns = ...

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
local RANK_ORDER = { "Guppy", "Minnow", "Pike", "Shark", "Trophy" }
local RANK_HEX = { Guppy = "9d9d9d", Minnow = "1eff00", Pike = "0070dd", Shark = "a335ee", Trophy = "ff8000" }

-- Rank score cutoffs, mapped from live warband data (Aug 16 2026, 27-fish baseline,
-- perfectly monotonic across species so cutoffs are universal). Observed bounds:
-- Minnow ∈ (71.3, 75.4], Pike ∈ (75.4, 81.1], Shark ∈ (91.1, 96.1]; Trophy = 100.0
-- exactly. 75/80/95 are the only round numbers that fit; est marks them provisional
-- until gap catches confirm. Community-claimed 70/90 are refuted by the same data.
local RANK_CUTOFFS = {
  Minnow = { score = 75, est = true },
  Pike = { score = 80, est = true },
  Shark = { score = 95, est = true },
  Trophy = { score = 100 },
}

-- ---------------------------------------------------------------- localization
-- The addon works by parsing Blizzard's localized journal descriptions, so each
-- locale needs the exact label/header strings Blizzard uses there (plain strings,
-- matched literally — no Lua patterns, so translations can't break matching).
-- rankWords maps localized rank names to canonical keys; when a locale lacks them
-- (or Blizzard renames), rank falls back to RANK_CUTOFFS applied to the score.
-- openWaterWord/poolWord/onlyWord (lowercase) drive the (open)/(pool) tags and are
-- optional — without them the tags simply don't show.
-- Labels/headers are colon-free prefixes (French uses spaced colons, Korean none,
-- Chinese fullwidth ones). Header fields may be a string or a list of alternatives
-- (Blizzard is inconsistent within a locale: itIT "Probabilità"/"Frequenza", zhCN
-- "特殊"/"特殊效果"). Strings scraped from Wowhead's localized spell pages
-- (1295406/1295409), which mirror the in-game 12.1 text. Only the Guppy rank word
-- is visible there; other ranks resolve via the RANK_CUTOFFS score fallback.
--
-- The data itself lives in Locales/<code>.lua, one file per client language, all of
-- them loaded before this file (see BrinyBest.toc). Each one fills ns.Locale[<code>]
-- with a Parse table (the markers described above) and a Strings table (the addon's
-- own UI text, gathered further down in the UI-strings section).
local LOCALE_PARSE, L_ALL = {}, {}
for code, data in pairs(ns.Locale or {}) do
  LOCALE_PARSE[code] = data.Parse
  L_ALL[code] = data.Strings
end

-- English (UK) clients read the same journal text as enUS — all 34 descriptions come back
-- byte-identical — so they share its tables rather than counting as an untranslated client,
-- which would put the "help translate this language" note in their chat. A locale file
-- still wins if enGB ever gets text of its own.
if not LOCALE_PARSE.enGB then
  LOCALE_PARSE.enGB, L_ALL.enGB = LOCALE_PARSE.enUS, L_ALL.enUS
end

local PARSE = LOCALE_PARSE[GetLocale()]
local untranslatedLocale = not PARSE and GetLocale() or nil
PARSE = PARSE or LOCALE_PARSE.enUS

-- leading grammatical articles vary per fish in Blizzard's localized area lists
-- (frFR: "l’île Annelée" on some fish, "île Annelée" on others), so they must not
-- take part in zone identity. Lowercase, checked against case-folded strings.
LOCALE_PARSE.deDE.articlePrefixes = { "der ", "die ", "das " }
LOCALE_PARSE.esES.articlePrefixes = { "el ", "la ", "los ", "las " }
LOCALE_PARSE.esMX.articlePrefixes = LOCALE_PARSE.esES.articlePrefixes
LOCALE_PARSE.frFR.articlePrefixes = { "l’", "l'", "le ", "la ", "les " }
LOCALE_PARSE.itIT.articlePrefixes = { "l’", "l'", "il ", "lo ", "la ", "i ", "gli ", "le " }
LOCALE_PARSE.ptBR.articlePrefixes = { "o ", "a ", "os ", "as " }

-- localized numbers may use comma decimals ("96,6"); scores never carry thousands
local function parseNumber(s)
  if not s then return nil end
  -- some locales end the line right after the number ("Score de pêche : 100.0.")
  -- and the greedy capture keeps that final period; strip trailing separators
  s = s:gsub(",", "."):gsub("[%.]+$", "")
  return tonumber(s)
end

-- case-fold beyond ASCII: Latin-1 accented capitals (frFR "Île"/"île") and Cyrillic
-- (ruRU), which Lua's lower() leaves untouched
local function foldCase(s)
  s = s:lower()
  s = s:gsub("\195([\128-\158])", function(c)
    local b = c:byte()
    if b ~= 0x97 then return "\195" .. string.char(b + 32) end -- skip × at C397
  end)
  s = s:gsub("\208([\144-\175])", function(c)
    local b = c:byte()
    if b <= 0x9F then return "\208" .. string.char(b + 32) end
    return "\209" .. string.char(b - 32)
  end)
  return s
end

-- One zone, one identity: fold case and drop leading articles. Returns the grouping
-- key plus a display form (original case, article stripped). Used on BOTH the parsed
-- area strings and the player's live zone names so they can't drift apart.
local function normalizeArea(a)
  local folded = foldCase(a)
  for _, art in ipairs(PARSE.articlePrefixes or {}) do
    if folded:sub(1, #art) == art then
      return folded:sub(#art + 1), a:sub(#art + 1)
    end
  end
  return folded, a
end

local function startsWith(line, prefix)
  return prefix and line:sub(1, #prefix) == prefix
end

-- header fields may be one prefix or a list of alternatives
local function startsWithAny(line, prefixes)
  if type(prefixes) == "table" then
    for _, p in ipairs(prefixes) do
      if startsWith(line, p) then return true end
    end
    return false
  end
  return startsWith(line, prefixes)
end

-- labels too: Blizzard is inconsistent between fish within one locale
local function findLabel(desc, labels)
  if type(labels) == "table" then
    for _, l in ipairs(labels) do
      local s, e = desc:find(l, 1, true)
      if s then return s, e end
    end
    return nil
  end
  return desc:find(labels, 1, true)
end

-- strip whole punctuation SEQUENCES, never byte classes: multibyte chars like
-- Korean 고 (EA B3 A0) or Cyrillic р (D1 80) share bytes with NBSP/。 and a
-- byte-wise character class amputates them
local TRAIL_PUNCT = { " ", "\t", ".", ";", ",", "\194\160", "\227\128\130" }
local function stripTrailing(s)
  local changed = true
  while changed do
    changed = false
    for _, suf in ipairs(TRAIL_PUNCT) do
      if #s >= #suf and s:sub(-#suf) == suf then
        s = s:sub(1, -#suf - 1)
        changed = true
      end
    end
  end
  return s
end

local LEAD_BULLET = { "-", "\226\128\147", " ", "\t", "\194\160" }
local function stripLeadingBullet(s)
  local changed = true
  while changed do
    changed = false
    for _, p in ipairs(LEAD_BULLET) do
      if s:sub(1, #p) == p then
        s = s:sub(#p + 1)
        changed = true
      end
    end
  end
  return s
end

-- list items start with "-" (most locales) or "–" (frFR); values may carry trailing
-- "." / NBSP+";" (frFR) or "。" (zhCN)
local function bulletValue(line)
  if line:sub(1, 1) ~= "-" and line:sub(1, 3) ~= "\226\128\147" then return nil end
  local v = stripTrailing(stripLeadingBullet(line))
  return v ~= "" and v or nil
end

local function rankFromScore(score)
  local best
  for _, rname in ipairs(RANK_ORDER) do
    local cut = RANK_CUTOFFS[rname]
    if not cut or score >= cut.score then best = rname end
  end
  return best
end

local function firstAlt(v)
  return type(v) == "table" and v[1] or v
end

-- Self-localizing rank names: when a fish's rank is known from the score cutoffs,
-- the word on its rank line IS this locale's name for that rank. Learn it once
-- (persisted per locale), but only from scores a safe distance from the
-- provisional cutoffs so an off-by-a-little estimate can't mislabel a rank.
local LEAD_LABEL = { " ", "\t", ":", "\194\160", "\239\188\154" }
local function stripLeadingLabel(s)
  local changed = true
  while changed do
    changed = false
    for _, p in ipairs(LEAD_LABEL) do
      if s:sub(1, #p) == p then
        s = s:sub(#p + 1)
        changed = true
      end
    end
  end
  return s
end

local function learnRankWord(info)
  if not (info and info.rankLine) then return end
  local cache = BrinyBestDB and BrinyBestDB.rankWordCache
  if not cache then return end
  local loc = GetLocale()
  cache[loc] = cache[loc] or {}
  local words = cache[loc]
  -- an uncaught fish's rank line is the raw template — every localized rank word
  -- in canonical order ("[guppy][vairon][brochet][requin][trophée]"): authoritative,
  -- learned in one shot and allowed to overwrite heuristic entries
  if info.rankLine:find("[", 1, true) then
    local list = {}
    for w in info.rankLine:gmatch("%[([^%]]+)%]") do list[#list + 1] = w end
    if #list == 5 then
      for i, rname in ipairs(RANK_ORDER) do words[rname] = list[i] end
    end
    return
  end
  -- otherwise learn one word from a fish whose rank is cutoff-certain
  if not info.rank or info.score <= 0 then return end
  if words[info.rank] then return end
  for _, rname in ipairs(RANK_ORDER) do
    local cut = RANK_CUTOFFS[rname]
    if cut and cut.est and math.abs(info.score - cut.score) < 1.5 then return end
  end
  local word = stripLeadingLabel(info.rankLine):gsub("%s*[%(（].*$", "")
  word = stripTrailing(word)
  if word ~= "" and #word < 40 then words[info.rank] = word end
end

local function rankDisplay(rank)
  local cache = BrinyBestDB and BrinyBestDB.rankWordCache
  local words = cache and cache[GetLocale()]
  return (words and words[rank]) or rank
end

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

-- Blizzard's 12.1 fish descriptions garble the Coiled Isle vault names. Verified
-- in-game 2026-08-16: the only real sub-zone is "Vaults of Atal'Utek" (its own map
-- zone under The Coiled Isle; "Atal'Utek" and "Vaults of Ula'tek" don't exist), and
-- Ula'tek Snakehead is an ordinary Coiled Isle pool/open-water fish. The vaults
-- inherit the isle's loot table via the parent-map walk, so no fish needs to list
-- the vaults except the Stargorger, which is exclusive to them.

-- ---------------------------------------------------------------- UI strings
-- The addon's own text, taken from the Strings half of each Locales/<code>.lua
-- (Blizzard's labels are reused from LOCALE_PARSE where they exist; rank names
-- self-localize via the learned rank-word cache). Translations are maintainer-
-- written — corrections from native speakers welcome via GitHub issues.
--
-- Every locale file carries the full key set — untranslated entries are the English
-- text, so a locale reads English rather than breaking, and its file shows at a glance
-- what still needs translating. These metatables are the safety net underneath: a key
-- added to enUS alone still resolves everywhere instead of coming back nil. A locale
-- that wants a different fallback declares it on its own Strings table and is left
-- alone here — esMX is deliberately not chained to the closely related esES.
for _, strings in pairs(L_ALL) do
  if strings ~= L_ALL.enUS and not getmetatable(strings) then
    setmetatable(strings, { __index = L_ALL.enUS })
  end
end
local L = L_ALL[GetLocale()] or L_ALL.enUS

-- The two real zones the garbled names refer to, as locale-independent UiMapIDs
-- (verified in-game Aug 20: 2512 = The Coiled Isle, 2509 = Vaults of Atal'Utek).
-- The client resolves the localized zone name itself, so one correction table
-- serves every language.
local MAP_ISLE, MAP_VAULTS = 2512, 2509

-- Zones that share another zone's fishing loot table but never appear in the
-- fish descriptions. The Isle of Quel'Danas (three phased map IDs) fishes the
-- Eversong Woods list; verified in-game 2026-09-17 after a user report.
-- Keyed by live map ID, value is the map ID whose name the fish lists use.
local MAP_EVERSONG = 2395
local ZONE_MAP_ALIASES = {
  [2424] = MAP_EVERSONG, -- Isle of Quel'Danas
  [2432] = MAP_EVERSONG, -- Isle of Quel'Danas (phase)
  [2565] = MAP_EVERSONG, -- Isle of Quel'Danas (phase)
}

local function mapName(id, fallback)
  local mi = C_Map.GetMapInfo(id)
  return (mi and mi.name) or fallback
end

-- Raw garbled area strings as each locale's fish descriptions actually write them
-- (harvested from live clients + Wowhead tooltip data for all 11 languages).
-- Stargorger's "Atal'Utek" variants → vaults + isle (lure works in both);
-- Snakehead's phantom vault variants → isle only (it's an ordinary isle fish).
local VAULTS_AND_ISLE = { vaults = true, isle = true }
local ISLE_ONLY = { isle = true }
local GARBLED_AREAS = {
  ["Atal'Utek"] = VAULTS_AND_ISLE,    -- enUS/deDE/esES/esMX/ptBR
  ["Atal'utek"] = VAULTS_AND_ISLE,    -- itIT
  ["Atal\226\128\153Utek"] = VAULTS_AND_ISLE, -- frFR (curly apostrophe)
  ["\236\149\132\237\131\136\236\154\176\237\133\141"] = VAULTS_AND_ISLE, -- koKR 아탈우텍
  ["\208\144\209\130\208\176\208\187'\208\163\209\130\208\181\208\186"] = VAULTS_AND_ISLE, -- ruRU Атал'Утек
  ["\233\152\191\229\161\148\228\185\140\231\137\185\229\133\139"] = VAULTS_AND_ISLE, -- zhCN 阿塔乌特克
  ["\233\152\191\229\161\148\231\131\143\231\137\185\229\133\139"] = VAULTS_AND_ISLE, -- zhTW 阿塔烏特克
  ["Vaults of Ula'tek"] = ISLE_ONLY,
  ["Gew\195\182lbe von Ula'tek"] = ISLE_ONLY,   -- deDE
  ["caveaux d\226\128\153Ula\226\128\153tek"] = ISLE_ONLY, -- frFR
  ["C\195\161maras de Ula'tek"] = ISLE_ONLY,    -- esES
  ["B\195\179vedas de Ula'tek"] = ISLE_ONLY,    -- esMX
  ["Segrete di Ula'tek"] = ISLE_ONLY,             -- itIT
  ["\236\154\184\235\157\188\237\133\141 \234\184\136\234\179\160"] = ISLE_ONLY, -- koKR 울라텍 금고
  ["C\195\162maras de Ula'tek"] = ISLE_ONLY,    -- ptBR
  ["\208\165\209\128\208\176\208\189\208\184\208\187\208\184\209\137\208\176 \208\163\208\187\208\176'\209\130\208\181\208\186"] = ISLE_ONLY, -- ruRU Хранилища Ула'тек
  ["\228\185\140\230\139\137\231\137\185\229\133\139\229\156\176\231\170\159"] = ISLE_ONLY, -- zhCN 乌拉特克地窟
  ["\231\131\143\230\139\137\231\137\185\229\133\139\229\175\182\229\186\171"] = ISLE_ONLY, -- zhTW 烏拉特克寶庫
}

local function correctedAreas(a)
  local g = GARBLED_AREAS[a]
  if not g then return nil end
  local out = {}
  if g.vaults then out[#out + 1] = mapName(MAP_VAULTS, "Vaults of Atal'Utek") end
  if g.isle then out[#out + 1] = mapName(MAP_ISLE, "The Coiled Isle") end
  return out
end

-- settings can override which locale's parse strings are used (mainly a debugging
-- aid — the parse language must match the client's actual journal text to work)
local function setParseLocale(override)
  local eff = override or GetLocale()
  untranslatedLocale = (not LOCALE_PARSE[eff]) and eff or nil
  PARSE = LOCALE_PARSE[eff] or LOCALE_PARSE.enUS
end

-- Exceptions to the generic "any fish, open water or pools" rule, verified in-game
-- 2026-08-16: the Coiled Stargorger never bites without its rep-locked lure, while
-- the Ula'tek Snakehead's description falsely claims a lure requirement (it also
-- calls the vaults "Temple of Ula'tek" — a third name for the same place). A note
-- here replaces the generic disclaimer line in that fish's tooltip.
local function fishNote(id)
  if id == 1295408 then -- Coiled Stargorger
    return L.NOTE_STARGORGER:format(mapName(MAP_VAULTS, "Vaults of Atal'Utek"), mapName(MAP_ISLE, "The Coiled Isle"))
  elseif id == 1295406 then -- Ula'tek Snakehead
    return L.NOTE_SNAKEHEAD:format(mapName(MAP_ISLE, "The Coiled Isle"))
  end
end

-- Blizzard rate lines too wrong to show (e.g. the Snakehead's phantom lure requirement)
local FISH_HIDE_RATES = {
  [1295406] = true, -- Ula'tek Snakehead
}

-- Fish with a targeted lure item ("Increases the chance to catch X for 30 min").
-- Complete family per the item DB, 2026-08-23: seven lures, all craftable from
-- fishing recipe books. The Root Crab's lure is named "Rootland Crab Lure"
-- (recipe 244818) — Blizzard's name, same fish.
local FISH_LURES = {
  [1225269] = true, -- Root Crab ("Rootland Crab Lure")
  [1225273] = true, -- Ominous Octopus (241149)
  [1225274] = true, -- Blood Hunter (241147)
  [1225278] = true, -- Sunwell Fish (241150)
  [1225284] = true, -- Lucky Loa (241145)
  [1295406] = true, -- Ula'tek Snakehead (277821)
  [1295408] = true, -- Coiled Stargorger (241151, required — see fishNote)
}

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
  -- Cursed Oddities (and possibly others) have no score system at all; only fish whose
  -- description carries an "Anglin' Score:" line count toward zone/global maximums
  local scorePos, scoreEnd = findLabel(desc, PARSE.scoreLabel)
  info.scoreable = scorePos ~= nil
  -- skip colons/spaces (incl. French " : " and fullwidth "：") up to the number,
  -- without crossing onto the next line
  local scoreRaw = scoreEnd and desc:match("^[^%d\r\n]*([%d%.,]+)", scoreEnd + 1)
  info.score = parseNumber(scoreRaw) or 0
  -- freshly loaded clients can serve the description before its dynamic values
  -- resolve ("Score de pêche : points." with no number); treat as still loading
  info.valuesPending = info.scoreable and scoreRaw == nil
  local _, rankEnd = findLabel(desc, PARSE.rankLabel)
  local rankLine = rankEnd and desc:match("^%s*([^\n\r]+)", rankEnd + 1)
  info.rankLine = rankLine -- raw, for the rank-word harvester in the dev harness
  if rankLine and not rankLine:find("%[") then
    -- plain-find each localized rank word (works for CJK where "words" don't split)
    for localized, canonical in pairs(PARSE.rankWords or {}) do
      if rankLine:find(localized, 1, true) then
        info.rank = canonical
        break
      end
    end
  end
  if not info.rank and rankLine and not rankLine:find("[", 1, true) then
    local cache = BrinyBestDB and BrinyBestDB.rankWordCache
    local words = cache and cache[GetLocale()]
    if words then
      for canon, w in pairs(words) do
        if rankLine:find(w, 1, true) then
          info.rank = canon
          break
        end
      end
    end
  end
  if not info.rank and info.scoreable and info.score > 0 then
    info.rank = rankFromScore(info.score) -- cutoff fallback for untranslated rank words
  end
  info.rankNum = info.rank and RANK_NUM[info.rank] or 0

  local mode, lastHeader
  for rawLine in desc:gmatch("[^\n\r]+") do
    local line = rawLine:match("^%s*(.-)%s*$")
    if startsWithAny(line, PARSE.areasHeader) then
      mode = "areas"
    elseif startsWithAny(line, PARSE.poolsHeader) then
      mode = "pools"
    elseif startsWithAny(line, PARSE.ratesHeader) then
      mode = "rates"
    elseif startsWithAny(line, PARSE.descriptionHeader) then
      mode = nil
    elseif startsWithAny(line, PARSE.specialHeader) then
      mode = "special"
      lastHeader = true
    elseif bulletValue(line) then
      local v = bulletValue(line)
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
    elseif mode == "rates" and line ~= "" then
      -- frFR sometimes writes a single rate line with no bullet
      info.rates[#info.rates + 1] = stripTrailing(line)
    end
  end

  local corrected, seenArea = {}, {}
  for _, a in ipairs(info.areas) do
    for _, r in ipairs(correctedAreas(a) or { a }) do
      if not seenArea[r] then
        seenArea[r] = true
        corrected[#corrected + 1] = r
      end
    end
  end
  info.areas = corrected

  -- All Midnight fish can be caught in both open water and pools; the Rates text
  -- only expresses where the catch rate is better, so the tag shows bias, not exclusivity.
  local rateText = table.concat(info.rates, " "):lower()
  local mentionsOpen = PARSE.openWaterWord and rateText:find(PARSE.openWaterWord, 1, true) ~= nil
  local mentionsPool = PARSE.poolWord and rateText:find(PARSE.poolWord, 1, true) ~= nil
  if mentionsPool and PARSE.onlyWord and rateText:find(PARSE.onlyWord, 1, true) then
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
  local s = ""
  if info.bias == "open" then
    s = (" |cff69ccf0(%s)|r"):format(L.TAG_OPEN)
  elseif info.bias == "pools" then
    s = (" |cffffcc00(%s)|r"):format(L.TAG_POOL)
  elseif info.bias == "poolsonly" then
    s = (" |cffff7f3f(%s)|r"):format(L.TAG_POOL_ONLY)
  elseif info.bias == "both" then
    s = (" |cff1eff00(%s)|r"):format(L.TAG_EITHER)
  end
  if FISH_LURES[info.id] then
    s = s .. ((s == "" and " " or "") .. "|cffa335ee(%s)|r"):format(L.TAG_LURE)
  end
  return s
end

-- ---------------------------------------------------------------- warband score

local function escapePattern(s)
  return (s:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?]", "%%%0"))
end

local function warbandScore()
  local ok, _, _, _, qty = pcall(GetAchievementCriteriaInfo, ACHIEVEMENT_ID, 1)
  local critQty = ok and qty or nil
  local desc = C_Spell.GetSpellDescription(SCORE_SPELL)
  local precise
  if desc then
    if PARSE.pointsWord then
      precise = desc:match("([%d%.,]+)%s*" .. escapePattern(PARSE.pointsWord))
    end
    -- fallback for locales without a pointsWord: first decimal-looking number
    precise = precise or desc:match("(%d+[%.,]%d)")
  end
  return precise or (critQty and tostring(critQty)) or "?", critQty
end

-- ---------------------------------------------------------------- zone matching

local function currentZoneNames()
  local names = {}
  local z = GetZoneText()
  if z and z ~= "" then names[(normalizeArea(z))] = true end
  local sub = GetSubZoneText()
  if sub and sub ~= "" then names[(normalizeArea(sub))] = true end
  local mapID = C_Map.GetBestMapForUnit("player")
  local hops = 0
  while mapID and hops < 6 do
    local mi = C_Map.GetMapInfo(mapID)
    if not mi then break end
    if mi.name then names[(normalizeArea(mi.name))] = true end
    local alias = ZONE_MAP_ALIASES[mapID]
    if alias then
      local an = mapName(alias)
      if an then names[(normalizeArea(an))] = true end
    end
    mapID = (mi.parentMapID and mi.parentMapID > 0) and mi.parentMapID or nil
    hops = hops + 1
  end
  return names
end

-- ---------------------------------------------------------------- progress tracking / celebration

local sessionHidden = false -- X button hides until next reload; intentionally not saved
local fishedThisSession = false -- gates "hide until fishing"; session-scoped so a reload behaves like a login
-- the "Fishing" cast spells, observed via the BrinyProbe catch capture; any cast
-- counts as fishing activity — no need to wait for a catch, let alone a rank change
local FISHING_CASTS = { [131474] = true, [131476] = true }

local function coloredName(info)
  return ("|cff%s%s|r"):format(CAT_HEX[info.cat] or "ffffff", info.name)
end

local toast
local function ensureToast()
  if toast then return toast end
  toast = CreateFrame("Frame", "BrinyBestToast", UIParent, "BackdropTemplate")
  toast:SetSize(440, 96)
  toast:SetScale(((BrinyBestDB.settings and tonumber(BrinyBestDB.settings.scale)) or 100) / 100)
  toast:SetPoint("TOP", 0, -170)
  toast:SetFrameStrata("HIGH")
  toast:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 14,
    insets = { left = 4, right = 4, top = 4, bottom = 4 },
  })
  toast:SetBackdropColor(0.08, 0.05, 0, 0.9)
  toast:SetBackdropBorderColor(1, 0.5, 0, 1)
  toast:Hide()

  toast.icon = toast:CreateTexture(nil, "ARTWORK")
  toast.icon:SetSize(56, 56)
  toast.icon:SetPoint("LEFT", 18, 0)

  toast.title = toast:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
  toast.title:SetPoint("TOPLEFT", 88, -16)
  toast.title:SetText("|cffff8000" .. L.TOAST_TROPHY .. "|r")

  toast.fish = toast:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  toast.fish:SetPoint("TOPLEFT", 88, -48)

  toast.spark = toast:CreateTexture(nil, "OVERLAY")
  toast.spark:SetSize(80, 80)
  toast.spark:SetPoint("CENTER", toast.icon, "CENTER")
  toast.spark:SetTexture("Interface\\Cooldown\\star4")
  toast.spark:SetBlendMode("ADD")
  toast.spark:SetVertexColor(1, 0.6, 0, 0.9)

  local ag = toast:CreateAnimationGroup()
  local aIn = ag:CreateAnimation("Alpha")
  aIn:SetFromAlpha(0); aIn:SetToAlpha(1); aIn:SetDuration(0.25); aIn:SetOrder(1)
  local sIn = ag:CreateAnimation("Scale")
  sIn:SetScaleFrom(1.6, 1.6); sIn:SetScaleTo(1, 1); sIn:SetDuration(0.35)
  sIn:SetOrder(1); sIn:SetSmoothing("OUT")
  local aOut = ag:CreateAnimation("Alpha")
  aOut:SetFromAlpha(1); aOut:SetToAlpha(0); aOut:SetDuration(0.9)
  aOut:SetOrder(2); aOut:SetStartDelay(3.4)
  ag:SetScript("OnFinished", function() toast:Hide() end)
  toast.ag = ag

  local sparkAg = toast.spark:CreateAnimationGroup()
  sparkAg:SetLooping("REPEAT")
  local rot = sparkAg:CreateAnimation("Rotation")
  rot:SetDegrees(360); rot:SetDuration(6)
  toast.sparkAg = sparkAg
  return toast
end

local function celebrate(info)
  local t = ensureToast()
  if info.icon then t.icon:SetTexture(info.icon) end
  t.fish:SetText(coloredName(info) .. (" |cffffd100%s|r"):format(L.BANKED))
  t.ag:Stop()
  t:Show()
  t:SetAlpha(1)
  t.ag:Play()
  t.sparkAg:Play()
  pcall(PlaySound, SOUNDKIT and (SOUNDKIT.UI_LEGENDARY_LOOT_TOAST or SOUNDKIT.UI_EPICLOOT_TOAST) or 44293)
  chat(L.TROPHY_CHAT:format(coloredName(info)))
end

local function checkProgress(info)
  if not info.scoreable then return end
  local db = BrinyBestDB
  db.scores = db.scores or {}
  db.ranks = db.ranks or {}
  local oldScore = db.scores[info.id]
  local oldRank = db.ranks[info.id] or 0
  if oldScore == nil then
    -- first sighting (fresh install): baseline silently
    db.scores[info.id] = info.score
    db.ranks[info.id] = info.rankNum
    return
  end
  if info.score > oldScore + 0.05 then
    local rankNote = ""
    if info.rank and info.rankNum > oldRank and info.rankNum < 5 then
      rankNote = L.REACHED:format(("|cff%s%s|r"):format(RANK_HEX[info.rank], rankDisplay(info.rank)))
    end
    chat(L.IMPROVED:format(coloredName(info),
      ("|cffffd100%.1f|r"):format(oldScore), ("|cffffd100%.1f|r"):format(info.score)) .. rankNote)
  end
  if info.rankNum >= 5 and oldRank < 5 then
    celebrate(info)
  end
  if info.score > oldScore then db.scores[info.id] = info.score end
  if info.rankNum > oldRank then db.ranks[info.id] = info.rankNum end
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
  -- store offsets in screen (UIParent) space so they survive scale changes
  local point, _, relPoint, x, y = self:GetPoint()
  local sc = self:GetScale()
  BrinyBestDB.point = { point, relPoint, x * sc, y * sc }
end)

local SCALE_STEPS = { 85, 100, 115, 125, 150 }

local function positionFrame()
  local sc = frame:GetScale()
  frame:ClearAllPoints()
  local p = BrinyBestDB and BrinyBestDB.point
  if p then
    frame:SetPoint(p[1], UIParent, p[2], p[3] / sc, p[4] / sc)
  else
    frame:SetPoint("RIGHT", UIParent, "RIGHT", -80 / sc, 60 / sc)
  end
end

local function applyScale()
  local pct = tonumber(BrinyBestDB and BrinyBestDB.settings and BrinyBestDB.settings.scale) or 100
  pct = math.max(50, math.min(200, pct))
  frame:SetScale(pct / 100)
  if toast then toast:SetScale(pct / 100) end
  positionFrame()
end

local sessionClose = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
sessionClose:SetPoint("TOPRIGHT", -1, -1)
sessionClose:SetScript("OnClick", function()
  sessionHidden = true
  frame:Hide()
  chat(L.HIDDEN_SESSION)
end)

local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
title:SetPoint("TOPLEFT", 10, -8)
title:SetJustifyH("LEFT")

local scoreLine = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
scoreLine:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -2)
scoreLine:SetJustifyH("LEFT")

local footer = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
footer:SetJustifyH("LEFT")
-- bounded + wrappable: the hidden-Trophy note pushes this line past the frame
-- edge in most languages, so let it fold instead of spilling out
footer:SetWidth(FRAME_WIDTH - 20)
footer:SetWordWrap(true)

local zHeader = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
zHeader:SetJustifyH("LEFT")
zHeader:SetText(L.IMPROVE .. ":")

local zoneNames = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
zoneNames:SetJustifyH("LEFT")
zoneNames:SetPoint("TOPLEFT", zHeader, "BOTTOMLEFT", 4, -3)

-- three right-anchored columns so score, percent, and points-left align across
-- rows regardless of digit count (a single right-justified string wiggles)
local function statColumn(rightOffset)
  local fs = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  fs:SetJustifyH("RIGHT")
  fs:SetPoint("TOP", zoneNames, "TOP", 0, 0)
  fs:SetPoint("RIGHT", frame, "RIGHT", rightOffset, 0)
  return fs
end
local zoneScore = statColumn(-104)
local zonePct = statColumn(-68)
local zoneLeft = statColumn(-12)

local legend = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
legend:SetJustifyH("LEFT")
legend:SetWidth(FRAME_WIDTH - 20)
legend:SetText(("|cff69ccf0(%s)|r / |cffffcc00(%s)|r / |cff1eff00(%s)|r %s\n|cffa335ee(%s)|r %s"):format(L.TAG_OPEN, L.TAG_POOL, L.TAG_EITHER, L.LEGEND_SUFFIX, L.TAG_LURE, L.LEGEND_LURE))

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
    if not info.scoreable then
      GameTooltip:AddLine(L.NO_SCORE_TT, 0.6, 0.6, 0.6, true)
    else
      GameTooltip:AddLine(("%s: %.1f%s"):format(firstAlt(PARSE.scoreLabel), info.score, PARSE.pointsWord and (" " .. PARSE.pointsWord) or ""), 1, 1, 1)
      if info.rank then
        GameTooltip:AddLine(("%s: |cff%s%s|r (%d/5)"):format(firstAlt(PARSE.rankLabel), RANK_HEX[info.rank], rankDisplay(info.rank), info.rankNum), 1, 1, 1)
      else
        GameTooltip:AddLine(("%s: |cff9d9d9d%s|r"):format(firstAlt(PARSE.rankLabel), L.NOT_CAUGHT), 1, 1, 1)
      end
      if info.rankNum > 0 and info.rankNum < 5 then
        local nextRank = RANK_ORDER[info.rankNum + 1]
        local cut = RANK_CUTOFFS[nextRank]
        GameTooltip:AddLine(L.NEXT_RANK:format(
          ("|cff%s%s|r"):format(RANK_HEX[nextRank], rankDisplay(nextRank)),
          (cut.est and "~" or "") .. cut.score,
          math.max(0, cut.score - info.score)), 1, 1, 1)
      end
    end
    if info.special then
      GameTooltip:AddLine(firstAlt(PARSE.specialHeader) .. ": " .. info.special, 0.4, 0.85, 0.4)
    end
    if #info.pools > 0 then
      GameTooltip:AddLine(" ")
      GameTooltip:AddLine(firstAlt(PARSE.poolsHeader) .. ":", 0.4, 0.85, 0.4)
      for _, p in ipairs(info.pools) do
        GameTooltip:AddLine("  - " .. p, 1, 1, 1)
      end
    end
    if not FISH_HIDE_RATES[info.id] then
      for _, rate in ipairs(info.rates) do
        GameTooltip:AddLine(rate, 0.8, 0.8, 0.6, true)
      end
    end
    local note = fishNote(info.id)
    if note then
      GameTooltip:AddLine(note, 1, 0.55, 0.25, true)
    else
      if FISH_LURES[info.id] then
        GameTooltip:AddLine(L.LURE_TT, 0.64, 0.21, 0.93, true)
      end
      GameTooltip:AddLine(L.ALL_FISH_TT, 0.5, 0.5, 0.5, true)
    end
    GameTooltip:Show()
  end)
  row:SetScript("OnLeave", function() GameTooltip:Hide() end)
  rows[i] = row
  return row
end

-- ---------------------------------------------------------------- update

local pendingLoads = 0
local pendingValues = 0
local loadRetries = 0
local retryPending = false
local currentList = {}
local zoneAgg = {}
local globalScoreable = 0


-- needing 2500 of the possible points means every zone effectively needs this average
-- (with the confirmed 2800 max that's ~89.3%; derived from data, 2700 fallback while loading)
local function targetPct(globalMax)
  return 2500 / (globalMax or 2700) * 100
end

local function pctColor(pct, target)
  if pct >= target then return "1eff00" end -- on pace
  if pct >= 80 then return "ffd100" end     -- close
  return "ff7f3f"                           -- biggest opportunities
end

local function requestSpellData()
  for _, fdef in ipairs(FISH) do
    pcall(C_Spell.RequestLoadSpellData, fdef.id)
  end
  pcall(C_Spell.RequestLoadSpellData, SCORE_SPELL)
end

local function render(zoneLabel, list, statsList)
  title:SetText("BrinyBest — " .. zoneLabel)
  local precise, critQty = warbandScore()
  -- global max computed from fish that actually carry an Anglin' Score line;
  -- fall back to the community-known 2700 while descriptions are still loading
  local globalMax = (pendingLoads == 0 and globalScoreable > 0) and (globalScoreable * 100) or 2700
  scoreLine:SetText((L.WARBAND .. ": |cffffd100%s|r / 2500  |cff9d9d9d" .. L.SCORE_MAX .. "|r"):format(precise, globalMax))

  -- totals come from the unfiltered set so hiding Trophy fish doesn't skew them
  local total, trophies, scoreableCount = 0, 0, 0
  for _, info in ipairs(statsList or list) do
    if info.scoreable then
      scoreableCount = scoreableCount + 1
      total = total + info.score
      if info.rankNum >= 5 then trophies = trophies + 1 end
    end
  end
  for i, info in ipairs(list) do
    local row = getRow(i)
    row:ClearAllPoints()
    row:SetPoint("TOPLEFT", 10, -40 - (i - 1) * ROW_HEIGHT)
    local nameCol = ("|cff%s%s|r"):format(CAT_HEX[info.cat] or "ffffff", info.name)
    row.left:SetText(nameCol .. sourceSuffix(info))
    if info.rank then
      row.right:SetText(("%.1f  |cff%s%s|r"):format(info.score, RANK_HEX[info.rank], rankDisplay(info.rank)))
    else
      row.right:SetText(("%.1f  |cff9d9d9d—|r"):format(info.score))
    end
    row.info = info
    row:Show()
  end
  for i = #list + 1, #rows do rows[i]:Hide() end

  footer:ClearAllPoints()
  footer:SetPoint("TOPLEFT", 10, -42 - #list * ROW_HEIGHT)
  if scoreableCount > 0 then
    -- Trophy-rank fish sit at exactly 100.0, so zone max = 100 per scoreable fish
    local s = BrinyBestDB.settings or {}
    local word = s.showAll and L.TOTAL or L.ZONE
    -- own line: without a break the client folds this mid-word (CJK breaks
    -- anywhere), which reads worse than a clean second line
    local hiddenNote = (#list < scoreableCount and s.hideTrophy) and ("\n|cff9d9d9d%s|r"):format(L.TROPHY_HIDDEN:format(trophies)) or ""
    footer:SetText(("%s: |cffffd100%.1f|r / %d " .. L.PTS .. "   " .. L.TROPHIES .. ": |cffff8000%d|r/%d%s"):format(word, total, scoreableCount * 100, trophies, scoreableCount, hiddenNote))
  else
    local s = BrinyBestDB.settings or {}
    if s.locale and globalScoreable == 0 and pendingLoads == 0 then
      -- a parse-language override that matches nothing is almost certainly mismatched
      footer:SetText(("|cffff7f3f%s|r"):format(L.NO_PARSE_MISMATCH:format(s.locale)))
    else
      footer:SetText(L.NO_FISH)
    end
  end
  -- all-zone opportunity summary, biggest missing points first
  local zlist = {}
  for key, agg in pairs(zoneAgg) do
    zlist[#zlist + 1] = { key = key, name = agg.display or key, total = agg.total, max = agg.count * 100 }
  end
  table.sort(zlist, function(x, y)
    local mx, my = x.max - x.total, y.max - y.total
    if mx ~= my then return mx > my end
    return x.name < y.name
  end)
  local names, scores, pcts, lefts = {}, {}, {}, {}
  local cur = (normalizeArea(zoneLabel or ""))
  for _, z in ipairs(zlist) do
    local n = z.name
    if z.key == cur then n = "|cffffd100" .. n .. "|r" end
    names[#names + 1] = n
    local pct = z.max > 0 and (z.total / z.max * 100) or 0
    scores[#scores + 1] = ("%.0f / %d"):format(z.total, z.max)
    pcts[#pcts + 1] = ("|cff%s%.0f%%|r"):format(pctColor(pct, targetPct(globalMax)), pct)
    -- a zone with nothing left reads as finished rather than "0 left". Half a point
    -- is the cut because that is the last value %.0f still prints as a zero, and a
    -- zone that close already reads 2800 / 2800 and 100% in the cells beside this one
    local left = z.max - z.total
    lefts[#lefts + 1] = left <= 0.5 and L.LEFT_DONE or L.LEFT_FMT:format(left)
  end
  zHeader:ClearAllPoints()
  zHeader:SetPoint("TOPLEFT", footer, "BOTTOMLEFT", 0, -8)
  if #zlist > 0 then
    zHeader:SetText((L.IMPROVE .. " |cff9d9d9d" .. L.TARGET_AVG .. "|r:"):format(targetPct(globalMax)))
  else
    zHeader:SetText("")
  end
  zoneNames:SetText(table.concat(names, "\n"))
  zoneScore:SetText(table.concat(scores, "\n"))
  zonePct:SetText(table.concat(pcts, "\n"))
  zoneLeft:SetText(table.concat(lefts, "\n"))

  legend:ClearAllPoints()
  legend:SetPoint("TOPLEFT", zoneNames, "BOTTOMLEFT", -4, -8)

  -- every block below the rows is anchored to the one above it, so the frame
  -- height has to be the sum of their measured heights -- the old fixed
  -- 30 + 18 budget assumed a single-line footer and clipped it once the
  -- hidden-Trophy note wrapped
  frame:SetHeight(42 + #list * ROW_HEIGHT + footer:GetStringHeight() + 8
    + zHeader:GetStringHeight() + 3 + zoneNames:GetStringHeight() + 8
    + legend:GetStringHeight() + 8)
end

local function update()
  local zones = currentZoneNames()
  wipe(currentList)
  wipe(zoneAgg)
  pendingLoads = 0
  pendingValues = 0
  globalScoreable = 0
  local allList = {}

  for _, fdef in ipairs(FISH) do
    local info = parseFish(fdef)
    if info then
      checkProgress(info) -- notifications/celebrations fire even while the panel is hidden
      learnRankWord(info)
      if info.scoreable then
        globalScoreable = globalScoreable + 1
        allList[#allList + 1] = info
      end
      if info.valuesPending then
        pendingValues = pendingValues + 1
      end
      local inZone = false
      for _, area in ipairs(info.areas) do
        local key, disp = normalizeArea(area)
        if info.scoreable then
          local agg = zoneAgg[key] or { total = 0, count = 0, display = disp }
          agg.total = agg.total + info.score
          agg.count = agg.count + 1
          zoneAgg[key] = agg
        end
        if not inZone and info.scoreable and zones[key] then
          currentList[#currentList + 1] = info
          inZone = true
        end
      end
    else
      pendingLoads = pendingLoads + 1
    end
  end
  -- fresh clients (new locale packs especially) resolve description values late;
  -- keep nudging the spell data and re-checking until everything has numbers
  if pendingLoads > 0 or pendingValues > 0 then
    loadRetries = loadRetries + 1
    if loadRetries <= 12 and not retryPending then
      retryPending = true
      requestSpellData()
      C_Timer.After(1 + loadRetries * 0.5, function()
        retryPending = false
        update()
      end)
    end
  else
    loadRetries = 0
  end

  local s = BrinyBestDB.settings or {}
  local displayList, label
  if s.showAll then
    displayList, label = allList, L.ALL_FISH
  else
    displayList, label = currentList, GetZoneText() or "?"
  end
  table.sort(displayList, function(a, b)
    if a.score ~= b.score then return a.score > b.score end
    return a.name < b.name
  end)
  local statsList = displayList
  if s.hideTrophy then
    local kept = {}
    for _, info in ipairs(displayList) do
      if info.rankNum < 5 then kept[#kept + 1] = info end
    end
    displayList = kept
  end

  if BrinyBestDB.hidden or sessionHidden then
    frame:Hide()
    return
  end
  local inFishZone = #currentList > 0
  if not frame.manualShow then
    -- opt-in: stay hidden until fishing starts this session
    if s.hideUntilCatch and not fishedThisSession then
      frame:Hide()
      return
    end
    -- default on: the panel only appears where Midnight fish are recorded
    if s.onlyAchievementZones ~= false and not inFishZone then
      frame:Hide()
      return
    end
    if not s.showAll and not inFishZone then
      frame:Hide()
      return
    end
  end
  render(label, displayList, statsList)
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

-- ---------------------------------------------------------------- settings

local LOCALE_LIST = {}
for k in pairs(LOCALE_PARSE) do LOCALE_LIST[#LOCALE_LIST + 1] = k end
table.sort(LOCALE_LIST)

local function openSettingsMenu(anchor)
  local ok, err = pcall(function()
    if not (MenuUtil and MenuUtil.CreateContextMenu) then
      error("MenuUtil unavailable", 0)
    end
    MenuUtil.CreateContextMenu(anchor, function(_, root)
      local s = BrinyBestDB.settings
      root:CreateTitle("BrinyBest")
      root:CreateCheckbox(L.SET_SHOW_ALL,
        function() return s.showAll end,
        function() s.showAll = not s.showAll; update() end)
      root:CreateCheckbox(L.SET_HIDE_TROPHY,
        function() return s.hideTrophy end,
        function() s.hideTrophy = not s.hideTrophy; update() end)
      root:CreateCheckbox(L.SET_ONLY_ZONES,
        function() return s.onlyAchievementZones ~= false end,
        function() s.onlyAchievementZones = not (s.onlyAchievementZones ~= false); update() end)
      root:CreateCheckbox(L.SET_HIDE_LOGIN,
        function() return s.hideUntilCatch end,
        function() s.hideUntilCatch = not s.hideUntilCatch; update() end)
      root:CreateDivider()
      root:CreateTitle(L.SET_SCALE)
      for _, pct in ipairs(SCALE_STEPS) do
        root:CreateRadio(pct .. "%",
          function() return (tonumber(s.scale) or 100) == pct end,
          function() s.scale = pct; applyScale() end)
      end
      -- parse language intentionally NOT in the menu: Auto is always correct on a
      -- normal client and a mismatched override looks like a broken addon. The
      -- /bbf lang command remains as a debugging tool.
    end)
  end)
  if not ok then
    chat(L.MENU_FAILED:format(tostring(err)))
  end
end

local gear = CreateFrame("Button", nil, frame)
gear:SetSize(15, 15)
gear:SetPoint("RIGHT", sessionClose, "LEFT", -4, 0)
gear:SetNormalTexture("Interface\\Buttons\\UI-OptionsButton")
gear:SetHighlightTexture("Interface\\Buttons\\UI-OptionsButton", "ADD")
gear:SetScript("OnClick", function() openSettingsMenu(gear) end)
gear:SetScript("OnEnter", function(self)
  GameTooltip:SetOwner(self, "ANCHOR_LEFT")
  GameTooltip:SetText(L.SETTINGS)
  GameTooltip:Show()
end)
gear:SetScript("OnLeave", function() GameTooltip:Hide() end)

-- right-click anywhere on the panel also opens settings
frame:SetScript("OnMouseUp", function(_, btn)
  if btn == "RightButton" then openSettingsMenu(frame) end
end)

local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_ENTERING_WORLD")
events:RegisterEvent("ZONE_CHANGED_NEW_AREA")
events:RegisterEvent("ZONE_CHANGED")
events:RegisterEvent("ZONE_CHANGED_INDOORS")
events:RegisterEvent("CRITERIA_UPDATE")
events:RegisterEvent("CHAT_MSG_LOOT")
pcall(events.RegisterUnitEvent, events, "UNIT_SPELLCAST_SUCCEEDED", "player")
pcall(events.RegisterEvent, events, "SPELL_TEXT_UPDATE")

events:SetScript("OnEvent", function(_, event, arg1, ...)
  if event == "ADDON_LOADED" and arg1 == "BrinyBest" then
    BrinyBestDB = BrinyBestDB or {}
    BrinyBestDB.settings = BrinyBestDB.settings or {}
    BrinyBestDB.rankWordCache = BrinyBestDB.rankWordCache or {}
    if BrinyBestDB.settings.locale then
      setParseLocale(BrinyBestDB.settings.locale)
    end
    applyScale() -- also anchors the frame (saved or default position)
    if untranslatedLocale then
      chat(L.UNTRANSLATED:format(untranslatedLocale))
    end
  elseif event == "PLAYER_ENTERING_WORLD" then
    requestSpellData()
    queueUpdate(1.5)
  elseif event == "SPELL_TEXT_UPDATE" then
    queueUpdate(0.5)
  elseif event == "CRITERIA_UPDATE" then
    -- fires in bursts on each catch; re-request so descriptions refresh, then re-check
    -- (runs even when the panel is hidden so improvement/trophy alerts still fire)
    requestSpellData()
    queueUpdate(1.2)
  elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
    -- only casts in a zone with Midnight fish count — fishing elsewhere neither
    -- shows the panel nor arms it to appear on the next Briny zone visit
    local spellID = select(2, ...)
    if FISHING_CASTS[spellID] and not fishedThisSession and #currentList > 0 then
      fishedThisSession = true
      queueUpdate(0.3)
    end
  elseif event == "CHAT_MSG_LOOT" then
    -- backup trigger in case a special rod casts an unlisted spell: any journal
    -- fish in our own loot counts. Loot item names match the journal spell names,
    -- so this works in every locale; arg12 (the looter GUID) filters party members.
    if not fishedThisSession then
      local guid = select(11, ...)
      if guid == nil or guid == UnitGUID("player") then
        local looted = arg1 and arg1:match("|h%[(.-)%]|h")
        if looted then
          for _, fdef in ipairs(FISH) do
            local si = C_Spell.GetSpellInfo(fdef.id)
            if si and si.name == looted then
              fishedThisSession = true
              queueUpdate(0.3)
              break
            end
          end
        end
      end
    end
  else -- zone changes
    queueUpdate(0.3)
  end
end)

-- ---------------------------------------------------------------- slash commands

SLASH_BRINYBEST1 = "/bbf"
SLASH_BRINYBEST2 = "/brinybest"
SlashCmdList.BRINYBEST = function(msg)
  local cmd, rest = (msg or ""):lower():match("^%s*(%S*)%s*(.-)%s*$")
  if cmd == "" then
    if sessionHidden then
      -- X was clicked earlier this session; /bbf un-hides without touching the saved toggle
      sessionHidden = false
      BrinyBestDB.hidden = false
    else
      BrinyBestDB.hidden = not BrinyBestDB.hidden
    end
    frame.manualShow = not BrinyBestDB.hidden
    if BrinyBestDB.hidden then
      frame:Hide()
      chat(L.CMD_HIDDEN)
    else
      requestSpellData()
      update()
      if not frame:IsShown() then
        frame.manualShow = true
        update()
      end
      chat(L.CMD_SHOWN)
    end
  elseif cmd == "lock" then
    BrinyBestDB.locked = true
    chat(L.CMD_LOCKED)
  elseif cmd == "unlock" then
    BrinyBestDB.locked = false
    chat(L.CMD_UNLOCKED)
  elseif cmd == "reset" then
    BrinyBestDB.point = nil
    applyScale()
    chat(L.CMD_RESET)
  elseif cmd == "refresh" then
    requestSpellData()
    queueUpdate(0.5)
    chat(L.CMD_REFRESHING)
  elseif cmd == "all" then
    BrinyBestDB.settings.showAll = not BrinyBestDB.settings.showAll
    chat(BrinyBestDB.settings.showAll and L.CMD_ALL or L.CMD_ZONE)
    update()
  elseif cmd == "trophies" then
    BrinyBestDB.settings.hideTrophy = not BrinyBestDB.settings.hideTrophy
    chat(BrinyBestDB.settings.hideTrophy and L.CMD_TROPHY_HIDDEN or L.CMD_TROPHY_SHOWN)
    update()
  elseif cmd == "everywhere" then
    local s = BrinyBestDB.settings
    s.onlyAchievementZones = not (s.onlyAchievementZones ~= false)
    chat(s.onlyAchievementZones and L.CMD_ZONES_ONLY or L.CMD_ZONES_ALL)
    update()
  elseif cmd == "firstcatch" then
    local s = BrinyBestDB.settings
    s.hideUntilCatch = not s.hideUntilCatch
    chat(s.hideUntilCatch and L.CMD_FIRSTCATCH_ON or L.CMD_FIRSTCATCH_OFF)
    update()
  elseif cmd == "scale" then
    local pct = tonumber(rest)
    if pct then
      BrinyBestDB.settings.scale = math.max(50, math.min(200, math.floor(pct + 0.5)))
      applyScale()
      chat(L.CMD_SCALE:format(BrinyBestDB.settings.scale))
    else
      chat(L.CMD_SCALE_HINT:format(tonumber(BrinyBestDB.settings.scale) or 100))
    end
  elseif cmd == "lang" then
    if rest == "" or rest == "auto" then
      BrinyBestDB.settings.locale = nil
      setParseLocale(nil)
      chat(L.CMD_LANG_AUTO:format(GetLocale()))
      requestSpellData()
      queueUpdate(0.5)
    else
      local match
      for code in pairs(LOCALE_PARSE) do
        if code:lower() == rest then match = code end
      end
      if match then
        BrinyBestDB.settings.locale = match
        setParseLocale(match)
        chat(L.CMD_LANG_SET:format(match))
        requestSpellData()
        queueUpdate(0.5)
      else
        chat(L.CMD_LANG_UNKNOWN:format(table.concat(LOCALE_LIST, ", ")))
      end
    end
  elseif cmd == "version" then
    chat("v" .. (C_AddOns.GetAddOnMetadata("BrinyBest", "Version") or "?"))
  elseif cmd == "debug" then
    local zones = currentZoneNames()
    local zlist = {}
    for z in pairs(zones) do zlist[#zlist + 1] = z end
    chat(L.CMD_ZONES:format(table.concat(zlist, ", ")))
    local parsed, missing = 0, 0
    for _, fdef in ipairs(FISH) do
      local info = parseFish(fdef)
      if info then parsed = parsed + 1 else missing = missing + 1 end
    end
    chat(L.CMD_PARSED:format(parsed, missing, #currentList))
  else
    chat(L.CMD_COMMANDS)
    print(L.HELP)
  end
end

-- ---------------------------------------------------------------- internal API
-- Minimal surface for dev tooling (see tools/BrinyBestTest, which is not packaged).

BrinyBest = {
  fish = FISH,
  Lures = FISH_LURES,
  ParseFish = parseFish,
  NormalizeArea = normalizeArea,
  Celebrate = celebrate,
  Update = update,
  RequestSpellData = requestSpellData,
}
