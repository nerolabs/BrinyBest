-- BrinyBest locale data: Russian
-- Parse   = the wording Blizzard's Midnight Anglin' journal uses in this language
-- Strings = the addon's own UI text; entries still in English are untranslated

local addonName, ns = ...

ns.Locale = ns.Locale or {}

ns.Locale.ruRU = {
  Parse = {
    scoreLabel = "Счет рыбалки",
    rankLabel = { "Уровень улова", "Категория улова" },
    areasHeader = "Зоны обитания",
    poolsHeader = "Косяки рыб",
    ratesHeader = "Распространенность",
    descriptionHeader = "Описание",
    specialHeader = "Особое свойство",
    rankWords = { ["гуппи"] = "Guppy", ["Гуппи"] = "Guppy" },
    openWaterWord = "открытом море",
    poolWord = "прудах",
    onlyWord = "только",
  },
  Strings = {
    WARBAND = "Счет рыбалки отряда",
    ZONE = "Зона", TOTAL = "Всего", TROPHIES = "Трофеи", PTS = "очк.",
    TROPHY_HIDDEN = "(скрыто трофеев: %d)",
    NO_FISH = "В этой зоне нет рыбы Midnight.",
    IMPROVE = "Возможности улучшения", TARGET_AVG = "(цель: в среднем %.1f%%)",
    LEFT_FMT = "осталось %.0f",
    LEFT_DONE = "Готово",
    TAG_OPEN = "открытая вода", TAG_POOL = "косяк", TAG_POOL_ONLY = "только косяк", TAG_EITHER = "оба",
    TAG_LURE = "приманка",
    LEGEND_SUFFIX = "показывают лучший шанс поимки", LEGEND_LURE = "= есть приманка",
    NO_SCORE_TT = "Нет счета рыбалки — этот улов не имеет уровней и очков и не идет в зачет зоны или достижения.",
    NOT_CAUGHT = "еще не поймана",
    NEXT_RANK = "Следующий уровень: %s при %s — осталось %.1f очков",
    ALL_FISH_TT = "Любую рыбу можно поймать в открытой воде или в косяках; метка показывает лучший шанс.",
    LURE_TT = "Приманка (можно создать или купить) повышает шанс поймать эту рыбу.",
    NOTE_STARGORGER = "Требуется особая наживка (награда за репутацию) — работает в %s и на обычных косяках вокруг %s.",
    NOTE_SNAKEHEAD = "Наживка не требуется, но заметно помогает — ловится в косяках и открытой воде вокруг %s.",
    SET_SHOW_ALL = "Показывать всю рыбу (без учета зоны)", SET_HIDE_TROPHY = "Скрывать рыбу уровня «Трофей»",
    SET_ONLY_ZONES = "Показывать только в рыболовных зонах Midnight", SETTINGS = "Настройки", ALL_FISH = "Вся рыба",
    SET_HIDE_LOGIN = "Скрывать, пока вы не начнёте рыбачить",
    SET_SCALE = "Масштаб",
    IMPROVED = "Улучшено: %s — %s → %s", REACHED = " — достигнут уровень %s!",
    TROPHY_CHAT = "ТРОФЕЙ! %s достигла максимального уровня!", BANKED = "— 100 очков в копилке!",
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
/bbf scale <pct>  - panel/toast scale, 50-200 (default 100)
/bbf lang <code>  - override parse language (e.g. frFR), "auto" resets
]],
  },
}
