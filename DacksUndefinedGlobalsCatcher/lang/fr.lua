-- French localization for DacksUndefinedGlobalsCatcher

local strings = {
    -- Window title
    DACKS_UNDEFINED_GLOBALS_CATCHER_WINDOW_TITLE = "Variables globales non définies",

    -- Mode
    DACKS_UNDEFINED_GLOBALS_CATCHER_MODE_GLOBALS = "Globales",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MODE_FUNCTIONS = "Fonctions",

    -- Button
    DACKS_UNDEFINED_GLOBALS_CATCHER_BTN_ADD = "Ajouter",
    DACKS_UNDEFINED_GLOBALS_CATCHER_BTN_REMOVE = "Supprimer",
    DACKS_UNDEFINED_GLOBALS_CATCHER_BTN_IGNORE_GLOBAL = "Ignorer le global",
    DACKS_UNDEFINED_GLOBALS_CATCHER_BTN_IGNORE_FUNCTION = "Ignorer la fonction du haut",
    DACKS_UNDEFINED_GLOBALS_CATCHER_TOOLBAR_SEARCH = "Recherche :",
    DACKS_UNDEFINED_GLOBALS_CATCHER_TOOLBAR_SEARCH_TT = "Filtrer par nom global ou cadre de pile.",
    DACKS_UNDEFINED_GLOBALS_CATCHER_SEARCH_PLACEHOLDER = "global ou cadre...",
    DACKS_UNDEFINED_GLOBALS_CATCHER_TOOLBAR_CLEAR_TT = "Effacer tous les incidents",
    DACKS_UNDEFINED_GLOBALS_CATCHER_TOOLBAR_RESET_TT = "Réinitialiser le filtre",
    DACKS_UNDEFINED_GLOBALS_CATCHER_TOOLBAR_CLOSE_TT = "Fermer la fenêtre",
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_EMPTY = "Rien à afficher",
    DACKS_UNDEFINED_GLOBALS_CATCHER_CLEAR_DIALOG_TITLE = "Effacer les incidents",
    DACKS_UNDEFINED_GLOBALS_CATCHER_CLEAR_DIALOG_TEXT = "Supprimer tous les incidents de la liste ? Les compteurs ne sont pas réinitialisés.",
    DACKS_UNDEFINED_GLOBALS_CATCHER_ROW_COUNT_TT = "Signalé au comptage : <<1>>",
    DACKS_UNDEFINED_GLOBALS_CATCHER_ROW_GLOBAL_TT_TITLE = "Global : <<1>>",
    DACKS_UNDEFINED_GLOBALS_CATCHER_ROW_GLOBAL_TT_UNDEFINED = "Statut : non défini (nil dans _G)",
    DACKS_UNDEFINED_GLOBALS_CATCHER_ROW_GLOBAL_TT_DEFINED = "Statut : défini (<<1>>)",
    DACKS_UNDEFINED_GLOBALS_CATCHER_ROW_GLOBAL_TT_VALUE = "Valeur : <<1>>",
    DACKS_UNDEFINED_GLOBALS_CATCHER_ROW_GLOBAL_TT_KEY_TYPE = "Type de clé de recherche : <<1>>",
    DACKS_UNDEFINED_GLOBALS_CATCHER_ROW_GLOBAL_TT_FRAME = "Frame principal : <<1>>",

    -- Message
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_EMPTY_INPUT = "Veuillez d'abord saisir un nom ou un modèle.",

    -- Commands
    DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_TOGGLE = "Afficher/masquer la fenêtre des variables globales non définies",
    DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_LIST = "Lister toutes les variables globales ignorées",
    DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_ADD = "Ajouter une variable globale à la liste noire",
    DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_REMOVE = "Retirer une variable globale de la liste noire",
    DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_LISTFUNC = "Lister tous les motifs de fonction ignorés",
    DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_ADDFUNC = "Ajouter un motif de fonction à la liste noire",
    DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_REMOVEFUNC = "Retirer un motif de fonction de la liste noire",
    DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_HELP = "Afficher ce message d'aide",

    -- Messages
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_EMPTY_NAME = "Le nom de la variable globale ne peut pas être vide",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_ALREADY_DEFAULT = "'%s' est déjà dans la liste noire par défaut",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_ALREADY_USER = "'%s' est déjà dans votre liste noire",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_ADDED = "Ajout de '%s' à votre liste noire",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_REMOVED = "Suppression de '%s' de votre liste noire",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_NOT_FOUND = "'%s' n'a pas été trouvé dans votre liste noire",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_CANNOT_REMOVE_DEFAULT = "'%s' est dans la liste noire par défaut et ne peut pas être supprimé",

    -- Function messages
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_EMPTY_PATTERN = "Le motif de fonction ne peut pas être vide",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_PATTERN_ALREADY_DEFAULT = "'%s' est déjà dans la liste noire des fonctions par défaut",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_PATTERN_ALREADY_USER = "'%s' est déjà dans votre liste noire des fonctions",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_PATTERN_ADDED = "Ajout de '%s' à votre liste noire des fonctions",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_PATTERN_REMOVED = "Suppression de '%s' de votre liste noire des fonctions",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_PATTERN_NOT_FOUND = "'%s' n'a pas été trouvé dans votre liste noire des fonctions",
    DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_PATTERN_CANNOT_REMOVE_DEFAULT = "'%s' est dans la liste noire des fonctions par défaut et ne peut pas être supprimé",

    -- List headers
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_DEFAULT_GLOBALS = "===== VARIABLES GLOBALES IGNORÉES PAR DÉFAUT =====",
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_DEFAULT_GLOBALS_DESC = "Celles-ci ne peuvent pas être supprimées :",
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_USER_GLOBALS = "===== VARIABLES GLOBALES IGNORÉES PAR L'UTILISATEUR =====",
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_USER_GLOBALS_DESC = "Gérez-les avec /undefs_add et /undefs_remove",
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_NO_USER_GLOBALS = "Aucune variable globale ignorée définie par l'utilisateur",

    -- Function list headers
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_DEFAULT_FUNCS = "===== MOTIFS DE FONCTION IGNORÉS PAR DÉFAUT =====",
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_DEFAULT_FUNCS_DESC = "Ceux-ci ne peuvent pas être supprimés :",
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_USER_FUNCS = "===== MOTIFS DE FONCTION IGNORÉS PAR L'UTILISATEUR =====",
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_USER_FUNCS_DESC = "Gérez-les avec /undefs_addfunc et /undefs_removefunc",
    DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_NO_USER_FUNCS = "Aucun motif de fonction ignoré défini par l'utilisateur",

    -- Help header
    DACKS_UNDEFINED_GLOBALS_CATCHER_HELP_HEADER = "===== COMMANDES POUR LES VARIABLES GLOBALES NON DÉFINIES =====",

    -- Update messages
    DACKS_UNDEFINED_GLOBALS_CATCHER_UPDATE_IGNORE_LIST = "Liste noire mise à jour : %d entrées par défaut + %d entrées utilisateur",
    DACKS_UNDEFINED_GLOBALS_CATCHER_UPDATE_FUNC_LIST = "Liste noire des fonctions mise à jour : %d entrées par défaut + %d entrées utilisateur",

    -- Traceback formatting
    DACKS_UNDEFINED_GLOBALS_CATCHER_TRACEBACK_HEADER = "Pile d'appels :",
    DACKS_UNDEFINED_GLOBALS_CATCHER_TRACEBACK_LOCALS = "Variables locales :",
    DACKS_UNDEFINED_GLOBALS_CATCHER_TRACEBACK_TRACE = "Trace :",
}

for stringId, stringValue in pairs(strings) do
    SafeAddString(_G[stringId], stringValue, 2)
end
