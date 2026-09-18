-- BrinyBest locale data: Portuguese (Brazil)
-- Parse   = Blizzard's wording in this language (Midnight Anglin' journal and rod tooltips)
-- Strings = the addon's own UI text; entries still in English are untranslated

local addonName, ns = ...

ns.Locale = ns.Locale or {}

ns.Locale.ptBR = {
  Parse = {
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
    venomWord = "Peçonha",
  },
  Strings = {
    WARBAND = "Pontuação de pescaria do bando de guerra",
    ZONE = "Zona", TOTAL = "Total", TROPHIES = "Troféus", PTS = "pts",
    TROPHY_HIDDEN = "(%d troféus ocultos)",
    NO_FISH = "Nenhum peixe de Midnight registrado nesta zona.",
    IMPROVE = "Oportunidades de melhoria", TARGET_AVG = "(meta: %.1f%% de média)",
    LEFT_FMT = "faltam %.0f",
    LEFT_DONE = "Completo",
    TAG_OPEN = "águas abertas", TAG_POOL = "pesqueiro", TAG_POOL_ONLY = "só pesqueiro", TAG_EITHER = "ambos",
    TAG_LURE = "isca",
    LEGEND_SUFFIX = "indicam a melhor taxa de captura", LEGEND_LURE = "= isca disponível",
    NO_SCORE_TT = "Sem pontuação de pescaria — esta captura não tem graus nem pontos e não conta para a zona nem a conquista.",
    NOT_CAUGHT = "ainda não pescado",
    NEXT_RANK = "Próximo grau: %s em %s — faltam %.1f pontos",
    ALL_FISH_TT = "Todos os peixes podem ser pescados em águas abertas ou pesqueiros; a etiqueta indica a melhor taxa.",
    LURE_TT = "Uma isca (fabricável ou comprável) aumenta as chances de pescar este peixe.",
    NOTE_STARGORGER = "Requer sua isca especial (recompensa de reputação) — funciona em %s e nos pesqueiros normais ao redor de %s.",
    NOTE_SNAKEHEAD = "Nenhuma isca necessária, mas ajuda bastante — pescado em pesqueiros e águas abertas ao redor de %s.",
    SET_SHOW_ALL = "Mostrar todos os peixes (ignorar zona)", SET_HIDE_TROPHY = "Ocultar peixes de grau Troféu",
    SET_ONLY_ZONES = "Mostrar apenas em zonas de pesca de Midnight", SETTINGS = "Configurações", ALL_FISH = "Todos os peixes",
    SET_HIDE_LOGIN = "Ocultar até começar a pescar",
    SET_SCALE = "Escala",
    IMPROVED = "%s melhorado: %s → %s", REACHED = " — grau %s alcançado!",
    TROPHY_CHAT = "TROFÉU! %s está no grau máximo!", BANKED = "— 100 pontos garantidos!",
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
