-- German localization for DacksUndefinedGlobalsCatcher

local strings = {
    -- Window title
    DACKS_UNDEFINED_GLOBALS_CATCHER_WINDOW_TITLE = "Nicht definierte Globale Variablen",

    -- Commands
    DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_TOGGLE = "Fenster für nicht definierte Globals ein-/ausblenden",
    DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_LIST = "Alle ignorierten Globals auflisten",
    DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_ADD = "Global zur Ignorierliste hinzufügen",
    DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_REMOVE = "Global von der Ignorierliste entfernen",
    DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_LISTFUNC = "Alle ignorierten Funktionsmuster auflisten",
    DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_ADDFUNC = "Funktionsmuster zur Ignorierliste hinzufügen",
    DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_REMOVEFUNC = "Funktionsmuster von der Ignorierliste entfernen",
    DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_HELP = "Diese Hilfenachricht anzeigen",

    -- Messages
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_EMPTY_NAME = "Globaler Name darf nicht leer sein",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_ALREADY_DEFAULT = "'%s' ist bereits in der Standard-Ignorierliste",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_ALREADY_USER = "'%s' ist bereits in Ihrer Ignorierliste",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_ADDED = "'%s' wurde zu Ihrer Ignorierliste hinzugefügt",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_REMOVED = "'%s' wurde von Ihrer Ignorierliste entfernt",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_NOT_FOUND = "'%s' wurde nicht in Ihrer Ignorierliste gefunden",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_CANNOT_REMOVE_DEFAULT = "'%s' ist in der Standard-Ignorierliste und kann nicht entfernt werden",

    -- Function messages
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_EMPTY_PATTERN = "Funktionsmuster darf nicht leer sein",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_PATTERN_ALREADY_DEFAULT = "'%s' ist bereits in der Standard-Funktions-Ignorierliste",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_PATTERN_ALREADY_USER = "'%s' ist bereits in Ihrer Funktions-Ignorierliste",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_PATTERN_ADDED = "'%s' wurde zu Ihrer Funktions-Ignorierliste hinzugefügt",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_PATTERN_REMOVED = "'%s' wurde von Ihrer Funktions-Ignorierliste entfernt",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_PATTERN_NOT_FOUND = "'%s' wurde nicht in Ihrer Funktions-Ignorierliste gefunden",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_PATTERN_CANNOT_REMOVE_DEFAULT = "'%s' ist in der Standard-Funktions-Ignorierliste und kann nicht entfernt werden",

    -- List headers
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_DEFAULT_GLOBALS = "===== STANDARD-IGNORIERTE GLOBALS =====",
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_DEFAULT_GLOBALS_DESC = "Diese können nicht entfernt werden:",
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_USER_GLOBALS = "===== BENUTZER-IGNORIERTE GLOBALS =====",
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_USER_GLOBALS_DESC = "Verwalten Sie diese mit /undefs_add und /undefs_remove",
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_NO_USER_GLOBALS = "Keine benutzerdefinierten ignorierten Globals",

    -- Function list headers
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_DEFAULT_FUNCS = "===== STANDARD-IGNORIERTE FUNKTIONSMUSTER =====",
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_DEFAULT_FUNCS_DESC = "Diese können nicht entfernt werden:",
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_USER_FUNCS = "===== BENUTZER-IGNORIERTE FUNKTIONSMUSTER =====",
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_USER_FUNCS_DESC = "Verwalten Sie diese mit /undefs_addfunc und /undefs_removefunc",
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_NO_USER_FUNCS = "Keine benutzerdefinierten ignorierten Funktionsmuster",

    -- Help header
    DACKS_UNDEFINED_GLOBALS_CATCHER_HELP_HEADER = "===== BEFEHLE FÜR NICHT DEFINIERTE GLOBALS =====",

    -- Update messages
    DACKS_UNDEFINED_GLOBALS_CATCHER_UPDATE_IGNORE_LIST = "Ignorierliste aktualisiert: %d Standardeinträge + %d Benutzereinträge",
    DACKS_UNDEFINED_GLOBALS_CATCHER_UPDATE_FUNC_LIST = "Funktions-Ignorierliste aktualisiert: %d Standardeinträge + %d Benutzereinträge",

    -- Traceback formatting
    DACKS_UNDEFINED_GLOBALS_CATCHER_TRACEBACK_HEADER = "Aufrufstapel:",
    DACKS_UNDEFINED_GLOBALS_CATCHER_TRACEBACK_LOCALS = "Lokale Variablen:",
    DACKS_UNDEFINED_GLOBALS_CATCHER_TRACEBACK_TRACE = "Rückverfolgung:",
}

for stringId, stringValue in pairs(strings) do
    --ZO_CreateStringId(stringId, stringValue)
    --SafeAddVersion(stringId, 2)
    SafeAddString(_G[stringId], stringValue, 2)
end
