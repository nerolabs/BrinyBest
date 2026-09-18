-- BrinyBest locale data: German
-- Parse   = Blizzard's wording in this language (Midnight Anglin' journal and rod tooltips)
-- Strings = the addon's own UI text; entries still in English are untranslated

local addonName, ns = ...

ns.Locale = ns.Locale or {}

ns.Locale.deDE = {
  Parse = {
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
    venomWord = "Toxin",
  },
  Strings = {
    WARBAND = "Angelwertung der Kriegsmeute",
    ZONE = "Zone", TOTAL = "Gesamt", TROPHIES = "Trophäen", PTS = "Pkt.",
    TROPHY_HIDDEN = "(%d Trophäen ausgeblendet)",
    NO_FISH = "Keine Midnight-Fische für diese Zone erfasst.",
    IMPROVE = "Verbesserungsmöglichkeiten", TARGET_AVG = "(Ziel: %.1f%% Durchschnitt)",
    LEFT_FMT = "%.0f übrig",
    LEFT_DONE = "Fertig",
    TAG_OPEN = "offen", TAG_POOL = "Schwarm", TAG_POOL_ONLY = "nur Schwarm", TAG_EITHER = "beides",
    TAG_LURE = "Köder",
    LEGEND_SUFFIX = "zeigen die besten Fangraten", LEGEND_LURE = "= Köder verfügbar",
    NO_SCORE_TT = "Keine Angelwertung — dieser Fang hat kein Rangsystem und zählt nicht für Zonen- oder Erfolgspunkte.",
    NOT_CAUGHT = "noch nicht gefangen",
    NEXT_RANK = "Nächster Rang: %s bei %s — noch %.1f Punkte",
    ALL_FISH_TT = "Alle Fische können im offenen Gewässer oder in Schwärmen gefangen werden; das Etikett zeigt die bessere Rate.",
    LURE_TT = "Ein Köder (herstellbar oder kaufbar) erhöht die Fangchance für diesen Fisch.",
    NOTE_STARGORGER = "Benötigt seinen besonderen Köder (Rufbelohnung) — funktioniert in %s und an normalen Schwärmen rund um %s.",
    NOTE_SNAKEHEAD = "Kein Köder nötig, hilft aber deutlich — wird in Schwärmen und offenem Gewässer rund um %s gefangen.",
    SET_SHOW_ALL = "Alle Fische anzeigen (Zone ignorieren)", SET_HIDE_TROPHY = "Fische mit Trophäenrang ausblenden",
    SET_ONLY_ZONES = "Nur in Midnight-Angelzonen anzeigen", SETTINGS = "Einstellungen", ALL_FISH = "Alle Fische",
    SET_HIDE_LOGIN = "Ausblenden, bis geangelt wird",
    SET_SCALE = "Skalierung",
    IMPROVED = "%s verbessert: %s → %s", REACHED = " — Rang %s erreicht!",
    TROPHY_CHAT = "TROPHÄE! %s hat den Höchstrang!", BANKED = "— 100 Punkte gesichert!",
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
