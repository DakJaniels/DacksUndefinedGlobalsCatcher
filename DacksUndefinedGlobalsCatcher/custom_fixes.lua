---@diagnostic disable: lowercase-global, duplicate-set-field, undefined-global

--[[
    DacksUndefinedGlobalsCatcher - Custom Fixes
    
    This file contains temporary fixes for undefined globals in the ESO UI.
    
    HOW IT WORKS:
    - This prevents "attempt to index nil value" errors for known missing globals
    - Each fix should include the original error context as a comment if known
    
    HOW TO ADD FIXES:
    1. Add the undefined global with its proper value (or a reasonable default)
    2. Include a comment about where/why it's needed
    3. If possible, group related fixes together
    4. Include github links to the original code
]]
--

--------------------------------------------------
-- CONFIGURATION SETTINGS
--------------------------------------------------
-- https://github.com/esoui/esoui/blob/a4f33eb847c6c0ac17696bd1ce711ff922620f17/esoui/publicallingames/rewards/rewards_manager.lua#L361
-- https://github.com/esoui/esoui/blob/a4f33eb847c6c0ac17696bd1ce711ff922620f17/esoui/publicallingames/rewards/rewards_manager.lua#L437
-- https://github.com/esoui/esoui/blob/a4f33eb847c6c0ac17696bd1ce711ff922620f17/esoui/publicallingames/rewards/rewards_manager.lua#L458
USE_LOWERCASE_NUMBER_SUFFIXES = false

--------------------------------------------------
-- HOUSING PERMISSIONS
--------------------------------------------------
-- TO BE REMOVED AFTER UPDATE 46 (confirmed fix coming from ZOS Dev SethL)
-- https://github.com/esoui/esoui/blob/a4f33eb847c6c0ac17696bd1ce711ff922620f17/esoui/ingame/housingeditor/housingeditorhud.lua#L284
HPOC_GENERAL = HOUSE_PERMISSION_SETTING_USE_INTERACTABLE_FIXTURES or 3

--------------------------------------------------
-- CRAFTING AND ITEM SYSTEM
--------------------------------------------------

-- https://github.com/esoui/esoui/blob/a4f33eb847c6c0ac17696bd1ce711ff922620f17/esoui/ingame/inventory/sharedinventory.lua#L245
CURT_IMPERIAL_FRAGMENT = CURT_IMPERIAL_FRAGMENTS or 13

--------------------------------------------------
-- UI AND AUTO-COMPLETION
--------------------------------------------------

do
    -- https://github.com/esoui/esoui/blob/a4f33eb847c6c0ac17696bd1ce711ff922620f17/esoui/ingame/globals/autocomplete.lua#L40
    -- these are called as globals but should be localized just like they are in
    -- https://github.com/esoui/esoui/blob/a4f33eb847c6c0ac17696bd1ce711ff922620f17/esoui/publicallingames/globals/autocomplete.lua
    -- and set in the initialization function of the file.
    g_currentPlayerName = GetUnitName("player")
    g_currentPlayerUserId = GetDisplayName()
end

-- Auto-completion system constants
-- Defined as a local constant and used globally in multiple files.
-- https://github.com/esoui/esoui/blob/a4f33eb847c6c0ac17696bd1ce711ff922620f17/esoui/ingame/chatsystem/sharedchatsystem.lua#L95
MAX_AUTO_COMPLETION_RESULTS = 10

-- https://github.com/esoui/esoui/blob/a4f33eb847c6c0ac17696bd1ce711ff922620f17/esoui/ingame/globals/ingamedialogs.lua#L1135
AUTO_COMPLETION_ONLINE = AUTO_COMPLETION_ONLINE_ONLY

PULSES = true

NOT_SUMMARY = false

NO_DISABLED_COLOR = ZO_ACHIEVEMENT_DISABLED_COLOR

-- https://github.com/esoui/esoui/blob/a4f33eb847c6c0ac17696bd1ce711ff922620f17/esoui/ingame/globals/ingamedialogs.lua#L1185
-- https://github.com/esoui/esoui/blob/a4f33eb847c6c0ac17696bd1ce711ff922620f17/esoui/ingame/group/grouputils.lua#L19
-- https://github.com/esoui/esoui/blob/a4f33eb847c6c0ac17696bd1ce711ff922620f17/esoui/ingame/restyle/gamepad/outfit_slots_panel_gamepad.lua#L502
-- https://github.com/esoui/esoui/blob/a4f33eb847c6c0ac17696bd1ce711ff922620f17/esoui/ingame/restyle/gamepad/restylestation_gamepad.lua#L1281
ALERT = UI_ALERT_CATEGORY_ALERT
--------------------------------------------------
-- PLAYER ACTIONS
--------------------------------------------------
TUTORIAL_TRIGGER_MOUNT_SET = TUTORIAL_TRIGGER_MOUNTED
-- https://github.com/esoui/esoui/blob/a4f33eb847c6c0ac17696bd1ce711ff922620f17/esoui/ingame/globals/ingamedialogs.lua#L1964
LOGOUT_RESULT_DEFERRED = LOGOUT_RESULT_DEFER

--------------------------------------------------
-- CAMERA AND VIEWPORT SETTINGS
--------------------------------------------------
-- Champion system camera position constants
-- These are set based on the current input mode (gamepad/keyboard)
-- https://github.com/esoui/esoui/blob/a4f33eb847c6c0ac17696bd1ce711ff922620f17/esoui/ingame/champion/champion.lua#L995
if IsInGamepadPreferredMode() then
    ZOOMED_IN_CAMERA_Y = ZO_CHAMPION_GAMEPAD_ZOOMED_IN_CAMERA_Y
    ZOOMED_IN_CAMERA_Z = ZO_CHAMPION_GAMEPAD_ZOOMED_IN_CAMERA_Z
else
    ZOOMED_IN_CAMERA_Y = ZO_CHAMPION_KEYBOARD_ZOOMED_IN_CAMERA_Y
    ZOOMED_IN_CAMERA_Z = ZO_CHAMPION_KEYBOARD_ZOOMED_IN_CAMERA_Z
end

-- Method overrides.

do
    local g_loggingEnabled = false
    -- ??? Not sure how ZOS can handle this being called.
    -- Maybe they could wrap this in a IsInternalBuild call before accessing?
    -- Maybe they could expose the g_loggingEnabled to a CVar that addon devs could use to toggle?
    -- These are neat to rewrite using d or CHAT_ROUTER:AddSystemMessage to log to the chat window if anyone does happen to read this comment.
    function ZO_Scene:Log(message)
        if IsInternalBuild() and g_loggingEnabled and WriteToInterfaceLog then
            WriteToInterfaceLog(string.format("%s - %s - %s", ZO_Scene_GetOriginColor():Colorize(GetString("SI_SCENEMANAGERMESSAGEORIGIN", ZO_REMOTE_SCENE_CHANGE_ORIGIN)), self.name, message))
        end
    end
    function ZO_SceneManager_Follower:Log(message, sceneName)
        if IsInternalBuild() and g_loggingEnabled and WriteToInterfaceLog then
            if sceneName then
                WriteToInterfaceLog(string.format("%s - %s - %s", ZO_Scene_GetOriginColor():Colorize(GetString("SI_SCENEMANAGERMESSAGEORIGIN", ZO_REMOTE_SCENE_CHANGE_ORIGIN)), message, sceneName))
            else
                WriteToInterfaceLog(string.format("%s - %s", ZO_Scene_GetOriginColor():Colorize(GetString("SI_SCENEMANAGERMESSAGEORIGIN", ZO_REMOTE_SCENE_CHANGE_ORIGIN)), message))
            end
        end
    end
end

do
    -- This method calls NOTIFICATION_ICONS_CONSOLE, that object is only created on console, so wrap it in a IsConsoleUI check.
    function ZO_GamepadNotificationManager:OnNumNotificationsChanged(totalNumNotifications)
        MAIN_MENU_GAMEPAD:OnNumNotificationsChanged(totalNumNotifications)
        KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybindStripDescriptor)

        if IsConsoleUI() then
            if NOTIFICATION_ICONS_CONSOLE then
                NOTIFICATION_ICONS_CONSOLE:OnNumNotificationsChanged(totalNumNotifications)
            end
        end
    end
end
do
    --- not sure what BRACKET_COMMANDS, ZO_REGIONCOMMANDS, or ZO_CLIENTCOMMANDS are but we are gonna wrap them in a IsInternalBuild check as that looks like ZOS internal code.
    function SlashCommandAutoComplete:GetAutoCompletionResults(text)
        if #text < 3 then
            return
        end
        local startChar = text:sub(1, 1)
        if startChar ~= "/" and startChar ~= "]" then
            return
        end
        if text:find(" ", 1, true) then
            return
        end

        if next(self.possibleMatches) == nil then
            for command in pairs(SLASH_COMMANDS) do
                if #command > 0 then
                    self.possibleMatches[command:lower()] = command
                end
            end

            if IsInternalBuild() then
                if BRACKET_COMMANDS then
                    for command in pairs(BRACKET_COMMANDS) do
                        if #command > 0 then
                            self.possibleMatches[command:lower()] = command
                        end
                    end
                end

                self:AddCommandsToPossibleResults(ZO_REGIONCOMMANDS)
                self:AddCommandsToPossibleResults(ZO_CLIENTCOMMANDS)
            end

            local switchLookup = ZO_ChatSystem_GetChannelSwitchLookupTable()
            for channelId, switchString in ipairs(switchLookup) do
                self.possibleMatches[switchString:lower()] = switchString
            end
        end

        local results = GetTopMatchesByLevenshteinSubStringScore(self.possibleMatches, text, 2, self.maxResults)
        if results then
            return unpack(results)
        end
        return nil
    end
end
