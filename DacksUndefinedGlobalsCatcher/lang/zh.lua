-- Traditional Chinese localization for DacksUndefinedGlobalsCatcher

local strings = {
    -- Window title
    DACKS_UNDEFINED_GLOBALS_CATCHER_WINDOW_TITLE = "未定義的全域變數",

    -- Commands
    DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_TOGGLE = "顯示/隱藏未定義全域變數視窗",
    DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_LIST = "列出已忽略的全域變數",
    DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_ADD = "將全域變數加入忽略清單",
    DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_REMOVE = "從忽略清單中移除全域變數",
    DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_LISTFUNC = "列出已忽略的函數模式",
    DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_ADDFUNC = "將函數模式加入忽略清單",
    DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_REMOVEFUNC = "從忽略清單中移除函數模式",
    DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_HELP = "顯示此說明訊息",

    -- Messages
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_EMPTY_NAME = "全域變數名稱不能為空",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_ALREADY_DEFAULT = "'%s' 已在預設忽略清單中",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_ALREADY_USER = "'%s' 已在您的忽略清單中",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_ADDED = "已將 '%s' 加入忽略清單",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_REMOVED = "已從忽略清單中移除 '%s'",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_NOT_FOUND = "在忽略清單中找不到 '%s'",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_CANNOT_REMOVE_DEFAULT = "'%s' 在預設忽略清單中，無法移除",

    -- Function messages
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_EMPTY_PATTERN = "函數模式不能為空",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_PATTERN_ALREADY_DEFAULT = "'%s' 已在預設函數忽略清單中",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_PATTERN_ALREADY_USER = "'%s' 已在您的函數忽略清單中",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_PATTERN_ADDED = "已將 '%s' 加入函數忽略清單",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_PATTERN_REMOVED = "已從函數忽略清單中移除 '%s'",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_PATTERN_NOT_FOUND = "在函數忽略清單中找不到 '%s'",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_PATTERN_CANNOT_REMOVE_DEFAULT = "'%s' 在預設函數忽略清單中，無法移除",

    -- List headers
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_DEFAULT_GLOBALS = "===== 預設忽略的全域變數 =====",
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_DEFAULT_GLOBALS_DESC = "這些無法移除:",
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_USER_GLOBALS = "===== 使用者定義的忽略全域變數 =====",
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_USER_GLOBALS_DESC = "使用 /undefs_add 和 /undefs_remove 管理",
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_NO_USER_GLOBALS = "沒有使用者定義的忽略全域變數",

    -- Function list headers
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_DEFAULT_FUNCS = "===== 預設忽略的函數模式 =====",
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_DEFAULT_FUNCS_DESC = "這些無法移除:",
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_USER_FUNCS = "===== 使用者定義的忽略函數模式 =====",
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_USER_FUNCS_DESC = "使用 /undefs_addfunc 和 /undefs_removefunc 管理",
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_NO_USER_FUNCS = "沒有使用者定義的忽略函數模式",

    -- Help header
    DACKS_UNDEFINED_GLOBALS_CATCHER_HELP_HEADER = "===== 未定義全域變數捕捉器指令 =====",

    -- Update messages
    DACKS_UNDEFINED_GLOBALS_CATCHER_UPDATE_IGNORE_LIST = "已更新忽略清單: %d 個預設項目 + %d 個使用者項目",
    DACKS_UNDEFINED_GLOBALS_CATCHER_UPDATE_FUNC_LIST = "已更新函數忽略清單: %d 個預設項目 + %d 個使用者項目",

    -- Traceback formatting
    DACKS_UNDEFINED_GLOBALS_CATCHER_TRACEBACK_HEADER = "呼叫堆疊:",
    DACKS_UNDEFINED_GLOBALS_CATCHER_TRACEBACK_LOCALS = "區域變數:",
    DACKS_UNDEFINED_GLOBALS_CATCHER_TRACEBACK_TRACE = "堆疊追蹤:",
}

for stringId, stringValue in pairs(strings) do
    SafeAddString(_G[stringId], stringValue, 2)
end
