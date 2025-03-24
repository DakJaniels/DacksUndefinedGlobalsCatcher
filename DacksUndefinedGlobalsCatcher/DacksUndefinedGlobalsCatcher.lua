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
local WINDOW_MANAGER = _G.GetWindowManager()
local ANIMATION_MANAGER = _G.GetAnimationManager()

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

if not SLASH_COMMANDS["/rl"] then
    SLASH_COMMANDS["/rl"] = function()
        ReloadUI("ingame")
    end
end

getUsableFont = function(font)
    if IsInGamepadPreferredMode() or IsConsoleUI() then
        font = "$(GAMEPAD_MEDIUM_FONT)|$(GP_18)|soft-shadow-thick"
    else
        font = "$(BOLD_FONT)|$(KB_18)|soft-shadow-thin"
    end
    return font
end

-- Helper functions for showing/hiding the window
local function ShowMsgWin(win)
    if win then
        win:SetHidden(false)
    end
end

local function HideMsgWin(win)
    if win then
        win:SetHidden(true)
    end
end

-- Our message window implementation using ZO_DeferredInitializingObject
--- @class MessageWindow : ZO_DeferredInitializingObject
local MessageWindow = ZO_DeferredInitializingObject:Subclass()

-- Create a new instance of MessageWindow with provided parameters
function MessageWindow:New(name, title, width, height)
    local window = ZO_DeferredInitializingObject.New(self)
    window:Initialize(name, title, width, height)
    return window
end

function MessageWindow:Initialize(name, title, width, height)
    -- Store parameters for later use
    self.name = name
    self.title = title
    self.width = width or 1024
    self.height = height or 768
    self.messageQueue = {}

    -- Create main window with minimal setup
    self.control = WINDOW_MANAGER:CreateTopLevelWindow(name)
    self.control:SetDrawLayer(DL_CONTROLS)
    self.control:SetDrawTier(DT_HIGH)
    self.control:SetDrawLevel(42)
    self.control:SetMouseEnabled(true)
    self.control:SetMovable(true)
    self.control:SetHidden(true)
    self.control:SetClampedToScreen(true)
    self.control:SetDimensions(self.width, self.height)
    self.control:SetClampedToScreenInsets(-24, 0, 0, 0)
    self.control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 50, 50)
    local maxWidth, maxHeight = GuiRoot:GetDimensions()
    self.control:SetDimensionConstraints(200, 150, maxWidth, maxHeight)
    self.control:SetResizeHandleSize(16)

    -- Create a simple fade fragment for our window to use with ZO_DeferredInitializingObject
    ZO_DeferredInitializingObject.Initialize(self, ZO_FadeSceneFragment:New(self.control))
end

-- Required implementation for ZO_DeferredInitializingObject
function MessageWindow:OnDeferredInitialize()
    self:CreateUI()
    self:SetupHandlers()
    self:ProcessQueuedMessages()

    -- Even though ZO_DeferredInitializingObject sets self.initialized internally,
    -- we'll set it here as a safety measure for our code that checks it
    self.initialized = true
end

-- Override OnShowing to handle when the fragment is showing
function MessageWindow:OnShowing()
    -- Update UI elements when showing
    if self.buffer then
        self:AdjustSlider()
    end
end

-- Override OnHiding to handle when the fragment is hiding
function MessageWindow:OnHiding()
    -- Clean up or save state when hiding
    HideMsgWin(self)
end

-- Override OnShown when fully shown
function MessageWindow:OnShown()
    ShowMsgWin(self)
end

-- Override OnHidden when fully hidden
function MessageWindow:OnHidden()
    HideMsgWin(self)
end

-- Create all UI elements
function MessageWindow:CreateUI()
    local maxWidth, maxHeight = GuiRoot:GetDimensions()
    local font = getUsableFont()
    -- Create window background
    self.bg = WINDOW_MANAGER:CreateControl(self.name .. "Bg", self.control, CT_BACKDROP)
    self.bg:SetAnchor(TOPLEFT, self.control, TOPLEFT, -8, -6)
    self.bg:SetAnchor(BOTTOMRIGHT, self.control, BOTTOMRIGHT, 4, 4)
    self.bg:SetEdgeTexture("EsoUI/Art/ChatWindow/chatwindowbg_edge.dds", 256, 256, 32, 0)
    self.bg:SetCenterTexture("EsoUI/Art/ChatWindow/chatwindowbg_center.dds")
    self.bg:SetInsets(32, 32, -32, -32)
    self.bg:SetDimensionConstraints(200, 150, maxWidth, maxHeight)
    -- Make background completely opaque
    self.bg:SetAlpha(1.0)

    -- Create header backdrop for title bar
    self.headerBg = WINDOW_MANAGER:CreateControl(self.name .. "HeaderBg", self.control, CT_BACKDROP)
    self.headerBg:SetAnchor(TOPLEFT, self.control, TOPLEFT, 0, -5)
    self.headerBg:SetAnchor(TOPRIGHT, self.control, TOPRIGHT, 0, 40)
    self.headerBg:SetCenterColor(0.1, 0.1, 0.15, 1.0) -- Dark blue-gray color
    self.headerBg:SetEdgeColor(0.3, 0.3, 0.4, 1.0)
    self.headerBg:SetAlpha(0)

    -- Create a solid backdrop for better text contrast - completely opaque
    self.bgSolid = WINDOW_MANAGER:CreateControl(self.name .. "BgSolid", self.control, CT_BACKDROP)
    self.bgSolid:SetAnchor(TOPLEFT, self.control, TOPLEFT, 10, 40)
    self.bgSolid:SetAnchor(BOTTOMRIGHT, self.control, BOTTOMRIGHT, -10, -10)
    self.bgSolid:SetCenterColor(0.05, 0.05, 0.05, 0.85) -- Completely black with no transparency
    self.bgSolid:SetEdgeColor(0.1, 0.1, 0.2, 0.5) -- Subtle edge

    -- Create improved divider
    self.divider = WINDOW_MANAGER:CreateControl(self.name .. "Divider", self.control, CT_TEXTURE)
    self.divider:SetDimensions(4, 2)
    self.divider:SetAnchor(TOPLEFT, self.control, TOPLEFT, 10, 40)
    self.divider:SetAnchor(TOPRIGHT, self.control, TOPRIGHT, -10, 40)
    self.divider:SetTexture("EsoUI/Art/Miscellaneous/horizontalDivider.dds")
    self.divider:SetTextureCoords(0.181640625, 0.818359375, 0, 1)
    self.divider:SetColor(0.6, 0.6, 0.8, 1) -- Lighter color for better visibility

    -- Create text buffer with improved spacing
    self.buffer = WINDOW_MANAGER:CreateControl(self.name .. "Buffer", self.control, CT_TEXTBUFFER)
    self.buffer:SetFont(font)
    self.buffer:SetMaxHistoryLines(200)
    self.buffer:SetMouseEnabled(true)
    self.buffer:SetLinkEnabled(true)
    self.buffer:SetAnchor(TOPLEFT, self.control, TOPLEFT, 20, 45) -- Adjusted to be below divider
    self.buffer:SetAnchor(BOTTOMRIGHT, self.control, BOTTOMRIGHT, -35, -20)
    self.buffer:SetLineFade(0, 0)
    self.buffer:SetHandler("OnLinkMouseUp", function(self, linkText, link, button)
        ZO_LinkHandler_OnLinkMouseUp(link, button, self)
    end)
    self.buffer:SetDimensionConstraints(200 - 55, 150 - 62, maxWidth, maxHeight)

    -- Create slider with improved positioning
    self.slider = WINDOW_MANAGER:CreateControl(self.name .. "Slider", self.control, CT_SLIDER)
    self.slider:SetDimensions(15, 32)
    self.slider:SetAnchor(TOPRIGHT, self.control, TOPRIGHT, -25, 60)
    self.slider:SetAnchor(BOTTOMRIGHT, self.control, BOTTOMRIGHT, -15, -40)
    self.slider:SetMinMax(1, 1)
    self.slider:SetMouseEnabled(true)
    self.slider:SetValueStep(1)
    self.slider:SetValue(1)
    self.slider:SetHidden(true)
    self.slider:SetThumbTexture("EsoUI/Art/ChatWindow/chat_thumb.dds", "EsoUI/Art/ChatWindow/chat_thumb_disabled.dds", nil, 8, 22, nil, nil, 0.6875, nil)
    self.slider:SetBackgroundMiddleTexture("EsoUI/Art/ChatWindow/chat_scrollbar_track.dds", 0, 0, 0, 0)

    -- Create scroll buttons
    self.scrollUp = WINDOW_MANAGER:CreateControlFromVirtual(self.name .. "SliderScrollUp", self.slider, "ZO_ScrollUpButton")
    self.scrollUp:SetAnchor(BOTTOM, self.slider, TOP, -1, 0)
    self.scrollUp:SetNormalTexture("EsoUI/Art/ChatWindow/chat_scrollbar_upArrow_up.dds")
    self.scrollUp:SetPressedTexture("EsoUI/Art/ChatWindow/chat_scrollbar_upArrow_down.dds")
    self.scrollUp:SetMouseOverTexture("EsoUI/Art/ChatWindow/chat_scrollbar_upArrow_over.dds")
    self.scrollUp:SetDisabledTexture("EsoUI/Art/ChatWindow/chat_scrollbar_upArrow_disabled.dds")

    self.scrollDown = WINDOW_MANAGER:CreateControlFromVirtual(self.name .. "SliderScrollDown", self.slider, "ZO_ScrollDownButton")
    self.scrollDown:SetAnchor(TOP, self.slider, BOTTOM, -1, 0)
    self.scrollDown:SetNormalTexture("EsoUI/Art/ChatWindow/chat_scrollbar_downArrow_up.dds")
    self.scrollDown:SetPressedTexture("EsoUI/Art/ChatWindow/chat_scrollbar_downArrow_down.dds")
    self.scrollDown:SetMouseOverTexture("EsoUI/Art/ChatWindow/chat_scrollbar_downArrow_over.dds")
    self.scrollDown:SetDisabledTexture("EsoUI/Art/ChatWindow/chat_scrollbar_downArrow_disabled.dds")

    self.scrollEnd = WINDOW_MANAGER:CreateControlFromVirtual(self.name .. "SliderScrollEnd", self.slider, "ZO_ScrollEndButton")
    self.scrollEnd:SetDimensions(16, 16)
    self.scrollEnd:SetAnchor(TOP, self.scrollDown, BOTTOM, 0, 0)

    -- Create close button with improved positioning
    self.closeButton = WINDOW_MANAGER:CreateControl(self.name .. "Close", self.control, CT_BUTTON)
    self.closeButton:SetDimensions(32, 32)
    self.closeButton:SetAnchor(TOPRIGHT, self.control, TOPRIGHT, -5, 5)
    self.closeButton:SetNormalTexture("EsoUI/Art/Buttons/closebutton_up.dds")
    self.closeButton:SetPressedTexture("EsoUI/Art/Buttons/closebutton_down.dds")
    self.closeButton:SetMouseOverTexture("EsoUI/Art/Buttons/closebutton_mouseover.dds")
    self.closeButton:SetDisabledTexture("EsoUI/Art/Buttons/closebutton_disabled.dds")

    -- Add resize grip in bottom right corner
    self.resizeGrip = WINDOW_MANAGER:CreateControl(self.name .. "ResizeGrip", self.control, CT_TEXTURE)
    self.resizeGrip:SetDimensions(24, 24)
    self.resizeGrip:SetAnchor(BOTTOMRIGHT, self.control, BOTTOMRIGHT, -2, -2)
    self.resizeGrip:SetTexture("EsoUI/Art/Miscellaneous/cornerDecoration.dds")
    self.resizeGrip:SetTextureCoords(0, 1, 0, 1)
    self.resizeGrip:SetColor(0.7, 0.7, 0.9, 0.8)
    self.resizeGrip:SetDrawLevel(10) -- Make sure it's on top

    -- Create title label with improved styling
    if self.title and self.title ~= "" then
        self.label = WINDOW_MANAGER:CreateControl(self.name .. "Label", self.control, CT_LABEL)
        self.label:SetText(self.title)
        self.label:SetFont(font)
        self.label:SetColor(1, 0.9, 0.6, 1) -- Gold-ish color for title
        self.label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
        local textHeight = self.label:GetTextHeight()
        self.label:SetDimensionConstraints(200 - 60, textHeight, nil, textHeight)
        self.label:ClearAnchors()
        self.label:SetAnchor(TOPLEFT, self.control, TOPLEFT, 30, (40 - textHeight) / 2 + 5)
        self.label:SetAnchor(TOPRIGHT, self.control, TOPRIGHT, -40, (40 - textHeight) / 2 + 5)
    end

    -- Set up resize behavior to ensure text buffer adjusts correctly when resized
    self.control:SetHandler("OnResized", function()
        self:AdjustSlider()
    end)

    -- Create the panel container
    self.managePanel = WINDOW_MANAGER:CreateControl(self.name .. "ManagePanel", self.control, CT_CONTROL)
    self.managePanel:SetDimensions(self.width - 40, 36)
    self.managePanel:SetAnchor(BOTTOMLEFT, self.control, BOTTOMLEFT, 20, -20)
    self.managePanel:SetAnchor(BOTTOMRIGHT, self.control, BOTTOMRIGHT, -40, -20)

    -- Create panel backdrop
    local panelBg = WINDOW_MANAGER:CreateControl(self.name .. "ManagePanelBg", self.managePanel, CT_BACKDROP)
    panelBg:SetAnchorFill(self.managePanel)
    panelBg:SetCenterColor(0.1, 0.1, 0.15, 0.85)
    panelBg:SetEdgeColor(0.3, 0.3, 0.4, 0.5)
    panelBg:SetPixelRoundingEnabled(true)

    -- Create mode toggle button (similar to the Button in XML)
    self.modeButton = WINDOW_MANAGER:CreateControl(self.name .. "ModeButton", self.managePanel, CT_BUTTON)
    self.modeButton:SetDimensions(28, 28)
    self.modeButton:SetAnchor(LEFT, self.managePanel, LEFT, 1, 0)
    self.modeButton:SetNormalTexture("EsoUI/Art/LFG/LFG_tabIcon_groupTools_up.dds")
    self.modeButton:SetPressedTexture("EsoUI/Art/LFG/LFG_tabIcon_groupTools_down.dds")
    self.modeButton:SetMouseOverTexture("EsoUI/Art/LFG/LFG_tabIcon_groupTools_over.dds")

    -- Create mode label button (similar to ModeButton in XML)
    self.modeLabelButton = WINDOW_MANAGER:CreateControl(self.name .. "ModeLabelButton", self.managePanel, CT_BUTTON)
    self.modeLabelButton:SetDimensions(90, 20)
    self.modeLabelButton:SetAnchor(LEFT, self.modeButton, RIGHT, 4, 0)
    self.modeLabelButton:SetFont(font)
    self.modeLabelButton:SetNormalFontColor(0.9, 0.9, 0.9, 1)
    self.modeLabelButton:SetMouseOverFontColor(1, 1, 0.8, 1)
    self.modeLabelButton:SetText(GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_MODE_GLOBALS))

    -- Create button background
    local buttonBg = WINDOW_MANAGER:CreateControl(self.name .. "ButtonBg", self.managePanel, CT_TEXTURE)
    buttonBg:SetAnchor(TOPLEFT, self.managePanel, TOPLEFT, 1, 1)
    buttonBg:SetAnchor(BOTTOMRIGHT, self.modeLabelButton, BOTTOMRIGHT, 1, 0)
    buttonBg:SetColor(0.2, 0.2, 0.6, 0.2)

    -- Create action buttons container (like ComboBox but we'll use buttons)
    local actionButtonsContainer = WINDOW_MANAGER:CreateControl(self.name .. "ActionButtons", self.managePanel, CT_CONTROL)
    actionButtonsContainer:SetDimensions(180, 22)
    actionButtonsContainer:SetAnchor(RIGHT, self.managePanel, RIGHT, -4, 0)

    -- Create the help button (new addition)
    self.helpButton = WINDOW_MANAGER:CreateControl(self.name .. "HelpButton", self.managePanel, CT_BUTTON)
    self.helpButton:SetDimensions(22, 22)
    self.helpButton:SetAnchor(RIGHT, actionButtonsContainer, LEFT, -8, 0)
    self.helpButton:SetNormalTexture("EsoUI/Art/Notifications/notification_help_up.dds")
    self.helpButton:SetPressedTexture("EsoUI/Art/Notifications/notification_help_down.dds")
    self.helpButton:SetMouseOverTexture("EsoUI/Art/Notifications/notification_help_over.dds")

    -- Create the help button's backdrop for styling
    local helpButtonBg = WINDOW_MANAGER:CreateControl(self.name .. "HelpButtonBg", self.helpButton, CT_BACKDROP)
    helpButtonBg:SetAnchorFill(self.helpButton)
    helpButtonBg:SetCenterColor(0.2, 0.2, 0.5, 0.5)
    helpButtonBg:SetEdgeColor(0.4, 0.4, 0.8, 0.5)

    -- Create the add button
    self.addButton = WINDOW_MANAGER:CreateControl(self.name .. "AddButton", actionButtonsContainer, CT_BUTTON)
    self.addButton:SetDimensions(80, 22)
    self.addButton:SetAnchor(LEFT, actionButtonsContainer, LEFT, 0, 0)
    self.addButton:SetFont(font)
    self.addButton:SetNormalFontColor(0.9, 0.9, 0.9, 1)
    self.addButton:SetMouseOverFontColor(1, 1, 0.8, 1)
    self.addButton:SetText(GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_BTN_ADD))

    -- Create add button backdrop
    local addButtonBg = WINDOW_MANAGER:CreateControl(self.name .. "AddButtonBg", self.addButton, CT_BACKDROP)
    addButtonBg:SetAnchorFill(self.addButton)
    addButtonBg:SetCenterColor(0.2, 0.5, 0.2, 0.85)
    addButtonBg:SetEdgeColor(0.3, 0.7, 0.3, 0.5)

    -- Create the remove button
    self.removeButton = WINDOW_MANAGER:CreateControl(self.name .. "RemoveButton", actionButtonsContainer, CT_BUTTON)
    self.removeButton:SetDimensions(80, 22)
    self.removeButton:SetAnchor(RIGHT, actionButtonsContainer, RIGHT, 0, 0)
    self.removeButton:SetFont(font)
    self.removeButton:SetNormalFontColor(0.9, 0.9, 0.9, 1)
    self.removeButton:SetMouseOverFontColor(1, 0.8, 0.8, 1)
    self.removeButton:SetText(GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_BTN_REMOVE))

    -- Create remove button backdrop
    local removeButtonBg = WINDOW_MANAGER:CreateControl(self.name .. "RemoveButtonBg", self.removeButton, CT_BACKDROP)
    removeButtonBg:SetAnchorFill(self.removeButton)
    removeButtonBg:SetCenterColor(0.5, 0.2, 0.2, 0.85)
    removeButtonBg:SetEdgeColor(0.7, 0.3, 0.3, 0.5)

    -- Create the edit box
    self.editBox = WINDOW_MANAGER:CreateControl(self.name .. "EditBox", self.managePanel, CT_EDITBOX)
    self.editBox:SetMouseEnabled(true)
    self.editBox:SetDrawLayer(DL_CONTROLS)
    self.editBox:SetDrawTier(DT_HIGH)
    self.editBox:SetDrawLevel(42)
    self.editBox:SetFont(font)
    self.editBox:SetAnchor(LEFT, self.modeLabelButton, RIGHT, 8, 0)
    self.editBox:SetAnchor(RIGHT, actionButtonsContainer, LEFT, -40, 0)
    self.editBox:SetDimensions(0, 20) -- Width will be determined by anchors
    self.editBox:SetMaxInputChars(100)

    -- Create edit box backdrop
    local editBg = WINDOW_MANAGER:CreateControl(self.name .. "EditBg", self.editBox, CT_BACKDROP)
    editBg:SetAnchorFill(self.editBox)
    editBg:SetCenterColor(0, 0, 0, 0.5)
    editBg:SetEdgeColor(0.5, 0.5, 0.5, 0.5)

    -- Set up the edit box
    self.editBox:SetEditEnabled(true) -- Enable editing
    self.editBox:SetSelectAllOnFocus(true) -- Select all text on focus
    self.editBox:SetNewLineEnabled(false) -- Disable new lines if you want single-line input
    self.editBox:SetPasteEnabled(true) -- Allow pasting text

    -- Add event handlers for the edit box
    self.editBox:SetHandler("OnEnter", function()
        self:AddCurrentItem() -- Call the function to add the item when Enter is pressed
    end)

    self.editBox:SetHandler("OnMouseDown", function()
        if not self.editBox:HasFocus() then
            self.editBox:TakeFocus() -- Make the edit box focusable
        end
    end)

    self.editBox:SetHandler("OnFocusLost", function()
        self.editBox:LoseFocus()
    end)

    self.editBox:SetHandler("OnTextChanged", function()
        -- Handle text changes if needed
    end)

    -- Make mode selector clickable to toggle between globals and functions
    self.modeButton:SetHandler("OnClicked", function()
        self:ToggleMode()
    end)

    self.modeLabelButton:SetHandler("OnClicked", function()
        self:ToggleMode()
    end)

    self.currentMode = "globals" -- Default mode is globals

    -- Add handlers for the buttons
    self.addButton:SetHandler("OnClicked", function()
        self:AddCurrentItem()
    end)

    self.removeButton:SetHandler("OnClicked", function()
        self:RemoveCurrentItem()
    end)

    -- Add handler for the help button
    self.helpButton:SetHandler("OnClicked", function()
        showHelp()
    end)

    -- Make the buffer a bit smaller to make room for our panel
    self.buffer:ClearAnchors()
    self.buffer:SetAnchor(TOPLEFT, self.control, TOPLEFT, 20, 45)
    self.buffer:SetAnchor(BOTTOMRIGHT, self.control, BOTTOMRIGHT, -35, -60)

    -- Adjust slider too
    self.slider:ClearAnchors()
    self.slider:SetAnchor(TOPRIGHT, self.control, TOPRIGHT, -25, 60)
    self.slider:SetAnchor(BOTTOMRIGHT, self.control, BOTTOMRIGHT, -15, -60)
end

-- Toggle between globals and functions mode
function MessageWindow:ToggleMode()
    if self.currentMode == "globals" then
        self.currentMode = "functions"
        self.modeLabelButton:SetText(GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_MODE_FUNCTIONS))
    else
        self.currentMode = "globals"
        self.modeLabelButton:SetText(GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_MODE_GLOBALS))
    end
end

-- Add the current item from the edit box
function MessageWindow:AddCurrentItem()
    local text = self.editBox:GetText()
    if text and text ~= "" then
        local success, message

        if self.currentMode == "globals" then
            success, message = addGlobalToIgnoreList(text)
        else
            success, message = addFunctionToIgnoreList(text)
        end

        displayMessage(message, success and 0 or 1, success and 1 or 0, 0)

        if success then
            self.editBox:SetText("")
        end
    else
        displayMessage(GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_EMPTY_INPUT), 1, 0, 0)
    end
end

-- Remove the current item from the edit box
function MessageWindow:RemoveCurrentItem()
    local text = self.editBox:GetText()
    if text and text ~= "" then
        local success, message

        if self.currentMode == "globals" then
            success, message = removeGlobalFromIgnoreList(text)
        else
            success, message = removeFunctionFromIgnoreList(text)
        end

        displayMessage(message, success and 0 or 1, success and 1 or 0, 0)

        if success then
            self.editBox:SetText("")
        end
    else
        displayMessage(GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_EMPTY_INPUT), 1, 0, 0)
    end
end

-- Process any queued messages
function MessageWindow:ProcessQueuedMessages()
    if #self.messageQueue > 0 then
        for _, msgData in ipairs(self.messageQueue) do
            self.buffer:AddMessage(msgData.message, msgData.r, msgData.g, msgData.b, nil)
        end
        self:AdjustSlider()
        self.messageQueue = {}
    end
end

-- Set up all the event handlers
function MessageWindow:SetupHandlers()
    local buffer = self.buffer
    local slider = self.slider
    local control = self.control

    -- Mouse wheel scrolling
    buffer:SetHandler("OnMouseWheel", function(_, delta, ctrl, alt, shift)
        local offset = delta
        if shift then
            offset = offset * buffer:GetNumVisibleLines()
        elseif ctrl then
            offset = offset * buffer:GetNumHistoryLines()
        end
        buffer:SetScrollPosition(buffer:GetScrollPosition() + offset)
        slider:SetValue(slider:GetValue() - offset)
    end)

    -- Slider value changed
    slider:SetHandler("OnValueChanged", function(_, value, eventReason)
        local numHistoryLines = buffer:GetNumHistoryLines()
        if eventReason == EVENT_REASON_HARDWARE then
            buffer:SetScrollPosition(numHistoryLines - value)
        end
    end)

    -- Scroll buttons
    self.scrollUp:SetHandler("OnMouseDown", function()
        buffer:SetScrollPosition(buffer:GetScrollPosition() + 1)
        slider:SetValue(slider:GetValue() - 1)
    end)

    self.scrollDown:SetHandler("OnMouseDown", function()
        buffer:SetScrollPosition(buffer:GetScrollPosition() - 1)
        slider:SetValue(slider:GetValue() + 1)
    end)

    self.scrollEnd:SetHandler("OnMouseDown", function()
        buffer:SetScrollPosition(0)
        slider:SetValue(buffer:GetNumHistoryLines())
    end)

    -- Close button
    self.closeButton:SetHandler("OnClicked", function()
        self:SetHidden(true)
    end)
end

-- Adjust the slider based on the current buffer state
function MessageWindow:AdjustSlider()
    if not self.buffer or not self.slider then
        return
    end

    local numHistoryLines = self.buffer:GetNumHistoryLines()
    local numVisHistoryLines = self.buffer:GetNumVisibleLines()
    local sliderMin, sliderMax = self.slider:GetMinMax()
    local sliderValue = self.slider:GetValue()

    self.slider:SetMinMax(0, numHistoryLines)

    -- If the slider's at the bottom, stay at the bottom to show new text
    if sliderValue == sliderMax then
        self.slider:SetValue(numHistoryLines)
        -- If the buffer is full start moving the slider up
    elseif numHistoryLines == self.buffer:GetMaxHistoryLines() then
        self.slider:SetValue(sliderValue - 1)
    end

    -- If there are more history lines than visible lines show the slider
    if numHistoryLines > numVisHistoryLines then
        self.slider:SetHidden(false)
    else
        self.slider:SetHidden(true)
    end
end

-- Add text to the buffer
function MessageWindow:AddText(message, red, green, blue)
    -- Don't process nil messages
    if not message then
        return
    end

    -- Queue messages if we're not initialized yet
    if not self.buffer then
        table_insert(self.messageQueue, { message = message, r = red or 1, g = green or 1, b = blue or 1 })
        return
    end

    local r = red or 1
    local g = green or 1
    local b = blue or 1

    self.buffer:AddMessage(message, r, g, b, nil)
    self:AdjustSlider()
end

-- Clear the buffer
function MessageWindow:ClearText()
    if not self.buffer then
        self.messageQueue = {}
        return
    end

    self.buffer:Clear()
end

-- Set the window hidden state
function MessageWindow:SetHidden(hidden)
    -- Initialize if showing for the first time
    if not hidden then
        -- Ensure initialization has been performed
        self:PerformDeferredInitialize()
    end

    -- Directly set the control's hidden state
    if self.control then
        self.control:SetHidden(hidden)
    end
end

-- Toggle the window visibility
function MessageWindow:Toggle()
    if self.control then
        self:SetHidden(self.control:IsControlHidden() == false)
    end
end

-- Check if the window is showing
function MessageWindow:IsShowing()
    -- Use DeferredInitializingObject's IsShowing if available, otherwise check control
    if self.fragment then
        return self.fragment:IsShowing()
    else
        return self.control and not self.control:IsControlHidden()
    end
end

-- Utility functions
local function isNilOrEmpty(value)
    return value == nil or (type(value) == "string" and value == "")
end

-- Pretty prints a table with proper indentation and formatting
--- @param value any The value to pretty print
--- @param indent number? The current indentation level
--- @param done table? Table to track already printed tables (prevents infinite recursion)
--- @return string
local function prettyPrint(value, indent, done)
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
    table_sort(keys, function(a, b)
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
local function formatMessage(formatStr, reportedKey, key, traceback, functionNames)
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

        table_insert(callStackInfo, string_format("  %2d. %s%s|r", i, color, functionName))
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
        locals = locals:gsub("=%s*{([^}]+)}", function(content)
            -- Format table contents properly
            local cleaned = content
                :gsub("%s+", " ") -- Normalize whitespace
                :gsub("([%w_]+)%s*=%s*([^,}]+)", "%1 = %2") -- Fix key-value pairs
                :gsub(",%s*}", "}") -- Remove trailing commas
            return "= {" .. cleaned .. "}"
        end)

        -- Add quotes around string keys if needed
        locals = locals:gsub("([%w_]+)%s*=", function(keyName)
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

-- Configuration
local CONFIG = {
    WINDOW_WIDTH = 1000,
    WINDOW_HEIGHT = 600,
    EPSILON = 1e-6,
    MAX_REPORTS = 1000, -- Add a limit to prevent memory leaks
}

-- State management
local reported = setmetatable({}, {
    __index = function()
        return 0
    end,
})
local msgwin = nil
--- @cast msgwin MessageWindow

-- Default ignore globals that are static - these won't be saved but always included
local defaultIgnoreGlobals = {
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
local SavedVars = {
    userIgnoreGlobals = {}, -- User-defined ignore list
    userIgnoreFunctions = {}, -- User-defined function patterns to ignore
}

-- Default function patterns that are static - these won't be saved but always included
local defaultIgnoreFunctions = {
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

    -- Log the result if window is available
    if msgwin then
        local userCount = 0
        if SavedVars and SavedVars.userIgnoreGlobals then
            userCount = #SavedVars.userIgnoreGlobals
        end
        msgwin:AddText(string_format(GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_UPDATE_IGNORE_LIST), #defaultIgnoreGlobals, userCount), 0, 1, 0)
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

    -- Log the result if window is available
    if msgwin then
        local userCount = 0
        if SavedVars and SavedVars.userIgnoreFunctions then
            userCount = #SavedVars.userIgnoreFunctions
        end
        msgwin:AddText(string_format(GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_UPDATE_FUNC_LIST), #defaultIgnoreFunctions, userCount), 0, 1, 0)
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

-- List ignored globals
function listIgnoredGlobals()
    if msgwin then
        msgwin:SetHidden(false)
        msgwin:AddText(GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_DEFAULT_GLOBALS), 1, 0.8, 0)
        msgwin:AddText(GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_DEFAULT_GLOBALS_DESC), 1, 0.8, 0)

        table_sort(defaultIgnoreGlobals)
        for _, name in ipairs(defaultIgnoreGlobals) do
            msgwin:AddText(name, 0.7, 0.7, 0.7)
        end

        msgwin:AddText(GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_USER_GLOBALS), 0, 0.8, 1)
        msgwin:AddText(GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_USER_GLOBALS_DESC), 0, 0.8, 1)

        if not SavedVars or not SavedVars.userIgnoreGlobals or #SavedVars.userIgnoreGlobals == 0 then
            msgwin:AddText(GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_NO_USER_GLOBALS), 0.7, 0.7, 0.7)
        else
            table_sort(SavedVars.userIgnoreGlobals)
            for _, name in ipairs(SavedVars.userIgnoreGlobals) do
                msgwin:AddText(name, 0.7, 0.7, 0.7)
            end
        end
    end
end

-- List ignored function patterns
function listIgnoredFunctions()
    if msgwin then
        msgwin:SetHidden(false)
        msgwin:AddText(GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_DEFAULT_FUNCS), 1, 0.8, 0)
        msgwin:AddText(GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_DEFAULT_FUNCS_DESC), 1, 0.8, 0)

        table_sort(defaultIgnoreFunctions)
        for _, pattern in ipairs(defaultIgnoreFunctions) do
            msgwin:AddText(pattern, 0.7, 0.7, 0.7)
        end

        msgwin:AddText(GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_USER_FUNCS), 0, 0.8, 1)
        msgwin:AddText(GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_USER_FUNCS_DESC), 0, 0.8, 1)

        if not SavedVars or not SavedVars.userIgnoreFunctions or #SavedVars.userIgnoreFunctions == 0 then
            msgwin:AddText(GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_NO_USER_FUNCS), 0.7, 0.7, 0.7)
        else
            table_sort(SavedVars.userIgnoreFunctions)
            for _, pattern in ipairs(SavedVars.userIgnoreFunctions) do
                msgwin:AddText(pattern, 0.7, 0.7, 0.7)
            end
        end
    end
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
    if msgwin then
        msgwin:SetHidden(false)
        msgwin:AddText(GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_HELP_HEADER), 1, 1, 0)
        msgwin:AddText("/undefs - " .. GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_TOGGLE), 1, 1, 1)
        msgwin:AddText("/undefs_list - " .. GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_LIST), 1, 1, 1)
        msgwin:AddText("/undefs_add <name> - " .. GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_ADD), 1, 1, 1)
        msgwin:AddText("/undefs_remove <name> - " .. GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_REMOVE), 1, 1, 1)
        msgwin:AddText("/undefs_listfunc - " .. GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_LISTFUNC), 1, 1, 1)
        msgwin:AddText("/undefs_addfunc <pattern> - " .. GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_ADDFUNC), 1, 1, 1)
        msgwin:AddText("/undefs_removefunc <pattern> - " .. GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_REMOVEFUNC), 1, 1, 1)
        msgwin:AddText("/undefs_help - " .. GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_HELP), 1, 1, 1)
    end
end

-- Display a message both in window and in chat
function displayMessage(message, r, g, b)
    -- Add to our window if available
    if msgwin then
        msgwin:AddText(message, r, g, b)
    end

    -- Also add to chat for immediate feedback
    CHAT_ROUTER:AddSystemMessage(message)
end

function isControlCreation(functionNames)
    for _, funcName in ipairs(functionNames) do
        -- Check against both default and user-defined patterns
        if ignoreFunctionLookup[funcName] then
            return true
        end
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
    if isNilOrEmpty(key) or reported[key] > CONFIG.MAX_REPORTS or shouldIgnoreGlobal(key) or ignoreLookup[key] then
        return
    end

    local functionNames = ZO_GetCallstackFunctionNames(1)
    if isControlCreation(functionNames) then
        return
    end

    reported[key] = reported[key] + 1

    -- Only report every 2^n occurrences to reduce spam
    if zo_abs(math_frexp(reported[key]) - 0.5) > CONFIG.EPSILON then
        return
    end
    if not msgwin then
        return
    end

    local formatStr = type(key) == "string" and "%3dx %q" or "%3dx %s"
    local traceback = debugTraceback("|cFF0000Undefined global|r:" .. key, 2)

    msgwin:AddText(formatMessage(formatStr, reported[key], key, traceback, functionNames))
end

EVENT_MANAGER:RegisterForEvent(myNAME, EVENT_ADD_ON_LOADED, function(eventCode, addOnName)
    if addOnName ~= myNAME then
        return
    end
    EVENT_MANAGER:UnregisterForEvent(myNAME, eventCode)

    -- Initialize saved variables
    DacksUndefinedGlobalsCatcherSavedVars = DacksUndefinedGlobalsCatcherSavedVars or {
        userIgnoreGlobals = {},
        userIgnoreFunctions = {},
    }
    SavedVars = DacksUndefinedGlobalsCatcherSavedVars

    -- Ensure the userIgnoreFunctions field exists (for backwards compatibility)
    if SavedVars.userIgnoreFunctions == nil then
        SavedVars.userIgnoreFunctions = {}
    end

    -- Build the initial lookup tables
    rebuildIgnoreLookup()
    rebuildIgnoreFunctionLookup()

    -- Create the message window
    msgwin = MessageWindow:New("DacksUndefinedGlobalsCatcherWindow", GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_WINDOW_TITLE), CONFIG.WINDOW_WIDTH, CONFIG.WINDOW_HEIGHT)

    -- Register slash commands
    SLASH_COMMANDS["/undefs"] = function()
        msgwin:Toggle()
    end

    SLASH_COMMANDS["/undefs_add"] = function(args)
        local success, message = addGlobalToIgnoreList(args)
        if success then
            displayMessage(message, 0, 1, 0) -- Green for success
        else
            displayMessage(message, 1, 0, 0) -- Red for error
        end
    end

    SLASH_COMMANDS["/undefs_remove"] = function(args)
        local success, message = removeGlobalFromIgnoreList(args)
        if success then
            displayMessage(message, 0, 1, 0) -- Green for success
        else
            displayMessage(message, 1, 0, 0) -- Red for error
        end
    end

    SLASH_COMMANDS["/undefs_list"] = function()
        listIgnoredGlobals()
    end

    SLASH_COMMANDS["/undefs_addfunc"] = function(args)
        local success, message = addFunctionToIgnoreList(args)
        if success then
            displayMessage(message, 0, 1, 0) -- Green for success
        else
            displayMessage(message, 1, 0, 0) -- Red for error
        end
    end

    SLASH_COMMANDS["/undefs_removefunc"] = function(args)
        local success, message = removeFunctionFromIgnoreList(args)
        if success then
            displayMessage(message, 0, 1, 0) -- Green for success
        else
            displayMessage(message, 1, 0, 0) -- Red for error
        end
    end

    SLASH_COMMANDS["/undefs_listfunc"] = function()
        listIgnoredFunctions()
    end

    SLASH_COMMANDS["/undefs_help"] = function()
        showHelp()
    end

    setmetatable(_G, { __index = globalmiss })
end)
