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
-- Auto-completion system constants
-- Defined as a local constant and used globally in multiple files.
-- https://github.com/esoui/esoui/blob/a4f33eb847c6c0ac17696bd1ce711ff922620f17/esoui/ingame/chatsystem/sharedchatsystem.lua#L95
MAX_AUTO_COMPLETION_RESULTS = 10

-- https://github.com/esoui/esoui/blob/a4f33eb847c6c0ac17696bd1ce711ff922620f17/esoui/ingame/globals/ingamedialogs.lua#L1135
AUTO_COMPLETION_ONLINE = AUTO_COMPLETION_ONLINE_ONLY

--------------------------------------------------
-- PLAYER ACTIONS
--------------------------------------------------

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
