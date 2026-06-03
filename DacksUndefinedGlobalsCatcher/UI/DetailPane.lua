--- Detail text for a selected undefined-global incident (read-only, selectable, copyable).
DacksUGC = DacksUGC or {}

local DetailPane = ZO_Object:Subclass()
DacksUGC.DetailPane = DetailPane

local DETAIL_EDIT_MAX_CHARS = 50000

function DetailPane:New(hostControl)
    local obj = ZO_Object.New(self)
    obj:Initialize(hostControl)
    return obj
end

function DetailPane:Initialize(hostControl)
    self.hostControl = hostControl
    self.currentIncident = nil
    self.detailTextMarked = nil
    self.detailTextPlain = nil
    self.detailShowingPlain = false
    self.detailUserCopyMode = false
    self.detailSavedTopLine = 1
    self.detailSavedCursor = 0

    local Theme = DacksUGC.Theme
    local font = Theme.GetDetailFont()

    local actionBar = WINDOW_MANAGER:CreateControl("$(parent)Actions", hostControl, CT_CONTROL)
    actionBar:SetAnchor(TOPLEFT, hostControl, TOPLEFT, 0, 0)
    actionBar:SetAnchor(TOPRIGHT, hostControl, TOPRIGHT, 0, 0)
    actionBar:SetHeight(Theme.controlHeight)
    self.actionBar = actionBar

    self.ignoreGlobalButton = WINDOW_MANAGER:CreateControl("$(parent)IgnoreGlobal", actionBar, CT_BUTTON)
    self.ignoreGlobalButton:SetDimensions(120, Theme.controlHeight)
    self.ignoreGlobalButton:SetAnchor(LEFT, actionBar, LEFT, 0, 0)
    self.ignoreGlobalButton:SetText(GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_BTN_IGNORE_GLOBAL))
    Theme.ApplyTextButton(self.ignoreGlobalButton)
    self.ignoreGlobalButton:SetHandler("OnClicked", function()
        self:IgnoreGlobal()
    end)

    self.ignoreFunctionButton = WINDOW_MANAGER:CreateControl("$(parent)IgnoreFunction", actionBar, CT_BUTTON)
    self.ignoreFunctionButton:SetDimensions(140, Theme.controlHeight)
    self.ignoreFunctionButton:SetAnchor(LEFT, self.ignoreGlobalButton, RIGHT, 12, 0)
    self.ignoreFunctionButton:SetText(GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_BTN_IGNORE_FUNCTION))
    Theme.ApplyTextButton(self.ignoreFunctionButton)
    self.ignoreFunctionButton:SetHandler("OnClicked", function()
        self:IgnoreTopFunction()
    end)

    self.copyDetailButton = WINDOW_MANAGER:CreateControl("$(parent)CopyDetail", actionBar, CT_BUTTON)
    self.copyDetailButton:SetDimensions(72, Theme.controlHeight)
    self.copyDetailButton:SetAnchor(RIGHT, actionBar, RIGHT, 0, 0)
    self.copyDetailButton:SetText(GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_BTN_COPY_DETAIL))
    self.copyDetailButton.tooltipText = GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_BTN_COPY_DETAIL_TT)
    Theme.ApplyTextButton(self.copyDetailButton)
    self.copyDetailButton:SetHandler("OnClicked", function()
        self:CopyPlainDetailToClipboard()
    end)

    local bufferBg = WINDOW_MANAGER:CreateControlFromVirtual("$(parent)BufferBg", hostControl, "ZO_DefaultBackdrop")
    bufferBg:SetAnchor(TOPLEFT, actionBar, BOTTOMLEFT, 0, 4)
    bufferBg:SetAnchor(BOTTOMRIGHT, hostControl, BOTTOMRIGHT, 0, 0)
    bufferBg:SetDrawTier(DT_LOW)
    Theme.ApplyBackdrop(bufferBg, "surface")
    self.bufferBg = bufferBg

    local editHost = WINDOW_MANAGER:CreateControl("$(parent)EditHost", bufferBg, CT_CONTROL)
    editHost:SetAnchorFill(bufferBg)
    self.editHost = editHost

    -- ZO_DefaultEditMultiLineForBackdrop: multiline, scroll via mouse wheel (see EditBoxTemplates_Keyboard.xml).
    self.detailEdit = WINDOW_MANAGER:CreateControlFromVirtual("$(parent)DetailEdit", editHost, "ZO_DefaultEditMultiLineForBackdrop")
    self.detailEdit:ClearAnchors()
    self.detailEdit:SetAnchor(TOPLEFT, editHost, TOPLEFT, 4, 4)
    self.detailEdit:SetAnchor(BOTTOMRIGHT, editHost, BOTTOMRIGHT, -4, -4)
    self.detailEdit:SetFont(font)
    self.detailEdit:SetMaxInputChars(DETAIL_EDIT_MAX_CHARS)
    self.detailEdit:SetAllowMarkupType(ALLOW_MARKUP_TYPE_COLOR_ONLY)
    self.detailEdit:SetCopyEnabled(true)
    self.detailEdit:SetPasteEnabled(false)
    self.detailEdit:SetEditEnabled(false)
    self.detailEdit:SetSelectAllOnFocus(false)
    self.detailEdit:SetHandler("OnMouseDown", function(control)
        control:TakeFocus()
    end)
    self.detailEdit:SetHandler("OnFocusLost", function()
        self:RestoreMarkedDetailView()
    end)
    editHost:SetHandler("OnUpdate", function()
        self:UpdateDetailTextForCopyChord()
    end)

    self:Clear()
end

function DetailPane:RestoreMarkedDetailView()
    local edit = self.detailEdit
    if not edit or not self.detailTextMarked then
        self.detailShowingPlain = false
        self.detailUserCopyMode = false
        return
    end
    if not self.detailShowingPlain and not self.detailUserCopyMode then
        return
    end
    self.detailShowingPlain = false
    self.detailUserCopyMode = false
    edit:SetText(self.detailTextMarked, true)
    edit:SetTopLineIndex(self.detailSavedTopLine or 1)
    edit:SetCursorPosition(self.detailSavedCursor or 0)
end

function DetailPane:UpdateDetailTextForCopyChord()
    if self.detailUserCopyMode then
        return
    end
    local edit = self.detailEdit
    if not edit or not self.detailTextMarked or self.detailTextMarked == "" then
        return
    end
    local wantPlain = IsControlKeyDown() and edit:HasFocus()
    if wantPlain and not self.detailShowingPlain then
        self.detailShowingPlain = true
        self.detailSavedTopLine = edit:GetTopLineIndex()
        self.detailSavedCursor = edit:GetCursorPosition()
        edit:SetText(self.detailTextPlain or "", true)
    elseif not wantPlain and self.detailShowingPlain then
        self:RestoreMarkedDetailView()
    end
end

--- Plain text in the edit + SelectAll; user presses Ctrl+C (client copy, no private clipboard APIs).
function DetailPane:CopyPlainDetailToClipboard()
    local edit = self.detailEdit
    local plain = self.detailTextPlain
    if not edit or not plain or plain == "" or not self.detailTextMarked or self.detailTextMarked == "" then
        return
    end
    self.detailUserCopyMode = true
    self.detailShowingPlain = true
    self.detailSavedTopLine = edit:GetTopLineIndex()
    self.detailSavedCursor = edit:GetCursorPosition()
    edit:SetText(plain, true)
    edit:SelectAll()
    edit:TakeFocus()
end

function DetailPane:Clear()
    self.currentIncident = nil
    self.detailTextMarked = nil
    self.detailTextPlain = nil
    self.detailShowingPlain = false
    self.detailUserCopyMode = false
    if self.detailEdit then
        self.detailEdit:SetText("")
        self.detailEdit:SetTopLineIndex(1)
    end
end

function DetailPane:SetIncident(incident)
    self.currentIncident = incident
    self.detailShowingPlain = false
    if not self.detailEdit then
        return
    end
    local marked = (incident and incident.detailText) or ""
    local plain = incident and incident.detailTextPlain
    if (not plain or plain == "") and marked ~= "" and DacksUGC.StripColorMarkup then
        plain = DacksUGC.StripColorMarkup(marked)
    end
    self.detailTextMarked = marked
    self.detailTextPlain = plain or ""
    self.detailEdit:SetText(marked)
    self.detailEdit:SetTopLineIndex(1)
    self.detailEdit:SetCursorPosition(0)
end

function DetailPane:GetIncident()
    return self.currentIncident
end

function DetailPane:IgnoreGlobal()
    local incident = self.currentIncident
    if not incident or not DacksUGC.addGlobalToIgnoreList then
        return
    end
    local key = incident.key
    if type(key) ~= "string" then
        key = tostring(key)
    end
    local success, message = DacksUGC.addGlobalToIgnoreList(key)
    if DacksUGC.displayMessage then
        DacksUGC.displayMessage(message, success and 0 or 1, success and 1 or 0, 0)
    end
end

function DetailPane:IgnoreTopFunction()
    local incident = self.currentIncident
    if not incident or not incident.topFrame or incident.topFrame == "" or incident.topFrame == "?" then
        return
    end
    if not DacksUGC.addFunctionToIgnoreList then
        return
    end
    local success, message = DacksUGC.addFunctionToIgnoreList(incident.topFrame)
    if DacksUGC.displayMessage then
        DacksUGC.displayMessage(message, success and 0 or 1, success and 1 or 0, 0)
    end
end

function DetailPane:PrefillIgnoreEdit(text)
    if DacksUGC.ignoreBar and DacksUGC.ignoreBar.SetEditText then
        DacksUGC.ignoreBar:SetEditText(text or "")
    end
end
