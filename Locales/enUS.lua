-- BrinyBest locale data: English (US)
-- Parse   = Blizzard's wording in this language (Midnight Anglin' journal and rod tooltips)
-- Strings = the addon's own UI text; entries still in English are untranslated

local addonName, ns = ...

ns.Locale = ns.Locale or {}

ns.Locale.enUS = {
  Parse = {
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
    venomWord = "Venom",
  },
  Strings = {
    WARBAND = "Warband Anglin' Score",
    ZONE = "Zone", TOTAL = "Total", TROPHIES = "Trophies", PTS = "pts",
    TROPHY_HIDDEN = "(%d Trophy hidden)",
    NO_FISH = "No Midnight fish recorded for this zone.",
    IMPROVE = "Improvement opportunities", TARGET_AVG = "(target %.1f%% avg)",
    LEFT_FMT = "%.0f left",
    LEFT_DONE = "Complete",
    TAG_OPEN = "open", TAG_POOL = "pool", TAG_POOL_ONLY = "pool only", TAG_EITHER = "either",
    TAG_LURE = "lure",
    LEGEND_SUFFIX = "shows where catch rates are best", LEGEND_LURE = "= lure available",
    NO_SCORE_TT = "No Anglin' Score — this catch has no rank system and does not count toward zone or achievement points.",
    NOT_CAUGHT = "not caught yet",
    NEXT_RANK = "Next rank: %s at %s — %.1f points to go",
    ALL_FISH_TT = "All fish can be caught in open water or pools; the tag shows the better rate.",
    LURE_TT = "A craftable or buyable lure boosts your chances for this fish.",
    NOTE_STARGORGER = "Requires its special lure (reputation reward) — works in %s and on normal pools around %s.",
    NOTE_SNAKEHEAD = "No lure required, but one definitely helps — caught in pools and open water around %s.",
    SET_SHOW_ALL = "Show all fish (ignore zone)", SET_HIDE_TROPHY = "Hide Trophy-rank fish",
    SET_ONLY_ZONES = "Only show in Midnight fishing zones", SETTINGS = "Settings", ALL_FISH = "All fish",
    SET_HIDE_LOGIN = "Hide until you start fishing",
    SET_SCALE = "Scale",
    IMPROVED = "Improved %s: %s → %s", REACHED = " — reached %s rank!",
    TROPHY_CHAT = "TROPHY! %s is at max rank!", BANKED = "— 100 points banked!",
    TOAST_TROPHY = "Trophy Catch!",
    SCORE_MAX = "(%d max)",
    NO_PARSE_MISMATCH = "No fish parsed — language override (%s) doesn't match the game's text language. Set it back to Auto.",
    HIDDEN_SESSION = "hidden for this session — /bbf brings it back; a /reload also restores it",
    MENU_FAILED = "settings menu failed (%s) — use /bbf all | /bbf trophies | /bbf everywhere | /bbf lang <code|auto>",
    UNTRANSLATED = "your client language (%s) isn't translated yet, so fish data may not parse. Help out at github.com/nerolabs/BrinyBest/issues",
    CMD_SHOWN = "shown",
    CMD_HIDDEN = "hidden — /bbf to show",
    CMD_LOCKED = "position locked",
    CMD_UNLOCKED = "position unlocked — drag to move",
    CMD_RESET = "position reset",
    CMD_REFRESHING = "refreshing",
    CMD_ALL = "showing all fish",
    CMD_ZONE = "showing current zone",
    CMD_TROPHY_HIDDEN = "Trophy-rank fish hidden",
    CMD_TROPHY_SHOWN = "Trophy-rank fish shown",
    CMD_ZONES_ONLY = "panel only shows in fishing zones",
    CMD_ZONES_ALL = "panel shows everywhere",
    CMD_FIRSTCATCH_ON = "panel hidden until you start fishing",
    CMD_FIRSTCATCH_OFF = "panel shows without waiting for fishing",
    SET_SHOW_VENOM = "Show Coiled Huntress venom count",
    VENOM_FMT = "%s: %d",
    CMD_VENOM_ON = "venom count shown",
    CMD_VENOM_OFF = "venom count hidden",
    VENOM_UNEQUIPPED = "Coiled Huntress not equipped",
    VENOM_MISSING = "Coiled Huntress not in your bags",
    CMD_SCALE = "scale: %d%%",
    CMD_SCALE_HINT = "scale: %d%% — /bbf scale <50-200> to change",
    CMD_LANG_AUTO = "parse language: auto (%s)",
    CMD_LANG_SET = "parse language: %s",
    CMD_LANG_UNKNOWN = "unknown locale — available: %s",
    CMD_ZONES = "zone names: %s",
    CMD_PARSED = "parsed %d fish, %d descriptions still loading, %d in this zone",
    CMD_COMMANDS = "commands:",
    HELP = [[
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
/bbf firstcatch   - toggle hiding the panel until you start fishing
/bbf venom       - toggle the venom count line
/bbf scale <pct>  - panel/toast scale, 50-200 (default 100)
/bbf lang <code>  - override parse language (e.g. frFR), "auto" resets
]],
  },
}
