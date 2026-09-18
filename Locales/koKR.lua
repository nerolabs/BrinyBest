-- BrinyBest locale data: Korean
-- Parse   = the wording Blizzard's Midnight Anglin' journal uses in this language
-- Strings = the addon's own UI text; entries still in English are untranslated

local addonName, ns = ...

ns.Locale = ns.Locale or {}

ns.Locale.koKR = {
  Parse = {
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
  Strings = {
    WARBAND = "전투부대 강태공 점수",
    ZONE = "지역", TOTAL = "전체", TROPHIES = "트로피", PTS = "점",
    TROPHY_HIDDEN = "(트로피 %d마리 숨김)",
    NO_FISH = "이 지역에는 기록된 한밤 물고기가 없습니다.",
    IMPROVE = "개선 기회", TARGET_AVG = "(목표: 평균 %.1f%%)",
    LEFT_FMT = "%.0f 남음",
    LEFT_DONE = "완료",
    TAG_OPEN = "개방 수역", TAG_POOL = "웅덩이", TAG_POOL_ONLY = "웅덩이 전용", TAG_EITHER = "둘 다",
    TAG_LURE = "미끼",
    LEGEND_SUFFIX = "표시는 더 좋은 확률을 나타냅니다", LEGEND_LURE = "= 미끼 있음",
    NO_SCORE_TT = "강태공 점수 없음 — 이 어획물은 등급과 점수가 없으며 지역 및 업적 점수에 포함되지 않습니다.",
    NOT_CAUGHT = "아직 잡지 못함",
    NEXT_RANK = "다음 등급: %s (%s) — %.1f점 남음",
    ALL_FISH_TT = "모든 물고기는 개방 수역이나 웅덩이에서 잡을 수 있으며, 표시는 더 좋은 확률을 나타냅니다.",
    LURE_TT = "미끼(제작 또는 구매 가능)가 이 물고기를 잡을 확률을 높여 줍니다.",
    NOTE_STARGORGER = "전용 미끼(평판 보상)가 필요합니다 — %s와(과) %s 주변의 일반 웅덩이에서 사용할 수 있습니다.",
    NOTE_SNAKEHEAD = "미끼는 필요 없지만 큰 도움이 됩니다 — %s 주변의 웅덩이와 개방 수역에서 잡힙니다.",
    SET_SHOW_ALL = "모든 물고기 표시 (지역 무시)", SET_HIDE_TROPHY = "트로피 등급 물고기 숨기기",
    SET_ONLY_ZONES = "한밤 낚시 지역에서만 표시", SETTINGS = "설정", ALL_FISH = "모든 물고기",
    SET_HIDE_LOGIN = "낚시를 시작할 때까지 숨기기",
    SET_SCALE = "배율",
    IMPROVED = "%s 향상: %s → %s", REACHED = " — %s 등급 달성!",
    TROPHY_CHAT = "트로피! %s이(가) 최고 등급입니다!", BANKED = "— 100점 확보!",
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
