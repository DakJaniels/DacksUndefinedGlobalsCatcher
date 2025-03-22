-- Japanese localization for DacksUndefinedGlobalsCatcher

local strings = {
    -- Window title
    DACKS_UNDEFINED_GLOBALS_CATCHER_WINDOW_TITLE = "未定義のグローバル変数",

    -- Commands
    DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_TOGGLE = "未定義のグローバル変数ウィンドウを表示/非表示",
    DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_LIST = "無視されたグローバル変数を一覧表示",
    DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_ADD = "グローバル変数を無視リストに追加",
    DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_REMOVE = "グローバル変数を無視リストから削除",
    DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_LISTFUNC = "無視された関数パターンを一覧表示",
    DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_ADDFUNC = "関数パターンを無視リストに追加",
    DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_REMOVEFUNC = "関数パターンを無視リストから削除",
    DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_HELP = "このヘルプメッセージを表示",

    -- Messages
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_EMPTY_NAME = "グローバル変数名を空にすることはできません",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_ALREADY_DEFAULT = "'%s' は既にデフォルトの無視リストにあります",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_ALREADY_USER = "'%s' は既にあなたの無視リストにあります",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_ADDED = "'%s' を無視リストに追加しました",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_REMOVED = "'%s' を無視リストから削除しました",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_NOT_FOUND = "'%s' は無視リストに見つかりませんでした",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_CANNOT_REMOVE_DEFAULT = "'%s' はデフォルトの無視リストにあり、削除できません",

    -- Function messages
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_EMPTY_PATTERN = "関数パターンを空にすることはできません",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_PATTERN_ALREADY_DEFAULT = "'%s' は既にデフォルトの関数無視リストにあります",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_PATTERN_ALREADY_USER = "'%s' は既にあなたの関数無視リストにあります",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_PATTERN_ADDED = "'%s' を関数無視リストに追加しました",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_PATTERN_REMOVED = "'%s' を関数無視リストから削除しました",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_PATTERN_NOT_FOUND = "'%s' は関数無視リストに見つかりませんでした",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_PATTERN_CANNOT_REMOVE_DEFAULT = "'%s' はデフォルトの関数無視リストにあり、削除できません",

    -- List headers
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_DEFAULT_GLOBALS = "===== デフォルトの無視グローバル変数 =====",
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_DEFAULT_GLOBALS_DESC = "これらは削除できません:",
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_USER_GLOBALS = "===== ユーザー定義の無視グローバル変数 =====",
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_USER_GLOBALS_DESC = "/undefs_add と /undefs_remove で管理",
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_NO_USER_GLOBALS = "ユーザー定義の無視グローバル変数はありません",

    -- Function list headers
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_DEFAULT_FUNCS = "===== デフォルトの無視関数パターン =====",
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_DEFAULT_FUNCS_DESC = "これらは削除できません:",
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_USER_FUNCS = "===== ユーザー定義の無視関数パターン =====",
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_USER_FUNCS_DESC = "/undefs_addfunc と /undefs_removefunc で管理",
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_NO_USER_FUNCS = "ユーザー定義の無視関数パターンはありません",

    -- Help header
    DACKS_UNDEFINED_GLOBALS_CATCHER_HELP_HEADER = "===== 未定義グローバル変数キャッチャーのコマンド =====",

    -- Update messages
    DACKS_UNDEFINED_GLOBALS_CATCHER_UPDATE_IGNORE_LIST = "無視リストを更新: %d デフォルトエントリ + %d ユーザーエントリ",
    DACKS_UNDEFINED_GLOBALS_CATCHER_UPDATE_FUNC_LIST = "関数無視リストを更新: %d デフォルトエントリ + %d ユーザーエントリ",

    -- Traceback formatting
    DACKS_UNDEFINED_GLOBALS_CATCHER_TRACEBACK_HEADER = "コールスタック:",
    DACKS_UNDEFINED_GLOBALS_CATCHER_TRACEBACK_LOCALS = "ローカル変数:",
    DACKS_UNDEFINED_GLOBALS_CATCHER_TRACEBACK_TRACE = "スタックトレース:",
}

for stringId, stringValue in pairs(strings) do
    ZO_CreateStringId(stringId, stringValue)
    SafeAddVersion(stringId, 2)
end
