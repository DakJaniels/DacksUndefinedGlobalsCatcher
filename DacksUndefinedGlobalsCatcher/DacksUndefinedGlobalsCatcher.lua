local _G = _G
local myNAME = "DacksUndefinedGlobalsCatcher"
local setmetatable = setmetatable
local type = type
local pcall = pcall
local next = next
local debugTraceback = debug and debug.traceback
local table = table
local table_insert = table.insert
local table_concat = table.concat
local table_sort = table.sort
local table_remove = table.remove
local EVENT_MANAGER = _G.GetEventManager()
local ZO_GetCallstackFunctionNames = _G.ZO_GetCallstackFunctionNames
local EVENT_ADD_ON_LOADED = _G.EVENT_ADD_ON_LOADED
local SLASH_COMMANDS = _G.SLASH_COMMANDS
local ipairs = ipairs
local string = string
local string_format = string and string.format
local zo_abs = _G.zo_abs
local math = math
local math_frexp = math and math.frexp
local pairs = pairs
local tostring = tostring
local string_rep = string.rep
local LoadString = _G.LoadString
local ReloadUI = _G.ReloadUI

DacksUGC = DacksUGC or {}

-- -----------------------------------------------------------------------------
-- Forwards.
-- -----------------------------------------------------------------------------
local listIgnoredFunctions
local listIgnoredGlobals
local removeGlobalFromIgnoreList
local removeFunctionFromIgnoreList
local addGlobalToIgnoreList
local addFunctionToIgnoreList
local rebuildIgnoreFunctionLookup
local rebuildIgnoreLookup
local showHelp
local displayMessage
local isControlCreation
local shouldIgnoreGlobal
local globalmiss
local getUsableFont
local isNilOrEmpty
local prettyPrint
local formatMessage

-- -----------------------------------------------------------------------------
-- Utility Functions.
-- -----------------------------------------------------------------------------

---
--- @param font? string
--- @return string
function getUsableFont(font)
    if DacksUGC and DacksUGC.Theme then
        return DacksUGC.Theme.GetBodyFont()
    end
    if IsInGamepadPreferredMode() or IsConsoleUI() then
        return "$(GAMEPAD_MEDIUM_FONT)|$(GP_18)|soft-shadow-thick"
    end
    return "ZoFontGame"
end

--- @generic T
--- @param value T
--- @return boolean
function isNilOrEmpty(value)
    return value == nil or (type(value) == "string" and value == "")
end

-- Pretty prints a table with proper indentation and formatting
--- @param value any The value to pretty print
--- @param indent number? The current indentation level
--- @param done table? Table to track already printed tables (prevents infinite recursion)
--- @return string
function prettyPrint(value, indent, done)
    indent = indent or 0
    done = done or {}

    -- Handle non-table values
    if type(value) ~= "table" then
        if type(value) == "string" then
            return string_format("%q", value)
        end
        return tostring(value)
    end

    if done[value] then
        return "<circular reference>"
    end

    done[value] = true
    local padding = string_rep("  ", indent)
    local lines = {}

    -- Sort keys for consistent output
    local keys = {}
    for k in pairs(value) do
        table_insert(keys, k)
    end
    table_sort(keys, function (a, b)
        return tostring(a) < tostring(b)
    end)

    for _, k in ipairs(keys) do
        local v = value[k]
        local entry = padding
        if type(k) == "number" then
            entry = entry .. "[" .. k .. "]"
        else
            entry = entry .. k
        end
        entry = entry .. " = "

        if type(v) == "table" then
            if next(v) == nil then
                entry = entry .. "{}"
            else
                entry = entry .. "{\n" .. prettyPrint(v, indent + 1, done) .. "\n" .. padding .. "}"
            end
        else
            if type(v) == "string" then
                entry = entry .. string_format("%q", v)
            else
                entry = entry .. tostring(v)
            end
        end
        table_insert(lines, entry)
    end

    return table_concat(lines, "\n")
end

-- Formats the error message with proper alignment and colors
--- @param formatStr string
--- @param reportedKey number
--- @param key any
--- @param traceback string
--- @param functionNames string[]
--- @return string
function formatMessage(formatStr, reportedKey, key, traceback, functionNames)
    -- Improved header with count and key
    local header = string_format("|cFFD700%s|r", string_format(formatStr, reportedKey, key))

    -- Format the call stack with improved colors and indentation
    local callStackInfo = { "|c5C88DA" .. GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_TRACEBACK_HEADER) .. "|r" }
    for i, functionName in ipairs(functionNames) do
        -- Use different colors for different types of functions
        local color = "|cCCCCCC" -- Default gray

        -- Highlight scene-related functions in light blue
        if functionName:find("Scene") then
            color = "|c88CCFF"
            -- Highlight ZO_ functions in green
        elseif functionName:find("^ZO_") then
            color = "|c99EEBB"
            -- Highlight anonymous functions in orange
        elseif functionName:find("anonymous") then
            color = "|cFFCC99"
        end

        local safeName = EscapeMarkup(functionName, ALLOW_MARKUP_TYPE_COLOR_ONLY)
        table_insert(callStackInfo, string_format("  %2d. %s%s|r", i, color, safeName))
    end

    -- Extract locals from traceback if present
    local locals = traceback:match("<[Ll]ocals>(.+)</[Ll]ocals>")
    --- @cast locals string
    if locals then
        -- Convert common ESO boolean flags
        locals = locals:gsub("=%s*F%s*[,}]", "= false%1")
        locals = locals:gsub("=%s*T%s*[,}]", "= true%1")

        -- Handle array-style tables [table:1]
        locals = locals:gsub("%[table:(%d+)%]", "{}")

        -- Convert the locals string into a proper table format
        locals = locals:gsub("=%s*{%s*}", "= {}") -- Handle empty tables

        -- Clean up the locals string to make it valid Lua
        locals = locals:gsub("=%s*{([^}]+)}", function (content)
            -- Format table contents properly
            local cleaned = content
                :gsub("%s+", " ")                           -- Normalize whitespace
                :gsub("([%w_]+)%s*=%s*([^,}]+)", "%1 = %2") -- Fix key-value pairs
                :gsub(",%s*}", "}")                         -- Remove trailing commas
            return "= {" .. cleaned .. "}"
        end)

        -- Add quotes around string keys if needed
        locals = locals:gsub("([%w_]+)%s*=", function (keyName)
            -- Don't quote 'self' as it's a special case
            if keyName == "self" then
                return keyName .. " ="
            end
            return string_format("%q = ", keyName)
        end)

        local localsFunc, _ = LoadString("return {" .. locals .. "}", "locals")
        if localsFunc then
            local success, result = pcall(localsFunc)
            if success and type(result) == "table" then
                locals = "\n|cE6CC80" .. GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_TRACEBACK_LOCALS) .. "|r\n" .. prettyPrint(result, 1) .. "\n"
                traceback = traceback:gsub("<[Ll]ocals>.+</[Ll]ocals>", locals)
            end
        end
    end

    -- Format traceback for better readability
    traceback = traceback:gsub("stack traceback:", "|cFF6666" .. GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_TRACEBACK_TRACE) .. "|r")

    -- Colorize file paths in traceback
    traceback = traceback:gsub("([%w_/\\%.]+%.lua:%d+:)", "|cAAFFAA%1|r")

    -- Highlight 'in function' parts
    traceback = traceback:gsub("(in function%s+[%w_:'%.]+)", "|c99DDFF%1|r")

    -- Highlight 'Undefined global' message
    traceback = traceback:gsub("(|cFF0000Undefined global|r:[^%s]+)", "|cFF5555%1|r")

    -- Ensure consistent line endings and create the final message with better spacing
    local message = header .. "\n\n" .. traceback .. "\n\n" .. table_concat(callStackInfo, "\n") .. "\n"

    return (message:gsub("\r\n", "\n")) -- Normalize any Windows line endings, capture only first return value
end

--- Removes ESO color markup (|cRRGGBB and |r) for clipboard/plain display. Not EscapeMarkup (that escapes literal markup in user text).
function DacksUGC.StripColorMarkup(text)
    if not text or text == "" then
        return ""
    end
    text = text:gsub("|c%x%x%x%x%x%x", "")
    return text:gsub("|r", "")
end

-- Configuration
local CONFIG =
{
    WINDOW_WIDTH = 1000,
    WINDOW_HEIGHT = 600,
    EPSILON = 1e-6,
    MAX_REPORTS = 1000, -- Add a limit to prevent memory leaks
}

-- State management
local reported = setmetatable({},
                              {
                                  __index = function ()
                                      return 0
                                  end,
                                  __mode = "k",
                              })
local viewer = nil

-- Default ignore globals that are static - these won't be saved but always included
local defaultIgnoreGlobals =
{
    "ADCUI",
    "ActionButton1Decoration",
    "ActionButton2Decoration",
    "ActionButton3Decoration",
    "ActionButton4Decoration",
    "ActionButton5Decoration",
    "ActionButton6Decoration",
    "ActionButton7Decoration",
    "ActionButton8Decoration",
    "ActionButton9Decoration",
    "ActionButton10Decoration",
    "ActionButton11Decoration",
    "ActionButton12Decoration",
    "ActionButton13Decoration",
    "ActionButton14Decoration",
    "ActionButton15Decoration",
    "ActionButton16Decoration",
    "ActionButton17Decoration",
    "ActionButton18Decoration",
    "ActionButton19Decoration",
    "ActionButton20Decoration",
    "ActionButton21Decoration",
    "ActionButton22Decoration",
    "ActionButton23Decoration",
    "ActionButtonDecoration",
    "AddonSelectorAutoReloadUI",
    "AdvancedFilters",
    "AIGW",
    "ArkadiusTradeTools",
    "ArkadiusTradeToolsSalesData01",
    "ArkadiusTradeToolsSalesData02",
    "ArkadiusTradeToolsSalesData03",
    "ArkadiusTradeToolsSalesData04",
    "ArkadiusTradeToolsSalesData05",
    "ArkadiusTradeToolsSalesData06",
    "ArkadiusTradeToolsSalesData07",
    "ArkadiusTradeToolsSalesData08",
    "ArkadiusTradeToolsSalesData09",
    "ArkadiusTradeToolsSalesData10",
    "ArkadiusTradeToolsSalesData11",
    "ArkadiusTradeToolsSalesData12",
    "ArkadiusTradeToolsSalesData13",
    "ArkadiusTradeToolsSalesData14",
    "ArkadiusTradeToolsSalesData15",
    "ArkadiusTradeToolsSalesData16",
    "AUI_Main",
    "Azurah",
    "BUI",
    "BUI_VARS",
    "ComparativeTooltip1Divider1",
    "ComparativeTooltip1SellPrice2",
    "ComparativeTooltip2Divider1",
    "ComparativeTooltip2SellPrice2",
    "Count",
    "darkui",
    "DebugLogViewer",
    "DebugLogWindow",
    "DungeonTimer",
    "DungeonTrialReset",
    "ESOMRL",
    "EsoPL",
    "FarmingParty",
    "FCOCS",
    "FTC",
    "FTC_VARS",
    "FyrMM",
    "GameTooltipDivider1",
    "GameTooltipDivider2",
    "GridList",
    "HarvensCustomMapPinsType",
    "Harvest",
    "IIfA",
    "IIFA_GUI",
    "InventoryGridView",
    "ITTsGhostwriter",
    "Item Name",
    "ItemCooldownTrackerOptions",
    "ItemTooltipCondition",
    "ItemTooltipDivider1",
    "ItemTooltipEquippedInfo",
    "ItemTooltipSellPrice1",
    "ItemTooltipSellPrice2",
    "LibFilteredChatPanel",
    "LibHistoire_GuildHistory",
    "LibHistoire_GuildNames",
    "LibHistoire_NameDictionary",
    "LostTreasureMapTreasurePin",
    "MailLooter",
    "MasterMerchant",
    "MM00DataSavedVariables",
    "MM01DataSavedVariables",
    "MM02DataSavedVariables",
    "MM03DataSavedVariables",
    "MM04DataSavedVariables",
    "MM05DataSavedVariables",
    "MM06DataSavedVariables",
    "MM07DataSavedVariables",
    "MM08DataSavedVariables",
    "MM09DataSavedVariables",
    "MM10DataSavedVariables",
    "MM11DataSavedVariables",
    "MM12DataSavedVariables",
    "MM13DataSavedVariables",
    "MM14DataSavedVariables",
    "MM15DataSavedVariables",
    "originalBonanzaPriceValue",
    "PerfectRoll",
    "pinType_Delve_bosses",
    "pinType_Delve_bosses_done",
    "pinType_Dungeon_bosses",
    "pinType_Dungeon_bosses_done",
    "pinType_Gold_Road_Partaker",
    "pinType_Gold_Road_Partaker_done",
    "pinType_Minotaur_Tracker",
    "pinType_Minotaur_Tracker_done",
    "pinType_Skyshards",
    "pinType_Skyshards_done",
    "pinType_Lore_books",
    "pinType_Lore_books_done",
    "pinType_Treasure_Maps",
    "pinType_Treasure_Chests",
    "pinType_Unknown_POI",
    "pinType_Wine_and_Warriors",
    "POC",
    "Price",
    "SkySMapPin_unknown",
    "SkySMapPin_collected",
    "SKYS_TITLE",
    "QuickslotButton1Decoration",
    "QuickslotButton2Decoration",
    "QuickslotButton3Decoration",
    "QuickslotButton4Decoration",
    "QuickslotButton5Decoration",
    "QuickslotButton6Decoration",
    "QuickslotButton7Decoration",
    "QuickslotButton8Decoration",
    "QuickslotButton9Decoration",
    "QuickslotButton10Decoration",
    "QuickslotButton11Decoration",
    "QuickslotButton12Decoration",
    "QuickslotButton13Decoration",
    "QuickslotButton14Decoration",
    "QuickslotButton15Decoration",
    "QuickslotButton16Decoration",
    "QuickslotButton17Decoration",
    "QuickslotButton18Decoration",
    "QuickslotButton19Decoration",
    "QuickslotButton20Decoration",
    "QuickslotButton21Decoration",
    "QuickslotButton22Decoration",
    "QuickslotButton23Decoration",
    "QuickslotButtonDecoration",
    "RaidNotifier",
    "rChat",
    "Roomba",
    "RuESO_init",
    "salesCount",
    "Seller",
    "SetTrack",
    "ShoppingList",
    "TGT_SettingsHandler",
    "Time",
    "tim99_WitchesFestival",
    "TweakIt",
}

-- SavedVariables - will be populated on addon load
local SavedVars =
{
    userIgnoreGlobals = {},   -- User-defined ignore list
    userIgnoreFunctions = {}, -- User-defined function patterns to ignore
}

-- Default function patterns that are static - these won't be saved but always included
local defaultIgnoreFunctions =
{
    "CreateControl",
    "GetNamedChild",
    "CreateControlFromVirtual",
    "CreateTopLevelWindow",
    "ApplyTemplateToControl",
    "OnAddOnLoaded",
    "GetControl",
    "GetControlByName",
    "Compatibility",
    "reBuildAccountOptions",
    "InitPreviewIcon",
    "addon:InitPinSizes",
    "FCOIS.BuildAddonMenu",
    "FCOIS.CheckIfOtherAddonActive",
    "ZO_WorldMapPins_Manager:AddCustomPin",
    "lib:AddPinType",
    "OnUpdate",
    "OnHide",
    "OnShow",
    "OnInitialized",
}

-- Combined lookup table for ignored globals (will contain both default and user-defined)
local ignoreLookup = {}

-- Combined lookup table for ignored function patterns
local ignoreFunctionLookup = {}

-- Rebuild the lookup table by combining default and user-defined lists
function rebuildIgnoreLookup()
    ignoreLookup = {}

    -- Add default ignored globals
    for _, name in ipairs(defaultIgnoreGlobals) do
        ignoreLookup[name] = true
    end

    -- Add user-defined ignored globals
    if SavedVars and SavedVars.userIgnoreGlobals then
        for _, name in ipairs(SavedVars.userIgnoreGlobals) do
            ignoreLookup[name] = true
        end
    end

    local userCount = 0
    if SavedVars and SavedVars.userIgnoreGlobals then
        userCount = #SavedVars.userIgnoreGlobals
    end
    displayMessage(string_format(GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_UPDATE_IGNORE_LIST), #defaultIgnoreGlobals, userCount), 0, 1, 0)
    if viewer and viewer.RemoveIncidentsMatchingIgnoreRules then
        viewer:RemoveIncidentsMatchingIgnoreRules()
    end
end

-- Rebuild the function lookup table by combining default and user-defined lists
function rebuildIgnoreFunctionLookup()
    ignoreFunctionLookup = {}

    -- Add default ignored function patterns
    for _, pattern in ipairs(defaultIgnoreFunctions) do
        ignoreFunctionLookup[pattern] = true
    end

    -- Add user-defined ignored function patterns
    if SavedVars and SavedVars.userIgnoreFunctions then
        for _, pattern in ipairs(SavedVars.userIgnoreFunctions) do
            ignoreFunctionLookup[pattern] = true
        end
    end

    local userCount = 0
    if SavedVars and SavedVars.userIgnoreFunctions then
        userCount = #SavedVars.userIgnoreFunctions
    end
    displayMessage(string_format(GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_UPDATE_FUNC_LIST), #defaultIgnoreFunctions, userCount), 0, 1, 0)
    if viewer and viewer.RemoveIncidentsMatchingIgnoreRules then
        viewer:RemoveIncidentsMatchingIgnoreRules()
    end
end

-- Add a global to the ignore list
function addGlobalToIgnoreList(globalName)
    if not globalName or globalName == "" then
        return false, GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_EMPTY_NAME)
    end

    -- Check if it's already in the default list
    for _, name in ipairs(defaultIgnoreGlobals) do
        if name == globalName then
            return false, string_format(GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_ALREADY_DEFAULT), globalName)
        end
    end

    -- Check if it's already in the user list
    if SavedVars and SavedVars.userIgnoreGlobals then
        for _, name in ipairs(SavedVars.userIgnoreGlobals) do
            if name == globalName then
                return false, string_format(GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_ALREADY_USER), globalName)
            end
        end
    end

    -- Add it to the user list
    if SavedVars then
        table_insert(SavedVars.userIgnoreGlobals, globalName)
        rebuildIgnoreLookup()
    end

    return true, string_format(GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_ADDED), globalName)
end

-- Remove a global from the ignore list
function removeGlobalFromIgnoreList(globalName)
    if not globalName or globalName == "" then
        return false, GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_EMPTY_NAME)
    end

    -- Check if it's in the default list
    for _, name in ipairs(defaultIgnoreGlobals) do
        if name == globalName then
            return false, string_format(GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_CANNOT_REMOVE_DEFAULT), globalName)
        end
    end

    -- Check if it's in the user list
    local found = false
    if SavedVars and SavedVars.userIgnoreGlobals then
        for i, name in ipairs(SavedVars.userIgnoreGlobals) do
            if name == globalName then
                table_remove(SavedVars.userIgnoreGlobals, i)
                found = true
                break
            end
        end
    end

    if not found then
        return false, string_format(GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_NOT_FOUND), globalName)
    end

    rebuildIgnoreLookup()

    return true, string_format(GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_REMOVED), globalName)
end

local function showViewerDetailText(text)
    if not viewer then
        return
    end
    viewer:Show()
    viewer:SetDetailText(text)
end

-- List ignored globals
function listIgnoredGlobals()
    local lines =
    {
        GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_DEFAULT_GLOBALS),
        GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_DEFAULT_GLOBALS_DESC),
    }
    table_sort(defaultIgnoreGlobals)
    for _, name in ipairs(defaultIgnoreGlobals) do
        table_insert(lines, name)
    end
    table_insert(lines, GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_USER_GLOBALS))
    table_insert(lines, GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_USER_GLOBALS_DESC))
    if not SavedVars or not SavedVars.userIgnoreGlobals or #SavedVars.userIgnoreGlobals == 0 then
        table_insert(lines, GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_NO_USER_GLOBALS))
    else
        table_sort(SavedVars.userIgnoreGlobals)
        for _, name in ipairs(SavedVars.userIgnoreGlobals) do
            table_insert(lines, name)
        end
    end
    showViewerDetailText(table_concat(lines, "\n"))
end

-- List ignored function patterns
function listIgnoredFunctions()
    local lines =
    {
        GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_DEFAULT_FUNCS),
        GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_DEFAULT_FUNCS_DESC),
    }
    table_sort(defaultIgnoreFunctions)
    for _, pattern in ipairs(defaultIgnoreFunctions) do
        table_insert(lines, pattern)
    end
    table_insert(lines, GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_USER_FUNCS))
    table_insert(lines, GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_USER_FUNCS_DESC))
    if not SavedVars or not SavedVars.userIgnoreFunctions or #SavedVars.userIgnoreFunctions == 0 then
        table_insert(lines, GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_NO_USER_FUNCS))
    else
        table_sort(SavedVars.userIgnoreFunctions)
        for _, pattern in ipairs(SavedVars.userIgnoreFunctions) do
            table_insert(lines, pattern)
        end
    end
    showViewerDetailText(table_concat(lines, "\n"))
end

-- Add a function pattern to the ignore list
function addFunctionToIgnoreList(functionPattern)
    if not functionPattern or functionPattern == "" then
        return false, GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_EMPTY_PATTERN)
    end

    -- Check if it's already in the default list
    for _, pattern in ipairs(defaultIgnoreFunctions) do
        if pattern == functionPattern then
            return false, string_format(GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_PATTERN_ALREADY_DEFAULT), functionPattern)
        end
    end

    -- Check if it's already in the user list
    if SavedVars and SavedVars.userIgnoreFunctions then
        for _, pattern in ipairs(SavedVars.userIgnoreFunctions) do
            if pattern == functionPattern then
                return false, string_format(GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_PATTERN_ALREADY_USER), functionPattern)
            end
        end
    end

    -- Add it to the user list
    if SavedVars then
        table_insert(SavedVars.userIgnoreFunctions, functionPattern)
        rebuildIgnoreFunctionLookup()
    end

    return true, string_format(GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_PATTERN_ADDED), functionPattern)
end

-- Remove a function pattern from the ignore list
function removeFunctionFromIgnoreList(functionPattern)
    if not functionPattern or functionPattern == "" then
        return false, GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_EMPTY_PATTERN)
    end

    -- Check if it's in the default list
    for _, pattern in ipairs(defaultIgnoreFunctions) do
        if pattern == functionPattern then
            return false, string_format(GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_PATTERN_CANNOT_REMOVE_DEFAULT), functionPattern)
        end
    end

    -- Check if it's in the user list
    local found = false
    if SavedVars and SavedVars.userIgnoreFunctions then
        for i, pattern in ipairs(SavedVars.userIgnoreFunctions) do
            if pattern == functionPattern then
                table_remove(SavedVars.userIgnoreFunctions, i)
                found = true
                break
            end
        end
    end

    if not found then
        return false, string_format(GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_PATTERN_NOT_FOUND), functionPattern)
    end

    rebuildIgnoreFunctionLookup()

    return true, string_format(GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_PATTERN_REMOVED), functionPattern)
end

-- Show help message
function showHelp()
    local text = table_concat(
        {
            GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_HELP_HEADER),
            "/undefs - " .. GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_TOGGLE),
            "/undefs_list - " .. GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_LIST),
            "/undefs_add <name> - " .. GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_ADD),
            "/undefs_remove <name> - " .. GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_REMOVE),
            "/undefs_listfunc - " .. GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_LISTFUNC),
            "/undefs_addfunc <pattern> - " .. GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_ADDFUNC),
            "/undefs_removefunc <pattern> - " .. GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_REMOVEFUNC),
            "/undefs_help - " .. GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_HELP),
        }, "\n")
    showViewerDetailText(text)
end

-- Display feedback in chat
function displayMessage(message, r, g, b)
    CHAT_ROUTER:AddSystemMessage(message)
end

function isControlCreation(functionNames)
    for _, funcName in ipairs(functionNames) do
        -- Check against both default and user-defined patterns
        if ignoreFunctionLookup[funcName] then
            return true
        end
        for pattern in pairs(ignoreFunctionLookup) do
            if funcName:find(pattern, 1, true) then
                return true
            end
        end
    end
    return false
end

--- @param key any
--- @param functionNames string[]|nil
--- @return boolean
function shouldSkipIncident(key, functionNames)
    if isNilOrEmpty(key) then
        return false
    end
    if shouldIgnoreGlobal(key) then
        return true
    end
    local keyName = type(key) == "string" and key or tostring(key)
    if ignoreLookup[keyName] then
        return true
    end
    -- Global names listed under function ignores (e.g. via Functions mode) still suppress that global.
    if ignoreFunctionLookup[keyName] then
        return true
    end
    if functionNames and isControlCreation(functionNames) then
        return true
    end
    return false
end

function shouldIgnoreGlobal(key)
    if type(key) ~= "string" then
        return false
    end
    return key:sub(1, 3) == "ZO_" or key:sub(1, 3) == "SI_"
end

--- Handles undefined global variable access
--- @param _ any
--- @param key any
function globalmiss(_, key)
    if isNilOrEmpty(key) or reported[key] > CONFIG.MAX_REPORTS then
        return
    end

    local functionNames = ZO_GetCallstackFunctionNames(1)
    if shouldSkipIncident(key, functionNames) then
        return
    end

    reported[key] = reported[key] + 1

    -- Only report every 2^n occurrences to reduce spam
    if zo_abs(math_frexp(reported[key]) - 0.5) > CONFIG.EPSILON then
        return
    end
    if not viewer then
        return
    end

    local formatStr = type(key) == "string" and "%3dx %q" or "%3dx %s"
    local traceback = debugTraceback("|cFF0000Undefined global|r:" .. key, 2)
    local topFrame = functionNames[1] or "?"

    local detailText = formatMessage(formatStr, reported[key], key, traceback, functionNames)
    viewer:OnIncident(
        {
            key = key,
            reportCount = reported[key],
            topFrame = topFrame,
            functionNames = functionNames,
            detailText = detailText,
            detailTextPlain = DacksUGC.StripColorMarkup(detailText),
        })
end

EVENT_MANAGER:RegisterForEvent(myNAME, EVENT_ADD_ON_LOADED, function (eventCode, addOnName)
    if addOnName ~= myNAME then
        return
    end
    EVENT_MANAGER:UnregisterForEvent(myNAME, eventCode)

    -- Initialize saved variables
    DacksUndefinedGlobalsCatcherSavedVars = DacksUndefinedGlobalsCatcherSavedVars or
        {
            userIgnoreGlobals = {},
            userIgnoreFunctions = {},
        }
    SavedVars = DacksUndefinedGlobalsCatcherSavedVars

    -- Ensure the userIgnoreFunctions field exists (for backwards compatibility)
    if SavedVars.userIgnoreFunctions == nil then
        SavedVars.userIgnoreFunctions = {}
    end

    SavedVars.window = SavedVars.window or
        {
            x = 50,
            y = 50,
            width = CONFIG.WINDOW_WIDTH,
            height = CONFIG.WINDOW_HEIGHT,
            detailPaneHeight = 220,
        }

    DacksUGC.savedVars = SavedVars
    viewer = DacksUGC.IncidentViewer:New()
    DacksUGC.viewer = viewer
    DacksUGC.GetUsableFont = getUsableFont
    DacksUGC.displayMessage = displayMessage
    DacksUGC.showHelp = showHelp
    DacksUGC.addGlobalToIgnoreList = addGlobalToIgnoreList
    DacksUGC.removeGlobalFromIgnoreList = removeGlobalFromIgnoreList
    DacksUGC.addFunctionToIgnoreList = addFunctionToIgnoreList
    DacksUGC.removeFunctionFromIgnoreList = removeFunctionFromIgnoreList
    DacksUGC.shouldSkipIncident = shouldSkipIncident

    -- Build the initial lookup tables (chat-only status via displayMessage)
    rebuildIgnoreLookup()
    rebuildIgnoreFunctionLookup()

    -- -----------------------------------------------------------------------------

    if not SLASH_COMMANDS["/rl"] then
        SLASH_COMMANDS["/rl"] = function ()
            ReloadUI("ingame")
        end
    end

    -- Register slash commands
    SLASH_COMMANDS["/undefs"] = function ()
        viewer:Toggle()
    end

    SLASH_COMMANDS["/undefs_add"] = function (args)
        local success, message = addGlobalToIgnoreList(args)
        if success then
            displayMessage(message, 0, 1, 0) -- Green for success
        else
            displayMessage(message, 1, 0, 0) -- Red for error
        end
    end

    SLASH_COMMANDS["/undefs_remove"] = function (args)
        local success, message = removeGlobalFromIgnoreList(args)
        if success then
            displayMessage(message, 0, 1, 0) -- Green for success
        else
            displayMessage(message, 1, 0, 0) -- Red for error
        end
    end

    SLASH_COMMANDS["/undefs_list"] = function ()
        listIgnoredGlobals()
    end

    SLASH_COMMANDS["/undefs_addfunc"] = function (args)
        local success, message = addFunctionToIgnoreList(args)
        if success then
            displayMessage(message, 0, 1, 0) -- Green for success
        else
            displayMessage(message, 1, 0, 0) -- Red for error
        end
    end

    SLASH_COMMANDS["/undefs_removefunc"] = function (args)
        local success, message = removeFunctionFromIgnoreList(args)
        if success then
            displayMessage(message, 0, 1, 0) -- Green for success
        else
            displayMessage(message, 1, 0, 0) -- Red for error
        end
    end

    SLASH_COMMANDS["/undefs_listfunc"] = function ()
        listIgnoredFunctions()
    end

    SLASH_COMMANDS["/undefs_help"] = function ()
        showHelp()
    end

    setmetatable(_G, { __index = globalmiss })
end)
