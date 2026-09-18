-- BrinyBest locale data: Chinese (Traditional)
-- Parse   = Blizzard's wording in this language (Midnight Anglin' journal and rod tooltips)
-- Strings = the addon's own UI text; entries still in English are untranslated

local addonName, ns = ...

ns.Locale = ns.Locale or {}

ns.Locale.zhTW = {
  Parse = {
    scoreLabel = "釣魚分數",
    rankLabel = "漁獲等級",
    areasHeader = "可以找到這種魚的地區",
    poolsHeader = "釣魚池",
    ratesHeader = "機率",
    descriptionHeader = "說明",
    specialHeader = "特殊",
    pointsWord = "分",
    rankWords = { ["孔雀魚"] = "Guppy" },
    openWaterWord = "開放水域",
    poolWord = "魚群",
    venomWord = "毒液",
  },
  Strings = {
    WARBAND = "戰隊釣魚分數",
    ZONE = "區域", TOTAL = "總計", TROPHIES = "獎盃", PTS = "分",
    TROPHY_HIDDEN = "（已隱藏%d條獎盃魚）",
    NO_FISH = "此區域沒有記錄的至暗之夜魚類。",
    IMPROVE = "提升機會", TARGET_AVG = "（目標：平均%.1f%%）",
    LEFT_FMT = "還差%.0f",
    LEFT_DONE = "完成",
    TAG_OPEN = "開放水域", TAG_POOL = "魚群", TAG_POOL_ONLY = "僅魚群", TAG_EITHER = "皆可",
    TAG_LURE = "誘餌",
    LEGEND_SUFFIX = "標籤顯示更高的捕獲機率", LEGEND_LURE = "= 有誘餌",
    NO_SCORE_TT = "沒有釣魚分數——該漁獲沒有等級和分數，不計入區域或成就分數。",
    NOT_CAUGHT = "尚未捕獲",
    NEXT_RANK = "下一等級：%s（%s）——還差%.1f分",
    ALL_FISH_TT = "所有魚都可以在開放水域或魚群中捕獲；標籤顯示更高的機率。",
    LURE_TT = "可製作或購買的誘餌能提高釣到這種魚的機率。",
    NOTE_STARGORGER = "需要專用魚餌（聲望獎勵）——可在%s以及%s周圍的普通魚群使用。",
    NOTE_SNAKEHEAD = "無需魚餌，但魚餌會有很大幫助——在%s周圍的魚群和開放水域捕獲。",
    SET_SHOW_ALL = "顯示所有魚（忽略區域）", SET_HIDE_TROPHY = "隱藏獎盃等級的魚",
    SET_ONLY_ZONES = "僅在至暗之夜釣魚區域顯示", SETTINGS = "設定", ALL_FISH = "所有魚",
    SET_HIDE_LOGIN = "開始釣魚前隱藏",
    SET_SCALE = "縮放",
    IMPROVED = "%s提升：%s → %s", REACHED = "——達到%s等級！",
    TROPHY_CHAT = "獎盃！%s已達最高等級！", BANKED = "——已收入100分！",
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
