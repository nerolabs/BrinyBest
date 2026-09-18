-- BrinyBest locale data: Spanish (EU)
-- Parse   = Blizzard's wording in this language (Midnight Anglin' journal and rod tooltips)
-- Strings = the addon's own UI text; entries still in English are untranslated

local addonName, ns = ...

ns.Locale = ns.Locale or {}

ns.Locale.esES = {
  Parse = {
    scoreLabel = "Puntuación de pesca",
    rankLabel = "Rango de la captura",
    areasHeader = "Zonas en las que puedes encontrar",
    poolsHeader = { "Zonas de pesca", "Zona de pesca" },
    ratesHeader = "Frecuencia",
    descriptionHeader = "Descripción",
    specialHeader = "Especial",
    pointsWord = "puntos",
    rankWords = { ["Lebiste"] = "Guppy" },
    openWaterWord = "mar abierto",
    poolWord = "estanque",
    onlyWord = "solo",
    venomWord = "veneno",
  },
  Strings = {
    WARBAND = "Puntuación de pesca de la banda guerrera",
    ZONE = "Zona", TOTAL = "Total", TROPHIES = "Trofeos", PTS = "pts",
    TROPHY_HIDDEN = "(%d trofeos ocultos)",
    NO_FISH = "No hay peces de Midnight registrados en esta zona.",
    IMPROVE = "Oportunidades de mejora", TARGET_AVG = "(objetivo: %.1f%% de media)",
    LEFT_FMT = "faltan %.0f",
    LEFT_DONE = "Completado",
    TAG_OPEN = "mar abierto", TAG_POOL = "estanque", TAG_POOL_ONLY = "solo estanque", TAG_EITHER = "ambos",
    TAG_LURE = "cebo",
    LEGEND_SUFFIX = "indican la mejor tasa de captura", LEGEND_LURE = "= cebo disponible",
    NO_SCORE_TT = "Sin puntuación de pesca — esta captura no tiene rangos ni puntos y no cuenta para la zona ni el logro.",
    NOT_CAUGHT = "sin pescar aún",
    NEXT_RANK = "Siguiente rango: %s a %s — faltan %.1f puntos",
    ALL_FISH_TT = "Todos los peces pueden pescarse en mar abierto o en estanques; la etiqueta indica la mejor tasa.",
    LURE_TT = "Un cebo (fabricable o comprable) aumenta las probabilidades de pescar este pez.",
    NOTE_STARGORGER = "Requiere su señuelo especial (recompensa de reputación) — funciona en %s y en los estanques normales alrededor de %s.",
    NOTE_SNAKEHEAD = "No requiere señuelo, pero ayuda bastante — se pesca en estanques y mar abierto alrededor de %s.",
    SET_SHOW_ALL = "Mostrar todos los peces (ignorar zona)", SET_HIDE_TROPHY = "Ocultar peces con rango Trofeo",
    SET_ONLY_ZONES = "Mostrar solo en zonas de pesca de Midnight", SETTINGS = "Ajustes", ALL_FISH = "Todos los peces",
    SET_HIDE_LOGIN = "Ocultar hasta empezar a pescar",
    SET_SCALE = "Escala",
    IMPROVED = "%s mejorado: %s → %s", REACHED = " — ¡rango %s alcanzado!",
    TROPHY_CHAT = "¡TROFEO! ¡%s está al rango máximo!", BANKED = "— ¡100 puntos asegurados!",
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
