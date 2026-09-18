-- BrinyBest locale data: Chinese (Simplified)
-- Parse   = Blizzard's wording in this language (Midnight Anglin' journal and rod tooltips)
-- Strings = the addon's own UI text; entries still in English are untranslated

local addonName, ns = ...

ns.Locale = ns.Locale or {}

ns.Locale.zhCN = {
  Parse = {
    scoreLabel = "钓鱼得分",
    rankLabel = "捕获等级",
    areasHeader = { "可发现此鱼的水域", "可以找到这种鱼的地方" },
    poolsHeader = { "垂钓池", "钓鱼场所" },
    ratesHeader = { "几率", "稀有度" },
    descriptionHeader = "描述",
    specialHeader = "特殊",
    pointsWord = "分",
    rankWords = { ["孔雀鱼"] = "Guppy" },
    openWaterWord = "开阔水域",
    poolWord = "鱼群",
    venomWord = "毒液",
  },
  Strings = {
    WARBAND = "战团钓鱼得分",
    ZONE = "区域", TOTAL = "总计", TROPHIES = "奖杯鱼", PTS = "分",
    TROPHY_HIDDEN = "（已隐藏%d条奖杯鱼）",
    NO_FISH = "该区域没有记录的至暗之夜鱼类。",
    IMPROVE = "提升机会", TARGET_AVG = "（目标：平均%.1f%%）",
    LEFT_FMT = "还差%.0f",
    LEFT_DONE = "完成",
    TAG_OPEN = "开阔水域", TAG_POOL = "鱼群", TAG_POOL_ONLY = "仅鱼群", TAG_EITHER = "均可",
    TAG_LURE = "诱饵",
    LEGEND_SUFFIX = "标签显示更高的捕获几率", LEGEND_LURE = "= 有诱饵",
    NO_SCORE_TT = "没有钓鱼得分——该渔获没有等级和分数，不计入区域或成就分数。",
    NOT_CAUGHT = "尚未捕获",
    NEXT_RANK = "下一等级：%s（%s）——还差%.1f分",
    ALL_FISH_TT = "所有鱼都可以在开阔水域或鱼群中捕获；标签显示更高的几率。",
    LURE_TT = "可制作或购买的诱饵能提高钓到这种鱼的几率。",
    NOTE_STARGORGER = "需要专用鱼饵（声望奖励）——可在%s以及%s周围的普通鱼群使用。",
    NOTE_SNAKEHEAD = "无需鱼饵，但鱼饵会有很大帮助——在%s周围的鱼群和开阔水域捕获。",
    SET_SHOW_ALL = "显示所有鱼（忽略区域）", SET_HIDE_TROPHY = "隐藏奖杯等级的鱼",
    SET_ONLY_ZONES = "仅在至暗之夜钓鱼区域显示", SETTINGS = "设置", ALL_FISH = "所有鱼",
    SET_HIDE_LOGIN = "开始钓鱼前隐藏",
    SET_SCALE = "缩放",
    IMPROVED = "%s提升：%s → %s", REACHED = "——达到%s等级！",
    TROPHY_CHAT = "奖杯鱼！%s已达最高等级！", BANKED = "——已收入100分！",
    TOAST_TROPHY = "奖杯鱼上钩！",
    SCORE_MAX = "（上限%d）",
    NO_PARSE_MISMATCH = "未解析到任何鱼类——语言覆盖（%s）与游戏文本语言不匹配，请改回自动。",
    HIDDEN_SESSION = "本次会话已隐藏——/bbf 可恢复，/reload 也会恢复",
    MENU_FAILED = "设置菜单打开失败（%s）——可用 /bbf all | /bbf trophies | /bbf everywhere | /bbf lang <code|auto>",
    UNTRANSLATED = "你的客户端语言（%s）尚未翻译，鱼类数据可能无法解析。欢迎到 github.com/nerolabs/BrinyBest/issues 帮忙补充。",
    CMD_SHOWN = "已显示",
    CMD_HIDDEN = "已隐藏——/bbf 可重新显示",
    CMD_LOCKED = "位置已锁定",
    CMD_UNLOCKED = "位置已解锁——可拖动移动",
    CMD_RESET = "位置已重置",
    CMD_REFRESHING = "正在刷新",
    CMD_ALL = "显示所有鱼",
    CMD_ZONE = "显示当前区域",
    CMD_TROPHY_HIDDEN = "已隐藏奖杯等级的鱼",
    CMD_TROPHY_SHOWN = "已显示奖杯等级的鱼",
    CMD_ZONES_ONLY = "面板仅在钓鱼区域显示",
    CMD_ZONES_ALL = "面板在所有区域显示",
    CMD_FIRSTCATCH_ON = "面板在开始钓鱼前隐藏",
    CMD_FIRSTCATCH_OFF = "面板无需等待钓鱼即显示",
    SET_SHOW_VENOM = "显示盘卷女猎手毒液数量",
    VENOM_FMT = "%s：%d",
    CMD_VENOM_ON = "已显示毒液数量",
    CMD_VENOM_OFF = "已隐藏毒液数量",
    VENOM_UNEQUIPPED = "盘卷女猎手未装备",
    VENOM_MISSING = "尚未获得盘卷女猎手",
    CMD_SCALE = "缩放：%d%%",
    CMD_SCALE_HINT = "缩放：%d%%——输入 /bbf scale <50-200> 可修改",
    CMD_LANG_AUTO = "解析语言：自动（%s）",
    CMD_LANG_SET = "解析语言：%s",
    CMD_LANG_UNKNOWN = "未知语言——可用：%s",
    CMD_ZONES = "区域名称：%s",
    CMD_PARSED = "已解析%d条鱼，%d条描述仍在加载，本区域%d条",
    CMD_COMMANDS = "命令：",
    HELP = [[
/bbf              - 开关面板
/bbf lock         - 锁定位置（无法拖动）
/bbf unlock       - 解锁位置
/bbf reset        - 重置位置
/bbf refresh      - 强制刷新数据
/bbf debug        - 将本区域的解析状态输出到聊天框
设置（也可用齿轮按钮或在面板上右键打开）：
/bbf all          - 切换显示所有鱼 / 仅当前区域
/bbf trophies     - 切换是否隐藏奖杯等级的鱼
/bbf everywhere   - 切换是否在非钓鱼区域显示面板
/bbf firstcatch   - 切换是否在开始钓鱼前隐藏面板
/bbf venom       - 切换毒液数量行
/bbf scale <pct>  - 面板/提示缩放，50-200（默认100）
/bbf lang <code>  - 覆盖解析语言（如 frFR），“auto”重置
]],
  },
}
