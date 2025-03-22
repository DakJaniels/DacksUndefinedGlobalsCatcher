-- Spanish localization for DacksUndefinedGlobalsCatcher

local strings = {
    -- Window title
    DACKS_UNDEFINED_GLOBALS_CATCHER_WINDOW_TITLE = "Variables globales no definidas",

    -- Commands
    DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_TOGGLE = "Mostrar/ocultar la ventana de variables globales no definidas",
    DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_LIST = "Listar todas las variables globales ignoradas",
    DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_ADD = "Añadir una variable global a la lista de ignorados",
    DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_REMOVE = "Eliminar una variable global de la lista de ignorados",
    DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_LISTFUNC = "Listar todos los patrones de función ignorados",
    DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_ADDFUNC = "Añadir un patrón de función a la lista de ignorados",
    DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_REMOVEFUNC = "Eliminar un patrón de función de la lista de ignorados",
    DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_HELP = "Mostrar este mensaje de ayuda",

    -- Messages
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_EMPTY_NAME = "El nombre de la variable global no puede estar vacío",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_ALREADY_DEFAULT = "'%s' ya está en la lista de ignorados por defecto",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_ALREADY_USER = "'%s' ya está en tu lista de ignorados",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_ADDED = "Añadido '%s' a tu lista de ignorados",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_REMOVED = "Eliminado '%s' de tu lista de ignorados",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_NOT_FOUND = "'%s' no se encontró en tu lista de ignorados",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_CANNOT_REMOVE_DEFAULT = "'%s' está en la lista de ignorados por defecto y no puede ser eliminado",

    -- Function messages
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_EMPTY_PATTERN = "El patrón de función no puede estar vacío",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_PATTERN_ALREADY_DEFAULT = "'%s' ya está en la lista de patrones de función ignorados por defecto",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_PATTERN_ALREADY_USER = "'%s' ya está en tu lista de patrones de función ignorados",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_PATTERN_ADDED = "Añadido '%s' a tu lista de patrones de función ignorados",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_PATTERN_REMOVED = "Eliminado '%s' de tu lista de patrones de función ignorados",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_PATTERN_NOT_FOUND = "'%s' no se encontró en tu lista de patrones de función ignorados",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_PATTERN_CANNOT_REMOVE_DEFAULT = "'%s' está en la lista de patrones de función ignorados por defecto y no puede ser eliminado",

    -- List headers
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_DEFAULT_GLOBALS = "===== VARIABLES GLOBALES IGNORADAS POR DEFECTO =====",
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_DEFAULT_GLOBALS_DESC = "Estas no pueden ser eliminadas:",
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_USER_GLOBALS = "===== VARIABLES GLOBALES IGNORADAS POR USUARIO =====",
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_USER_GLOBALS_DESC = "Gestiona estas con /undefs_add y /undefs_remove",
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_NO_USER_GLOBALS = "No hay variables globales ignoradas definidas por usuario",

    -- Function list headers
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_DEFAULT_FUNCS = "===== PATRONES DE FUNCIÓN IGNORADOS POR DEFECTO =====",
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_DEFAULT_FUNCS_DESC = "Estos no pueden ser eliminados:",
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_USER_FUNCS = "===== PATRONES DE FUNCIÓN IGNORADOS POR USUARIO =====",
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_USER_FUNCS_DESC = "Gestiona estos con /undefs_addfunc y /undefs_removefunc",
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_NO_USER_FUNCS = "No hay patrones de función ignorados definidos por usuario",

    -- Help header
    DACKS_UNDEFINED_GLOBALS_CATCHER_HELP_HEADER = "===== COMANDOS PARA VARIABLES GLOBALES NO DEFINIDAS =====",

    -- Update messages
    DACKS_UNDEFINED_GLOBALS_CATCHER_UPDATE_IGNORE_LIST = "Lista de ignorados actualizada: %d entradas por defecto + %d entradas de usuario",
    DACKS_UNDEFINED_GLOBALS_CATCHER_UPDATE_FUNC_LIST = "Lista de patrones de función ignorados actualizada: %d entradas por defecto + %d entradas de usuario",

    -- Traceback formatting
    DACKS_UNDEFINED_GLOBALS_CATCHER_TRACEBACK_HEADER = "Pila de llamadas:",
    DACKS_UNDEFINED_GLOBALS_CATCHER_TRACEBACK_LOCALS = "Variables locales:",
    DACKS_UNDEFINED_GLOBALS_CATCHER_TRACEBACK_TRACE = "Traza:",
}

for stringId, stringValue in pairs(strings) do
    ZO_CreateStringId(stringId, stringValue)
    SafeAddVersion(stringId, 2)
end
