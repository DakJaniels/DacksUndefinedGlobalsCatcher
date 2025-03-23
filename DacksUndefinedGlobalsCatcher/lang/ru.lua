-- Russian localization for DacksUndefinedGlobalsCatcher

local strings = {
    -- Window title
    DACKS_UNDEFINED_GLOBALS_CATCHER_WINDOW_TITLE = "Неопределенные глобальные переменные",

    -- Commands
    DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_TOGGLE = "Показать/скрыть окно неопределенных глобальных переменных",
    DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_LIST = "Показать список игнорируемых глобальных переменных",
    DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_ADD = "Добавить глобальную переменную в список игнорируемых",
    DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_REMOVE = "Удалить глобальную переменную из списка игнорируемых",
    DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_LISTFUNC = "Показать список игнорируемых шаблонов функций",
    DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_ADDFUNC = "Добавить шаблон функции в список игнорируемых",
    DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_REMOVEFUNC = "Удалить шаблон функции из списка игнорируемых",
    DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_HELP = "Показать это сообщение справки",

    -- Messages
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_EMPTY_NAME = "Имя глобальной переменной не может быть пустым",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_ALREADY_DEFAULT = "'%s' уже находится в стандартном списке игнорируемых",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_ALREADY_USER = "'%s' уже находится в вашем списке игнорируемых",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_ADDED = "Добавлено '%s' в список игнорируемых",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_REMOVED = "Удалено '%s' из списка игнорируемых",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_NOT_FOUND = "'%s' не найдено в списке игнорируемых",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_CANNOT_REMOVE_DEFAULT = "'%s' находится в стандартном списке игнорируемых и не может быть удалено",

    -- Function messages
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_EMPTY_PATTERN = "Шаблон функции не может быть пустым",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_PATTERN_ALREADY_DEFAULT = "'%s' уже находится в стандартном списке игнорируемых шаблонов функций",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_PATTERN_ALREADY_USER = "'%s' уже находится в вашем списке игнорируемых шаблонов функций",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_PATTERN_ADDED = "Добавлено '%s' в список игнорируемых шаблонов функций",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_PATTERN_REMOVED = "Удалено '%s' из списка игнорируемых шаблонов функций",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_PATTERN_NOT_FOUND = "'%s' не найдено в списке игнорируемых шаблонов функций",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_PATTERN_CANNOT_REMOVE_DEFAULT = "'%s' находится в стандартном списке игнорируемых шаблонов функций и не может быть удалено",

    -- List headers
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_DEFAULT_GLOBALS = "===== Стандартные игнорируемые глобальные переменные =====",
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_DEFAULT_GLOBALS_DESC = "Эти нельзя удалить:",
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_USER_GLOBALS = "===== Пользовательские игнорируемые глобальные переменные =====",
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_USER_GLOBALS_DESC = "Управляются через /undefs_add и /undefs_remove",
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_NO_USER_GLOBALS = "Нет пользовательских игнорируемых глобальных переменных",

    -- Function list headers
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_DEFAULT_FUNCS = "===== Стандартные игнорируемые шаблоны функций =====",
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_DEFAULT_FUNCS_DESC = "Эти нельзя удалить:",
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_USER_FUNCS = "===== Пользовательские игнорируемые шаблоны функций =====",
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_USER_FUNCS_DESC = "Управляются через /undefs_addfunc и /undefs_removefunc",
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_NO_USER_FUNCS = "Нет пользовательских игнорируемых шаблонов функций",

    -- Help header
    DACKS_UNDEFINED_GLOBALS_CATCHER_HELP_HEADER = "===== Команды перехватчика неопределенных глобальных переменных =====",

    -- Update messages
    DACKS_UNDEFINED_GLOBALS_CATCHER_UPDATE_IGNORE_LIST = "Список игнорируемых обновлен: %d стандартных + %d пользовательских",
    DACKS_UNDEFINED_GLOBALS_CATCHER_UPDATE_FUNC_LIST = "Список игнорируемых шаблонов функций обновлен: %d стандартных + %d пользовательских",

    -- Traceback formatting
    DACKS_UNDEFINED_GLOBALS_CATCHER_TRACEBACK_HEADER = "Стек вызовов:",
    DACKS_UNDEFINED_GLOBALS_CATCHER_TRACEBACK_LOCALS = "Локальные переменные:",
    DACKS_UNDEFINED_GLOBALS_CATCHER_TRACEBACK_TRACE = "Трассировка стека:",
}

for stringId, stringValue in pairs(strings) do
    SafeAddString(_G[stringId], stringValue, 2)
end
