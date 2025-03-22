-- English localization for DacksUndefinedGlobalsCatcher

local strings = {
    -- Window title
    DACKS_UNDEFINED_GLOBALS_CATCHER_WINDOW_TITLE = "Undefined Globals",

    -- Commands
    DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_TOGGLE = "Toggle the undefined globals window",
    DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_LIST = "List all ignored globals",
    DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_ADD = "Add a global to the ignore list",
    DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_REMOVE = "Remove a global from the ignore list",
    DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_LISTFUNC = "List all ignored function patterns",
    DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_ADDFUNC = "Add a function pattern to the ignore list",
    DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_REMOVEFUNC = "Remove a function pattern from the ignore list",
    DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_HELP = "Show this help message",

    -- Messages
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_EMPTY_NAME = "Global name cannot be empty",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_ALREADY_DEFAULT = "'%s' is already in the default ignore list",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_ALREADY_USER = "'%s' is already in your ignore list",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_ADDED = "Added '%s' to your ignore list",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_REMOVED = "Removed '%s' from your ignore list",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_NOT_FOUND = "'%s' was not found in your ignore list",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_CANNOT_REMOVE_DEFAULT = "'%s' is in the default ignore list and cannot be removed",

    -- Function messages
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_EMPTY_PATTERN = "Function pattern cannot be empty",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_PATTERN_ALREADY_DEFAULT = "'%s' is already in the default function ignore list",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_PATTERN_ALREADY_USER = "'%s' is already in your function ignore list",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_PATTERN_ADDED = "Added '%s' to your function ignore list",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_PATTERN_REMOVED = "Removed '%s' from your function ignore list",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_PATTERN_NOT_FOUND = "'%s' was not found in your function ignore list",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_PATTERN_CANNOT_REMOVE_DEFAULT = "'%s' is in the default function ignore list and cannot be removed",

    -- List headers
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_DEFAULT_GLOBALS = "===== DEFAULT IGNORED GLOBALS =====",
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_DEFAULT_GLOBALS_DESC = "These cannot be removed:",
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_USER_GLOBALS = "===== USER IGNORED GLOBALS =====",
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_USER_GLOBALS_DESC = "Manage these with /undefs_add and /undefs_remove",
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_NO_USER_GLOBALS = "No user-defined ignored globals",

    -- Function list headers
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_DEFAULT_FUNCS = "===== DEFAULT IGNORED FUNCTION PATTERNS =====",
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_DEFAULT_FUNCS_DESC = "These cannot be removed:",
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_USER_FUNCS = "===== USER IGNORED FUNCTION PATTERNS =====",
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_USER_FUNCS_DESC = "Manage these with /undefs_addfunc and /undefs_removefunc",
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_NO_USER_FUNCS = "No user-defined ignored function patterns",

    -- Help header
    DACKS_UNDEFINED_GLOBALS_CATCHER_HELP_HEADER = "===== UNDEFINED GLOBALS CATCHER COMMANDS =====",

    -- Update messages
    DACKS_UNDEFINED_GLOBALS_CATCHER_UPDATE_IGNORE_LIST = "Updated ignore list: %d default entries + %d user entries",
    DACKS_UNDEFINED_GLOBALS_CATCHER_UPDATE_FUNC_LIST = "Updated function ignore list: %d default entries + %d user entries",

    -- Traceback formatting
    DACKS_UNDEFINED_GLOBALS_CATCHER_TRACEBACK_HEADER = "Call stack:",
    DACKS_UNDEFINED_GLOBALS_CATCHER_TRACEBACK_LOCALS = "Locals:",
    DACKS_UNDEFINED_GLOBALS_CATCHER_TRACEBACK_TRACE = "Traceback:",
}

for stringId, stringValue in pairs(strings) do
    ZO_CreateStringId(stringId, stringValue)
    SafeAddVersion(stringId, 1)
end
