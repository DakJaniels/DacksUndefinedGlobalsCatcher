--- Bottom ignore-list management bar.
DacksUGC = DacksUGC or {}

local IgnoreBar = ZO_Object:Subclass()
DacksUGC.IgnoreBar = IgnoreBar

function IgnoreBar:New(hostControl)
    local obj = ZO_Object.New(self)
    obj:Initialize(hostControl)
    return obj
end

function IgnoreBar:Initialize(hostControl)
    self.hostControl = hostControl
    self.currentMode = "globals"

    local Theme = DacksUGC.Theme
    local font = Theme.GetBodyFont()

    hostControl:SetAnchor(BOTTOMLEFT, hostControl:GetParent(), BOTTOMLEFT, 10, -10)
    hostControl:SetAnchor(BOTTOMRIGHT, hostControl:GetParent(), BOTTOMRIGHT, -10, -10)
    hostControl:SetHeight(40)

    local panelBg = WINDOW_MANAGER:CreateControlFromVirtual("$(parent)Bg", hostControl, "ZO_DefaultBackdrop")
    panelBg:SetAnchorFill(hostControl)
    panelBg:SetDrawTier(DT_LOW)
    Theme.ApplyBackdrop(panelBg, "surfaceAlt")

    self.modeButton = WINDOW_MANAGER:CreateControl("$(parent)ModeButton", hostControl, CT_BUTTON)
    self.modeButton:SetDimensions(28, 28)
    self.modeButton:SetAnchor(LEFT, hostControl, LEFT, 6, 0)
    self.modeButton:SetNormalTexture("EsoUI/Art/LFG/LFG_tabIcon_groupTools_up.dds")
    self.modeButton:SetPressedTexture("EsoUI/Art/LFG/LFG_tabIcon_groupTools_down.dds")
    self.modeButton:SetMouseOverTexture("EsoUI/Art/LFG/LFG_tabIcon_groupTools_over.dds")
    self.modeButton:SetHandler("OnClicked", function()
        self:ToggleMode()
    end)

    self.modeLabelButton = WINDOW_MANAGER:CreateControl("$(parent)ModeLabel", hostControl, CT_BUTTON)
    self.modeLabelButton:SetDimensions(90, Theme.controlHeight)
    self.modeLabelButton:SetAnchor(LEFT, self.modeButton, RIGHT, 4, 0)
    self.modeLabelButton:SetText(GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_MODE_GLOBALS))
    Theme.ApplyTextButton(self.modeLabelButton)
    self.modeLabelButton:SetHandler("OnClicked", function()
        self:ToggleMode()
    end)

    local editRow = WINDOW_MANAGER:CreateControl("$(parent)EditRow", hostControl, CT_CONTROL)
    editRow:SetAnchor(LEFT, self.modeLabelButton, RIGHT, 8, 0)
    editRow:SetAnchor(RIGHT, hostControl, RIGHT, -160, 0)
    editRow:SetHeight(Theme.controlHeight + 4)

    local editBackdrop = WINDOW_MANAGER:CreateControlFromVirtual("$(parent)EditBackdrop", editRow, "ZO_EditBackdrop")
    editBackdrop:SetAnchorFill(editRow)
    editBackdrop:SetMouseEnabled(true)

    self.editBox = WINDOW_MANAGER:CreateControlFromVirtual("$(parent)EditBox", editBackdrop, "ZO_DefaultEditForBackdrop")
    self.editBox:SetAnchor(TOPLEFT, editBackdrop, TOPLEFT, 4, 2)
    self.editBox:SetAnchor(BOTTOMRIGHT, editBackdrop, BOTTOMRIGHT, -4, -2)
    self.editBox:SetFont(font)
    self.editBox:SetMaxInputChars(100)
    self.editBox:SetEditEnabled(true)
    self.editBox:SetSelectAllOnFocus(true)
    self.editBox:SetHandler("OnEnter", function()
        self:AddCurrentItem()
    end)

    self.addButton = WINDOW_MANAGER:CreateControl("$(parent)Add", hostControl, CT_BUTTON)
    self.addButton:SetDimensions(72, Theme.controlHeight)
    self.addButton:SetAnchor(RIGHT, hostControl, RIGHT, -84, 0)
    self.addButton:SetText(GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_BTN_ADD))
    Theme.ApplyTextButton(self.addButton)
    self.addButton:SetHandler("OnClicked", function()
        self:AddCurrentItem()
    end)

    self.removeButton = WINDOW_MANAGER:CreateControl("$(parent)Remove", hostControl, CT_BUTTON)
    self.removeButton:SetDimensions(72, Theme.controlHeight)
    self.removeButton:SetAnchor(RIGHT, hostControl, RIGHT, -6, 0)
    self.removeButton:SetText(GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_BTN_REMOVE))
    Theme.ApplyTextButton(self.removeButton)
    self.removeButton:SetHandler("OnClicked", function()
        self:RemoveCurrentItem()
    end)
end

function IgnoreBar:SetEditText(text)
    if self.editBox then
        self.editBox:SetText(text or "")
    end
end

function IgnoreBar:GetEditText()
    return self.editBox and self.editBox:GetText() or ""
end

function IgnoreBar:ToggleMode()
    if self.currentMode == "globals" then
        self.currentMode = "functions"
        self.modeLabelButton:SetText(GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_MODE_FUNCTIONS))
    else
        self.currentMode = "globals"
        self.modeLabelButton:SetText(GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_MODE_GLOBALS))
    end
end

function IgnoreBar:AddCurrentItem()
    local text = self:GetEditText()
    if text == "" then
        if DacksUGC.displayMessage then
            DacksUGC.displayMessage(GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_EMPTY_INPUT), 1, 0, 0)
        end
        return
    end
    local success, message
    if self.currentMode == "globals" then
        success, message = DacksUGC.addGlobalToIgnoreList(text)
    else
        success, message = DacksUGC.addFunctionToIgnoreList(text)
    end
    if DacksUGC.displayMessage then
        DacksUGC.displayMessage(message, success and 0 or 1, success and 1 or 0, 0)
    end
    if success then
        self:SetEditText("")
    end
end

function IgnoreBar:RemoveCurrentItem()
    local text = self:GetEditText()
    if text == "" then
        if DacksUGC.displayMessage then
            DacksUGC.displayMessage(GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_MSG_EMPTY_INPUT), 1, 0, 0)
        end
        return
    end
    local success, message
    if self.currentMode == "globals" then
        success, message = DacksUGC.removeGlobalFromIgnoreList(text)
    else
        success, message = DacksUGC.removeFunctionFromIgnoreList(text)
    end
    if DacksUGC.displayMessage then
        DacksUGC.displayMessage(message, success and 0 or 1, success and 1 or 0, 0)
    end
    if success then
        self:SetEditText("")
    end
end
