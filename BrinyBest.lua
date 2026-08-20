-- BrinyBest: shows Midnight Anglin' fish scores and catch ranks for your current zone.
-- Data source: each journal fish is a dummy tradeskill recipe whose spell description
-- carries "Anglin' Score: N.N points", "Catch Rank: <rank>", areas, pools, and rates.
-- /bbf toggles the panel; /bbf help for options.

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
local LOCALE_PARSE = {
  enUS = {
    scoreLabel = "Anglin' Score",
    rankLabel = "Catch Rank",
    areasHeader = "Areas you can find",
    poolsHeader = "Fishing Pools",
    ratesHeader = "Rates",
    descriptionHeader = "Description",
    specialHeader = "Special",
    pointsWord = "points",
    rankWords = { Guppy = "Guppy", Minnow = "Minnow", Pike = "Pike", Shark = "Shark", Trophy = "Trophy" },
    openWaterWord = "open water",
    poolWord = "pool",
    onlyWord = "only",
  },
  deDE = {
    scoreLabel = "Angelwertung",
    rankLabel = "Fangrang",
    areasHeader = "Verbreitungsgebiete",
    poolsHeader = "Fischschwärme",
    ratesHeader = "Raten",
    descriptionHeader = "Beschreibung",
    specialHeader = "Besondere Verwendung",
    pointsWord = "Punkte",
    rankWords = { ["Guppy"] = "Guppy" },
    openWaterWord = "offenen gewässern",
    poolWord = "teich",
    onlyWord = "nur",
  },
  esES = {
    scoreLabel = "Puntuación de pesca",
    rankLabel = "Rango de la captura",
    areasHeader = "Zonas en las que puedes encontrar",
    poolsHeader = "Zonas de pesca",
    ratesHeader = "Frecuencia",
    descriptionHeader = "Descripción",
    specialHeader = "Especial",
    pointsWord = "puntos",
    rankWords = { ["Lebiste"] = "Guppy" },
    openWaterWord = "mar abierto",
    poolWord = "estanque",
    onlyWord = "solo",
  },
  frFR = {
    scoreLabel = "Score de pêche",
    rankLabel = "Rang de capture",
    areasHeader = "Poisson présent dans les régions",
    poolsHeader = "Bancs de poissons",
    ratesHeader = "Fréquence",
    descriptionHeader = "Description",
    specialHeader = "Utilisation spéciale",
    rankWords = { ["guppy"] = "Guppy" },
    openWaterWord = "étendues d’eau",
    poolWord = "bancs de poissons",
    onlyWord = "uniquement",
  },
  itIT = {
    scoreLabel = "Punteggio di Pesca",
    rankLabel = "Grado di Cattura",
    areasHeader = "Aree in cui si può trovare",
    poolsHeader = "Pozze di Pesca",
    ratesHeader = { "Probabilità", "Frequenza" },
    descriptionHeader = "Descrizione",
    specialHeader = "Speciale",
    pointsWord = "punti",
    rankWords = { ["Bavosa"] = "Guppy" },
    openWaterWord = "mare aperto",
    poolWord = "pozze",
    onlyWord = "solo",
  },
  koKR = {
    scoreLabel = "강태공 점수",
    rankLabel = "어획 등급",
    areasHeader = "이 생선을 잡을 수 있는 지역",
    poolsHeader = "낚시 웅덩이",
    ratesHeader = "확률",
    descriptionHeader = "설명",
    specialHeader = "특수",
    pointsWord = "점",
    rankWords = { ["치어"] = "Guppy" },
    openWaterWord = "개방된 수역",
    poolWord = "웅덩이",
  },
  ptBR = {
    scoreLabel = "Pontuação de pescaria",
    rankLabel = "Grau da captura",
    areasHeader = "Áreas de ocorrência",
    poolsHeader = "Pesqueiros",
    ratesHeader = "Frequência",
    descriptionHeader = "Descrição",
    specialHeader = "Especial",
    pointsWord = "pontos",
    rankWords = { ["Lebiste"] = "Guppy" },
    openWaterWord = "águas abertas",
    poolWord = "pesqueiro",
    onlyWord = "apenas",
  },
  ruRU = {
    scoreLabel = "Счет рыбалки",
    rankLabel = "Категория улова",
    areasHeader = "Зоны обитания",
    poolsHeader = "Косяки рыб",
    ratesHeader = "Распространенность",
    descriptionHeader = "Описание",
    specialHeader = "Особое свойство",
    rankWords = { ["гуппи"] = "Guppy" },
    openWaterWord = "открытом море",
    poolWord = "прудах",
    onlyWord = "только",
  },
  zhCN = {
    scoreLabel = "钓鱼得分",
    rankLabel = "捕获等级",
    areasHeader = "可发现此鱼的水域",
    poolsHeader = "垂钓池",
    ratesHeader = "几率",
    descriptionHeader = "描述",
    specialHeader = "特殊",
    pointsWord = "分",
    rankWords = { ["孔雀鱼"] = "Guppy" },
    openWaterWord = "开阔水域",
    poolWord = "鱼群",
  },
}
LOCALE_PARSE.enGB = LOCALE_PARSE.enUS
LOCALE_PARSE.esMX = LOCALE_PARSE.esES

local PARSE = LOCALE_PARSE[GetLocale()]
local untranslatedLocale = not PARSE and GetLocale() or nil
PARSE = PARSE or LOCALE_PARSE.enUS

-- leading grammatical articles vary per fish in Blizzard's localized area lists
-- (frFR: "l’île Annelée" on some fish, "île Annelée" on others), so they must not
-- take part in zone identity. Lowercase, checked against case-folded strings.
LOCALE_PARSE.deDE.articlePrefixes = { "der ", "die ", "das " }
LOCALE_PARSE.esES.articlePrefixes = { "el ", "la ", "los ", "las " }
LOCALE_PARSE.frFR.articlePrefixes = { "l’", "l'", "le ", "la ", "les " }
LOCALE_PARSE.itIT.articlePrefixes = { "l’", "l'", "il ", "lo ", "la ", "i ", "gli ", "le " }
LOCALE_PARSE.ptBR.articlePrefixes = { "o ", "a ", "os ", "as " }

-- localized numbers may use comma decimals ("96,6"); scores never carry thousands
local function parseNumber(s)
  if not s then return nil end
  return tonumber((s:gsub(",", ".")))
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

-- list items start with "-" (most locales) or "–" (frFR); values may carry trailing
-- "." / " ;" (frFR) or "。" (zhCN)
local function bulletValue(line)
  if line:sub(1, 1) ~= "-" and line:sub(1, 3) ~= "\226\128\147" then return nil end
  -- \194\160 = no-break space: French puts one before ";" in lists, and it isn't %s
  local v = line:gsub("^[%-\226\128\147\194\160%s]+", "", 1):gsub("[%s%.;\194\160\227\128\130]+$", "")
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
-- Keyed by raw (pre-normalization) description strings per locale; localized real
-- zone names verified against Wowhead zone pages 16535/16365.
local AREA_CORRECTIONS_BY_LOCALE = {
  enUS = {
    -- Stargorger lists both: lure-caught in the vaults AND on normal isle pools
    ["Atal'Utek"] = { "Vaults of Atal'Utek", "The Coiled Isle" },
    ["Vaults of Ula'tek"] = { "The Coiled Isle" },
  },
  frFR = {
    ["Atal’Utek"] = { "Caveaux d’Atal’Utek", "Île Annelée" },
    ["caveaux d’Ula’tek"] = { "Île Annelée" },
  },
}
AREA_CORRECTIONS_BY_LOCALE.enGB = AREA_CORRECTIONS_BY_LOCALE.enUS
local AREA_CORRECTIONS = AREA_CORRECTIONS_BY_LOCALE[GetLocale()] or {}

-- settings can override which locale's parse strings are used (mainly a debugging
-- aid — the parse language must match the client's actual journal text to work)
local function setParseLocale(override)
  local eff = override or GetLocale()
  untranslatedLocale = (not LOCALE_PARSE[eff]) and eff or nil
  PARSE = LOCALE_PARSE[eff] or LOCALE_PARSE.enUS
  AREA_CORRECTIONS = AREA_CORRECTIONS_BY_LOCALE[eff] or {}
end

-- Exceptions to the generic "any fish, open water or pools" rule, verified in-game
-- 2026-08-16: the Coiled Stargorger never bites without its rep-locked lure, while
-- the Ula'tek Snakehead's description falsely claims a lure requirement (it also
-- calls the vaults "Temple of Ula'tek" — a third name for the same place). A note
-- here replaces the generic disclaimer line in that fish's tooltip.
local FISH_NOTES = {
  [1295408] = "Requires the Coiled Stargorger Lure (reputation-locked) — works in the Vaults of Atal'Utek and on normal pools around The Coiled Isle.", -- Coiled Stargorger
  [1295406] = "No lure required, but one definitely helps — caught in pools and open water around The Coiled Isle.", -- Ula'tek Snakehead
}

-- Blizzard rate lines too wrong to show (e.g. the Snakehead's phantom lure requirement)
local FISH_HIDE_RATES = {
  [1295406] = true, -- Ula'tek Snakehead
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
  local scorePos, scoreEnd = desc:find(PARSE.scoreLabel, 1, true)
  info.scoreable = scorePos ~= nil
  -- skip colons/spaces (incl. French " : " and fullwidth "：") up to the number,
  -- without crossing onto the next line
  info.score = (scoreEnd and parseNumber(desc:match("^[^%d\r\n]*([%d%.,]+)", scoreEnd + 1))) or 0
  local _, rankEnd = desc:find(PARSE.rankLabel, 1, true)
  local rankLine = rankEnd and desc:match("^%s*([^\n\r]+)", rankEnd + 1)
  if rankLine and not rankLine:find("%[") then
    -- plain-find each localized rank word (works for CJK where "words" don't split)
    for localized, canonical in pairs(PARSE.rankWords or {}) do
      if rankLine:find(localized, 1, true) then
        info.rank = canonical
        break
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
      info.rates[#info.rates + 1] = (line:gsub("[%s%.;\194\160\227\128\130]+$", ""))
    end
  end

  local corrected, seenArea = {}, {}
  for _, a in ipairs(info.areas) do
    for _, r in ipairs(AREA_CORRECTIONS[a] or { a }) do
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
    mapID = (mi.parentMapID and mi.parentMapID > 0) and mi.parentMapID or nil
    hops = hops + 1
  end
  return names
end

-- ---------------------------------------------------------------- progress tracking / celebration

local sessionHidden = false -- X button hides until next reload; intentionally not saved

local function coloredName(info)
  return ("|cff%s%s|r"):format(CAT_HEX[info.cat] or "ffffff", info.name)
end

local toast
local function ensureToast()
  if toast then return toast end
  toast = CreateFrame("Frame", "BrinyBestToast", UIParent, "BackdropTemplate")
  toast:SetSize(440, 96)
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
  toast.title:SetText("|cffff8000Trophy Catch!|r")

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
  t.fish:SetText(coloredName(info) .. " |cffffd100— 100 points banked!|r")
  t.ag:Stop()
  t:Show()
  t:SetAlpha(1)
  t.ag:Play()
  t.sparkAg:Play()
  pcall(PlaySound, SOUNDKIT and (SOUNDKIT.UI_LEGENDARY_LOOT_TOAST or SOUNDKIT.UI_EPICLOOT_TOAST) or 44293)
  chat(("|cffff8000TROPHY!|r %s is at max rank!"):format(coloredName(info)))
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
      rankNote = (" — reached |cff%s%s|r rank!"):format(RANK_HEX[info.rank], info.rank)
    end
    chat(("Improved %s: |cffffd100%.1f|r → |cffffd100%.1f|r%s"):format(
      coloredName(info), oldScore, info.score, rankNote))
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
  local point, _, relPoint, x, y = self:GetPoint()
  BrinyBestDB.point = { point, relPoint, x, y }
end)

local sessionClose = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
sessionClose:SetPoint("TOPRIGHT", -1, -1)
sessionClose:SetScript("OnClick", function()
  sessionHidden = true
  frame:Hide()
  chat("hidden for this session — /bbf brings it back; a /reload also restores it")
end)

local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
title:SetPoint("TOPLEFT", 10, -8)
title:SetJustifyH("LEFT")

local scoreLine = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
scoreLine:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -2)
scoreLine:SetJustifyH("LEFT")

local footer = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
footer:SetJustifyH("LEFT")

local zHeader = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
zHeader:SetJustifyH("LEFT")
zHeader:SetText("Improvement opportunities:")

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
    if not info.scoreable then
      GameTooltip:AddLine("No Anglin' Score — this catch has no rank system and does not count toward zone or achievement points.", 0.6, 0.6, 0.6, true)
    else
      GameTooltip:AddLine(("Anglin' Score: %.1f points"):format(info.score), 1, 1, 1)
      if info.rank then
        GameTooltip:AddLine(("Catch Rank: |cff%s%s|r (%d of 5)"):format(RANK_HEX[info.rank], info.rank, info.rankNum), 1, 1, 1)
      else
        GameTooltip:AddLine("Catch Rank: |cff9d9d9dnot caught yet|r", 1, 1, 1)
      end
      if info.rankNum > 0 and info.rankNum < 5 then
        local nextRank = RANK_ORDER[info.rankNum + 1]
        local cut = RANK_CUTOFFS[nextRank]
        GameTooltip:AddLine(("Next rank: |cff%s%s|r at %s%d — %.1f points to go"):format(
          RANK_HEX[nextRank], nextRank, cut.est and "~" or "", cut.score,
          math.max(0, cut.score - info.score)), 1, 1, 1)
      end
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
    if not FISH_HIDE_RATES[info.id] then
      for _, rate in ipairs(info.rates) do
        GameTooltip:AddLine(rate, 0.8, 0.8, 0.6, true)
      end
    end
    local note = FISH_NOTES[info.id]
    if note then
      GameTooltip:AddLine(note, 1, 0.55, 0.25, true)
    else
      GameTooltip:AddLine("All fish can be caught in open water or pools; the tag shows the better rate.", 0.5, 0.5, 0.5, true)
    end
    GameTooltip:Show()
  end)
  row:SetScript("OnLeave", function() GameTooltip:Hide() end)
  rows[i] = row
  return row
end

-- ---------------------------------------------------------------- update

local pendingLoads = 0
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
  scoreLine:SetText(("Warband Anglin' Score: |cffffd100%s|r / 2500  |cff9d9d9d(%d max)|r"):format(precise, globalMax))

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
      row.right:SetText(("%.1f  |cff%s%s|r"):format(info.score, RANK_HEX[info.rank], info.rank))
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
    local word = s.showAll and "Total" or "Zone"
    local hiddenNote = (#list < scoreableCount and s.hideTrophy) and (" |cff9d9d9d(%d Trophy hidden)|r"):format(trophies) or ""
    footer:SetText(("%s: |cffffd100%.1f|r / %d pts   Trophies: |cffff8000%d|r/%d%s"):format(word, total, scoreableCount * 100, trophies, scoreableCount, hiddenNote))
  else
    local s = BrinyBestDB.settings or {}
    if s.locale and globalScoreable == 0 and pendingLoads == 0 then
      -- a parse-language override that matches nothing is almost certainly mismatched
      footer:SetText(("|cffff7f3fNo fish parsed — language override (%s) doesn't match the game's text language. Set it back to Auto.|r"):format(s.locale))
    else
      footer:SetText("No Midnight fish recorded for this zone.")
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
    lefts[#lefts + 1] = ("%.0f left"):format(z.max - z.total)
  end
  zHeader:ClearAllPoints()
  zHeader:SetPoint("TOPLEFT", footer, "BOTTOMLEFT", 0, -8)
  if #zlist > 0 then
    zHeader:SetText(("Improvement opportunities |cff9d9d9d(target %.1f%% avg)|r:"):format(targetPct(globalMax)))
  else
    zHeader:SetText("")
  end
  zoneNames:SetText(table.concat(names, "\n"))
  zoneScore:SetText(table.concat(scores, "\n"))
  zonePct:SetText(table.concat(pcts, "\n"))
  zoneLeft:SetText(table.concat(lefts, "\n"))

  legend:ClearAllPoints()
  legend:SetPoint("TOPLEFT", zoneNames, "BOTTOMLEFT", -4, -8)

  frame:SetHeight(40 + #list * ROW_HEIGHT + 30 + 18 + zoneNames:GetStringHeight() + 12)
end

local function update()
  local zones = currentZoneNames()
  wipe(currentList)
  wipe(zoneAgg)
  pendingLoads = 0
  globalScoreable = 0
  local allList = {}

  for _, fdef in ipairs(FISH) do
    local info = parseFish(fdef)
    if info then
      checkProgress(info) -- notifications/celebrations fire even while the panel is hidden
      if info.scoreable then
        globalScoreable = globalScoreable + 1
        allList[#allList + 1] = info
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
  local s = BrinyBestDB.settings or {}
  local displayList, label
  if s.showAll then
    displayList, label = allList, "All fish"
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

local function applyLocaleSetting(value)
  BrinyBestDB.settings.locale = value
  setParseLocale(value)
  requestSpellData()
  queueUpdate(0.5)
end

local function openSettingsMenu(anchor)
  local ok, err = pcall(function()
    if not (MenuUtil and MenuUtil.CreateContextMenu) then
      error("MenuUtil unavailable", 0)
    end
    MenuUtil.CreateContextMenu(anchor, function(_, root)
      local s = BrinyBestDB.settings
      root:CreateTitle("BrinyBest")
      root:CreateCheckbox("Show all fish (ignore zone)",
        function() return s.showAll end,
        function() s.showAll = not s.showAll; update() end)
      root:CreateCheckbox("Hide Trophy-rank fish",
        function() return s.hideTrophy end,
        function() s.hideTrophy = not s.hideTrophy; update() end)
      root:CreateCheckbox("Only show in fishing zones",
        function() return s.onlyAchievementZones ~= false end,
        function() s.onlyAchievementZones = not (s.onlyAchievementZones ~= false); update() end)
      root:CreateTitle("Parse language")
      root:CreateRadio(("Auto (%s)"):format(GetLocale()),
        function() return s.locale == nil end,
        function() applyLocaleSetting(nil) end)
      for _, code in ipairs(LOCALE_LIST) do
        root:CreateRadio(code,
          function() return s.locale == code end,
          function() applyLocaleSetting(code) end)
      end
    end)
  end)
  if not ok then
    chat("settings menu failed (" .. tostring(err) .. ") — use /bbf all | /bbf trophies | /bbf everywhere | /bbf lang <code|auto>")
  end
end

local gear = CreateFrame("Button", nil, frame)
gear:SetSize(15, 15)
gear:SetPoint("RIGHT", sessionClose, "LEFT", 2, 0)
gear:SetNormalTexture("Interface\\Buttons\\UI-OptionsButton")
gear:SetHighlightTexture("Interface\\Buttons\\UI-OptionsButton", "ADD")
gear:SetScript("OnClick", function() openSettingsMenu(gear) end)
gear:SetScript("OnEnter", function(self)
  GameTooltip:SetOwner(self, "ANCHOR_LEFT")
  GameTooltip:SetText("Settings")
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
pcall(events.RegisterEvent, events, "SPELL_TEXT_UPDATE")

events:SetScript("OnEvent", function(_, event, arg1)
  if event == "ADDON_LOADED" and arg1 == "BrinyBest" then
    BrinyBestDB = BrinyBestDB or {}
    BrinyBestDB.settings = BrinyBestDB.settings or {}
    if BrinyBestDB.settings.locale then
      setParseLocale(BrinyBestDB.settings.locale)
    end
    if BrinyBestDB.point then
      frame:ClearAllPoints()
      frame:SetPoint(BrinyBestDB.point[1], UIParent, BrinyBestDB.point[2], BrinyBestDB.point[3], BrinyBestDB.point[4])
    else
      frame:SetPoint("RIGHT", -80, 60)
    end
    if untranslatedLocale then
      chat(("your client language (%s) isn't translated yet, so fish data may not parse. Help out at github.com/nerolabs/BrinyBest/issues"):format(untranslatedLocale))
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
  else -- zone changes
    queueUpdate(0.3)
  end
end)

-- ---------------------------------------------------------------- slash commands

local HELP = [[
/bbf              - toggle the panel
/bbf lock         - lock position (click-through drag disabled)
/bbf unlock       - unlock position
/bbf reset        - reset position
/bbf refresh      - force a data refresh
/bbf debug        - print parse state for this zone to chat
Settings (also via the gear button / right-click on the panel):
/bbf all          - toggle showing all fish vs current zone
/bbf trophies     - toggle hiding Trophy-rank fish
/bbf everywhere   - toggle showing the panel outside fishing zones
/bbf lang <code>  - override parse language (e.g. frFR), "auto" resets
]]

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
      chat("hidden — /bbf to show")
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
  elseif cmd == "all" then
    BrinyBestDB.settings.showAll = not BrinyBestDB.settings.showAll
    chat(BrinyBestDB.settings.showAll and "showing all fish" or "showing current zone")
    update()
  elseif cmd == "trophies" then
    BrinyBestDB.settings.hideTrophy = not BrinyBestDB.settings.hideTrophy
    chat(BrinyBestDB.settings.hideTrophy and "Trophy-rank fish hidden" or "Trophy-rank fish shown")
    update()
  elseif cmd == "everywhere" then
    local s = BrinyBestDB.settings
    s.onlyAchievementZones = not (s.onlyAchievementZones ~= false)
    chat(s.onlyAchievementZones and "panel only shows in fishing zones" or "panel shows everywhere")
    update()
  elseif cmd == "lang" then
    if rest == "" or rest == "auto" then
      BrinyBestDB.settings.locale = nil
      setParseLocale(nil)
      chat("parse language: auto (" .. GetLocale() .. ")")
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
        chat("parse language: " .. match)
        requestSpellData()
        queueUpdate(0.5)
      else
        chat("unknown locale — available: " .. table.concat(LOCALE_LIST, ", "))
      end
    end
  elseif cmd == "version" then
    chat("v" .. (C_AddOns.GetAddOnMetadata("BrinyBest", "Version") or "?"))
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

-- ---------------------------------------------------------------- internal API
-- Minimal surface for dev tooling (see tools/BrinyBestTest, which is not packaged).

BrinyBest = {
  fish = FISH,
  ParseFish = parseFish,
  NormalizeArea = normalizeArea,
  Celebrate = celebrate,
  Update = update,
  RequestSpellData = requestSpellData,
}
