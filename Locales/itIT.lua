-- BrinyBest locale data: Italian
-- Parse   = Blizzard's wording in this language (Midnight Anglin' journal and rod tooltips)
-- Strings = the addon's own UI text; entries still in English are untranslated

local addonName, ns = ...

ns.Locale = ns.Locale or {}

ns.Locale.itIT = {
  Parse = {
    scoreLabel = "Punteggio di Pesca",
    rankLabel = "Grado di Cattura",
    areasHeader = "Aree in cui si può trovare",
    poolsHeader = "Pozze di Pesca",
    ratesHeader = { "Probabilità", "Frequenza", "Rates" },
    descriptionHeader = "Descrizione",
    specialHeader = "Speciale",
    pointsWord = "punti",
    rankWords = { ["Bavosa"] = "Guppy" },
    openWaterWord = "mare aperto",
    poolWord = "pozze",
    onlyWord = "solo",
    venomWord = "veleno",
  },
  Strings = {
    WARBAND = "Punteggio di Pesca della banda",
    ZONE = "Zona", TOTAL = "Totale", TROPHIES = "Trofei", PTS = "pt",
    TROPHY_HIDDEN = "(%d trofei nascosti)",
    NO_FISH = "Nessun pesce di Midnight registrato per questa zona.",
    IMPROVE = "Opportunità di miglioramento", TARGET_AVG = "(obiettivo: %.1f%% di media)",
    LEFT_FMT = "%.0f mancanti",
    LEFT_DONE = "Completato",
    TAG_OPEN = "mare aperto", TAG_POOL = "pozza", TAG_POOL_ONLY = "solo pozza", TAG_EITHER = "entrambi",
    TAG_LURE = "esca",
    LEGEND_SUFFIX = "indicano la probabilità di cattura migliore", LEGEND_LURE = "= esca disponibile",
    NO_SCORE_TT = "Nessun Punteggio di Pesca — questa cattura non ha gradi né punti e non conta per la zona o l'impresa.",
    NOT_CAUGHT = "non ancora pescato",
    NEXT_RANK = "Grado successivo: %s a %s — %.1f punti mancanti",
    ALL_FISH_TT = "Tutti i pesci si possono pescare in mare aperto o nelle pozze; l'etichetta indica la probabilità migliore.",
    LURE_TT = "Un'esca (fabbricabile o acquistabile) aumenta le probabilità di catturare questo pesce.",
    NOTE_STARGORGER = "Richiede la sua esca speciale (ricompensa di reputazione) — funziona in %s e nelle pozze normali attorno a %s.",
    NOTE_SNAKEHEAD = "Nessuna esca richiesta, ma aiuta molto — si pesca nelle pozze e in mare aperto attorno a %s.",
    SET_SHOW_ALL = "Mostra tutti i pesci (ignora la zona)", SET_HIDE_TROPHY = "Nascondi i pesci di grado Trofeo",
    SET_ONLY_ZONES = "Mostra solo nelle zone di pesca di Midnight", SETTINGS = "Impostazioni", ALL_FISH = "Tutti i pesci",
    SET_HIDE_LOGIN = "Nascondi finché non inizi a pescare",
    SET_SCALE = "Scala",
    IMPROVED = "%s migliorato: %s → %s", REACHED = " — grado %s raggiunto!",
    TROPHY_CHAT = "TROFEO! %s è al grado massimo!", BANKED = "— 100 punti assicurati!",
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
