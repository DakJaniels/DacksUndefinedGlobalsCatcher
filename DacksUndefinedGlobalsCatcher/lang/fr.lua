-- French localization for DacksUndefinedGlobalsCatcher

local strings = {
    -- Window title
    DACKS_UNDEFINED_GLOBALS_CATCHER_WINDOW_TITLE = "Variables globales non définies",

    -- Commands
    DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_TOGGLE = "Afficher/masquer la fenêtre des variables globales non définies",
    DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_LIST = "Lister toutes les variables globales ignorées",
    DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_ADD = "Ajouter une variable globale à la liste d'ignorance",
    DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_REMOVE = "Retirer une variable globale de la liste d'ignorance",
    DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_LISTFUNC = "Lister tous les motifs de fonction ignorés",
    DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_ADDFUNC = "Ajouter un motif de fonction à la liste d'ignorance",
    DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_REMOVEFUNC = "Retirer un motif de fonction de la liste d'ignorance",
    DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_HELP = "Afficher ce message d'aide",

    -- Messages
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_EMPTY_NAME = "Le nom de la variable globale ne peut pas être vide",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_ALREADY_DEFAULT = "'%s' est déjà dans la liste d'ignorance par défaut",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_ALREADY_USER = "'%s' est déjà dans votre liste d'ignorance",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_ADDED = "Ajout de '%s' à votre liste d'ignorance",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_REMOVED = "Suppression de '%s' de votre liste d'ignorance",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_NOT_FOUND = "'%s' n'a pas été trouvé dans votre liste d'ignorance",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_CANNOT_REMOVE_DEFAULT = "'%s' est dans la liste d'ignorance par défaut et ne peut pas être supprimé",

    -- Function messages
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_EMPTY_PATTERN = "Le motif de fonction ne peut pas être vide",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_PATTERN_ALREADY_DEFAULT = "'%s' est déjà dans la liste d'ignorance des fonctions par défaut",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_PATTERN_ALREADY_USER = "'%s' est déjà dans votre liste d'ignorance des fonctions",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_PATTERN_ADDED = "Ajout de '%s' à votre liste d'ignorance des fonctions",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_PATTERN_REMOVED = "Suppression de '%s' de votre liste d'ignorance des fonctions",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_PATTERN_NOT_FOUND = "'%s' n'a pas été trouvé dans votre liste d'ignorance des fonctions",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_PATTERN_CANNOT_REMOVE_DEFAULT = "'%s' est dans la liste d'ignorance des fonctions par défaut et ne peut pas être supprimé",

    -- List headers
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_DEFAULT_GLOBALS = "===== VARIABLES GLOBALES IGNORÉES PAR DÉFAUT =====",
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_DEFAULT_GLOBALS_DESC = "Celles-ci ne peuvent pas être supprimées :",
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_USER_GLOBALS = "===== VARIABLES GLOBALES IGNORÉES PAR L'UTILISATEUR =====",
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_USER_GLOBALS_DESC = "Gérez-les avec /undefs_add et /undefs_remove",
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_NO_USER_GLOBALS = "Aucune variable globale ignorée définie par l'utilisateur",

    -- Function list headers
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_DEFAULT_FUNCS = "===== MOTIFS DE FONCTION IGNORÉS PAR DÉFAUT =====",
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_DEFAULT_FUNCS_DESC = "Caux-ci ne peuvent pas être supprimés :",
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_USER_FUNCS = "===== MOTIFS DE FONCTION IGNORÉS PAR L'UTILISATEUR =====",
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_USER_FUNCS_DESC = "Gérez-les avec /undefs_addfunc et /undefs_removefunc",
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_NO_USER_FUNCS = "Aucun motif de fonction ignoré défini par l'utilisateur",

    -- Help header
    DACKS_UNDEFINED_GLOBALS_CATCHER_HELP_HEADER = "===== COMMANDES POUR LES VARIABLES GLOBALES NON DÉFINIES =====",

    -- Update messages
    DACKS_UNDEFINED_GLOBALS_CATCHER_UPDATE_IGNORE_LIST = "Liste d'ignorance mise à jour : %d entrées par défaut + %d entrées utilisateur",
    DACKS_UNDEFINED_GLOBALS_CATCHER_UPDATE_FUNC_LIST = "Liste d'ignorance des fonctions mise à jour : %d entrées par défaut + %d entrées utilisateur",

    -- Traceback formatting
    DACKS_UNDEFINED_GLOBALS_CATCHER_TRACEBACK_HEADER = "Pile d'appels :",
    DACKS_UNDEFINED_GLOBALS_CATCHER_TRACEBACK_LOCALS = "Variables locales :",
    DACKS_UNDEFINED_GLOBALS_CATCHER_TRACEBACK_TRACE = "Trace :",
}

for stringId, stringValue in pairs(strings) do
    ZO_CreateStringId(stringId, stringValue)
    SafeAddVersion(stringId, 2)
end
