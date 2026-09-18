-- BrinyBest locale data: French
-- Parse   = Blizzard's wording in this language (Midnight Anglin' journal and rod tooltips)
-- Strings = the addon's own UI text; entries still in English are untranslated

local addonName, ns = ...

ns.Locale = ns.Locale or {}

ns.Locale.frFR = {
  Parse = {
    scoreLabel = "Score de pêche",
    rankLabel = { "Rang de la prise", "Rang de capture" },
    areasHeader = "Poisson présent dans les régions",
    poolsHeader = "Bancs de poissons",
    ratesHeader = "Fréquence",
    descriptionHeader = "Description",
    specialHeader = "Utilisation spéciale",
    rankWords = { ["guppy"] = "Guppy", ["Guppy"] = "Guppy", ["trophée"] = "Trophy", ["Trophée"] = "Trophy" },
    openWaterWord = "étendues d’eau",
    poolWord = "bancs de poissons",
    onlyWord = "uniquement",
    venomWord = "venin",
  },
  Strings = {
    WARBAND = "Score de pêche du bataillon",
    ZONE = "Zone", TOTAL = "Total", TROPHIES = "Trophées", PTS = "pts",
    TROPHY_HIDDEN = "(%d trophées masqués)",
    NO_FISH = "Aucun poisson de Midnight enregistré pour cette zone.",
    IMPROVE = "Opportunités d’amélioration", TARGET_AVG = "(objectif : %.1f%% de moyenne)",
    LEFT_FMT = "%.0f restants",
    LEFT_DONE = "Terminé",
    TAG_OPEN = "eau libre", TAG_POOL = "banc", TAG_POOL_ONLY = "banc uniquement", TAG_EITHER = "les deux",
    TAG_LURE = "appât",
    LEGEND_SUFFIX = "indiquent le meilleur taux de capture", LEGEND_LURE = "= appât disponible",
    NO_SCORE_TT = "Pas de score de pêche — cette prise n’a ni rang ni points et ne compte ni pour la zone ni pour le haut fait.",
    NOT_CAUGHT = "pas encore pêché",
    NEXT_RANK = "Rang suivant : %s à %s — %.1f points restants",
    ALL_FISH_TT = "Tous les poissons peuvent être pêchés en eau libre ou dans les bancs ; l’étiquette indique le meilleur taux.",
    LURE_TT = "Un appât (à fabriquer ou acheter) augmente vos chances pour ce poisson.",
    NOTE_STARGORGER = "Nécessite son leurre spécial (récompense de réputation) — fonctionne dans %s et sur les bancs normaux autour de %s.",
    NOTE_SNAKEHEAD = "Aucun leurre requis, mais il aide beaucoup — se pêche dans les bancs et en eau libre autour de %s.",
    SET_SHOW_ALL = "Afficher tous les poissons (ignorer la zone)", SET_HIDE_TROPHY = "Masquer les poissons au rang Trophée",
    SET_ONLY_ZONES = "Afficher uniquement dans les zones de pêche de Midnight", SETTINGS = "Paramètres", ALL_FISH = "Tous les poissons",
    SET_HIDE_LOGIN = "Masquer jusqu’au début de la pêche",
    SET_SCALE = "Échelle",
    IMPROVED = "%s amélioré : %s → %s", REACHED = " — rang %s atteint !",
    TROPHY_CHAT = "TROPHÉE ! %s est au rang maximum !", BANKED = "— 100 points engrangés !",
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
