--- Main incident list window (DebugLogViewer-style).
DacksUGC = DacksUGC or {}

local IncidentViewer = ZO_Object:Subclass()
DacksUGC.IncidentViewer = IncidentViewer

local UGC_INCIDENT_DATA = 1
local INCIDENT_ROW_HEIGHT = 30
local MAX_INCIDENTS = 500
local SKIP_SCROLL_ANIMATION = true

local DEFAULT_DETAIL_PANE_HEIGHT = 220
local MIN_DETAIL_PANE_HEIGHT = 120
local MIN_LIST_HEIGHT = 100
local DETAIL_BOTTOM_INSET = 50
local PANE_SIDE_INSET = 10
local PANE_LIST_GAP = 8
local PANE_SPLITTER_HEIGHT = 8

local MESSAGE_WINDOW_SCENE_NAMES = { "hud", "hudui", "gameMenuInGame", "siegeBar", "siegeBarUI" }

local string_format = string.format
local string_lower = string.lower
local table_concat = table.concat
local table_insert = table.insert
local table_remove = table.remove
local zo_strformat = zo_strformat

local function formatGlobalKey(key)
    if type(key) == "string" then
        return string_format("%q", key)
    end
    return tostring(key)
end

local function getSearchBoxFilterText(editControl)
    local text = editControl:GetText() or ""
    if text == editControl:GetDefaultText() then
        return ""
    end
    return text
end

function IncidentViewer:New()
    local obj = ZO_Object.New(self)
    obj:Initialize()
    return obj
end

function IncidentViewer:Initialize()
    self.window = DacksUGCMainWindow
    self.window.container = self
    self.masterList = {}
    self.nextIncidentId = 0
    self.searchFilter = ""
    self.searchFilterLower = ""
    self.scrollLockedToBottom = true
    self.skipNextScrollAnimation = false
    self.pendingRefresh = nil

    self.fragment = ZO_SimpleSceneFragment:New(self.window)

    local detailHost = self.window:GetNamedChild("DetailPane")
    self.detailPaneHost = detailHost
    self.detailPane = DacksUGC.DetailPane:New(detailHost)

    local ignoreHost = self.window:GetNamedChild("IgnoreBar")
    self.ignoreBar = DacksUGC.IgnoreBar:New(ignoreHost)
    DacksUGC.ignoreBar = self.ignoreBar

    local sv = DacksUGC.savedVars
    self.detailPaneHeight = (sv and sv.window and sv.window.detailPaneHeight) or DEFAULT_DETAIL_PANE_HEIGHT
    self.paneSplitter = self.window:GetNamedChild("PaneSplitter")

    self:ApplyWindowTheme()
    self:InitializeToolbar()
    self:InitializeList()
    self:InitializePaneSplitter()
    self:InitializeWindowHandlers()
    self:ApplySavedGeometry()
    self:ApplyPaneLayout()
end

function IncidentViewer:ApplyWindowTheme()
    local Theme = DacksUGC.Theme
    local window = self.window

    Theme.ApplyBackdrop(window:GetNamedChild("BG"), "surface")
    Theme.ApplyBackdrop(window:GetNamedChild("ListBg"), "surface")

    local titleBar = window:GetNamedChild("TitleBar")
    Theme.ApplyBackdrop(titleBar:GetNamedChild("Bg"), "surfaceAlt")
    local titleLabel = titleBar:GetNamedChild("Title")
    titleLabel:SetText(GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_WINDOW_TITLE))
    Theme.ApplyLabelColor(titleLabel, true)

    local toolbar = window:GetNamedChild("Toolbar")
    Theme.ApplyBackdrop(toolbar:GetNamedChild("Bg"), "surfaceAlt")
end

function IncidentViewer:ApplySavedGeometry()
    local sv = DacksUGC.savedVars
    if not sv or not sv.window then
        return
    end
    local w = sv.window
    if w.width and w.height then
        self.window:SetDimensions(w.width, w.height)
    end
    if w.x and w.y then
        self.window:ClearAnchors()
        self.window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, w.x, w.y)
    end
end

function IncidentViewer:SaveGeometry()
    local sv = DacksUGC.savedVars
    if not sv then
        return
    end
    sv.window = sv.window or {}
    local x, y = self.window:GetScreenRect()
    sv.window.x = x
    sv.window.y = y
    sv.window.width, sv.window.height = self.window:GetDimensions()
    sv.window.detailPaneHeight = self.detailPaneHeight
end

function IncidentViewer:GetMaxDetailPaneHeight()
    local window = self.window
    local titleBar = window:GetNamedChild("TitleBar")
    local toolbar = window:GetNamedChild("Toolbar")
    local chrome = titleBar:GetHeight() + toolbar:GetHeight() + DETAIL_BOTTOM_INSET + PANE_SPLITTER_HEIGHT + PANE_LIST_GAP * 2
    return window:GetHeight() - chrome - MIN_LIST_HEIGHT
end

function IncidentViewer:ClampDetailPaneHeight(height)
    return zo_clamp(height, MIN_DETAIL_PANE_HEIGHT, self:GetMaxDetailPaneHeight())
end

function IncidentViewer:ApplyPaneLayout()
    local window = self.window
    local detailPane = self.detailPaneHost
    local splitter = self.paneSplitter
    local list = self.sortFilterList.list
    local listBg = window:GetNamedChild("ListBg")
    local toolbar = window:GetNamedChild("Toolbar")

    self.detailPaneHeight = self:ClampDetailPaneHeight(self.detailPaneHeight)

    detailPane:ClearAnchors()
    detailPane:SetAnchor(BOTTOMLEFT, window, BOTTOMLEFT, PANE_SIDE_INSET, -DETAIL_BOTTOM_INSET)
    detailPane:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, -PANE_SIDE_INSET, -DETAIL_BOTTOM_INSET)
    detailPane:SetHeight(self.detailPaneHeight)

    splitter:ClearAnchors()
    splitter:SetAnchor(BOTTOMLEFT, detailPane, TOPLEFT, 0, -4)
    splitter:SetAnchor(BOTTOMRIGHT, detailPane, TOPRIGHT, 0, -4)
    splitter:SetHeight(PANE_SPLITTER_HEIGHT)

    list:ClearAnchors()
    list:SetAnchor(TOPLEFT, toolbar, BOTTOMLEFT, PANE_SIDE_INSET, PANE_LIST_GAP)
    list:SetAnchor(BOTTOMRIGHT, splitter, TOPRIGHT, -PANE_SIDE_INSET, -PANE_LIST_GAP)

    listBg:ClearAnchors()
    listBg:SetAnchor(TOPLEFT, toolbar, BOTTOMLEFT, PANE_SIDE_INSET, PANE_LIST_GAP)
    listBg:SetAnchor(BOTTOMRIGHT, splitter, TOPRIGHT, -PANE_SIDE_INSET, -PANE_LIST_GAP)

    ZO_ScrollList_UpdateScroll(list)
end

function IncidentViewer:StopPaneSplitterDrag()
    if not self.splitterDragActive then
        return
    end
    self.splitterDragActive = false
    self.window:SetHandler("OnUpdate", nil)
    if self.paneSplitterDragShield then
        self.paneSplitterDragShield:SetHidden(true)
    end
    if self.paneSplitterRootDragShield then
        self.paneSplitterRootDragShield:SetHidden(true)
    end
    WINDOW_MANAGER:SetMouseCursor(MOUSE_CURSOR_DO_NOT_CARE)
    self:SaveGeometry()
end

function IncidentViewer:InitializePaneSplitter()
    local viewer = self
    local splitter = self.paneSplitter
    local window = self.window
    if not splitter or not window then
        return
    end

    splitter:SetMouseEnabled(true)

    local dragShield = WINDOW_MANAGER:CreateControl("$(parent)PaneSplitterDragShield", window, CT_CONTROL)
    dragShield:SetAnchor(TOPLEFT, window, TOPLEFT, 0, 0)
    dragShield:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, 0, 0)
    dragShield:SetMouseEnabled(true)
    dragShield:SetDrawTier(DT_HIGH)
    dragShield:SetHidden(true)
    viewer.paneSplitterDragShield = dragShield

    local rootDragShield = WINDOW_MANAGER:CreateControl("DacksUGCPaneSplitterDragShieldRoot", GuiRoot, CT_CONTROL)
    rootDragShield:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 0, 0)
    rootDragShield:SetAnchor(BOTTOMRIGHT, GuiRoot, BOTTOMRIGHT, 0, 0)
    rootDragShield:SetMouseEnabled(true)
    rootDragShield:SetDrawTier(DT_MAX_VALUE)
    rootDragShield:SetHidden(true)
    viewer.paneSplitterRootDragShield = rootDragShield

    local function tryStopDrag(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT and viewer.splitterDragActive then
            viewer:StopPaneSplitterDrag()
        end
    end

    dragShield:SetHandler("OnMouseUp", tryStopDrag)
    rootDragShield:SetHandler("OnMouseUp", tryStopDrag)
    splitter:SetHandler("OnMouseUp", tryStopDrag)
    window:SetHandler("OnMouseUp", tryStopDrag)

    local function startDrag()
        viewer.splitterDragActive = true
        viewer.splitterDragStartY = select(2, GetUIMousePosition())
        viewer.splitterDragStartHeight = viewer.detailPaneHeight
        WINDOW_MANAGER:SetMouseCursor(MOUSE_CURSOR_RESIZE_NS)
        dragShield:SetHidden(false)
        rootDragShield:SetHidden(false)
        viewer.window:SetHandler("OnUpdate", function()
            viewer:OnPaneSplitterDragUpdate()
        end)
    end

    splitter:SetHandler("OnMouseDown", function(control, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            startDrag()
        end
    end)
    splitter:SetHandler("OnDragStart", function(control, button)
        if button == MOUSE_BUTTON_INDEX_LEFT and not viewer.splitterDragActive then
            startDrag()
        end
    end)
    splitter:SetHandler("OnMouseEnter", function()
        if not viewer.splitterDragActive then
            WINDOW_MANAGER:SetMouseCursor(MOUSE_CURSOR_RESIZE_NS)
        end
    end)
    splitter:SetHandler("OnMouseExit", function()
        if not viewer.splitterDragActive then
            WINDOW_MANAGER:SetMouseCursor(MOUSE_CURSOR_DO_NOT_CARE)
        end
    end)
end

function IncidentViewer:OnPaneSplitterDragUpdate()
    if not self.splitterDragActive then
        return
    end
    local mouseY = select(2, GetUIMousePosition())
    local deltaY = self.splitterDragStartY - mouseY
    self.detailPaneHeight = self:ClampDetailPaneHeight(self.splitterDragStartHeight + deltaY)
    self:ApplyPaneLayout()
end

function IncidentViewer:InitializeToolbar()
    local Theme = DacksUGC.Theme
    local titleBar = self.window:GetNamedChild("TitleBar")
    local toolbar = self.window:GetNamedChild("Toolbar")

    local searchLabel = toolbar:GetNamedChild("SearchLabel")
    searchLabel:SetText(GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_TOOLBAR_SEARCH))
    searchLabel.tooltipText = GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_TOOLBAR_SEARCH_TT)
    Theme.ApplyLabelColor(searchLabel, true)

    local searchBox = toolbar:GetNamedChild("Search"):GetNamedChild("Box")
    self.searchBox = searchBox
    searchBox:SetFont(Theme.font.body)
    searchBox:SetDefaultText(GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_SEARCH_PLACEHOLDER))
    searchBox:SetHandler("OnTextChanged", function(control)
        self.searchFilter = getSearchBoxFilterText(control)
        self.searchFilterLower = string_lower(self.searchFilter)
        self:RequestRefresh(SKIP_SCROLL_ANIMATION)
    end)

    local clearBtn = toolbar:GetNamedChild("ClearIncidents")
    clearBtn.tooltipText = GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_TOOLBAR_CLEAR_TT)

    local resetBtn = titleBar:GetNamedChild("ResetFilters")
    resetBtn.tooltipText = GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_TOOLBAR_RESET_TT)

    local helpBtn = titleBar:GetNamedChild("Help")
    helpBtn.tooltipText = GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_CMD_HELP)

    local closeBtn = titleBar:GetNamedChild("Close")
    closeBtn.tooltipText = GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_TOOLBAR_CLOSE_TT)
end

function IncidentViewer:ShouldShowIncident(data, filterLower)
    if filterLower == "" then
        return true
    end
    local keyStr = formatGlobalKey(data.key)
    local frameStr = data.topFrame or ""
    return string.find(string_lower(keyStr), filterLower, 1, true) ~= nil or string.find(string_lower(frameStr), filterLower, 1, true) ~= nil
end

function IncidentViewer:InitializeList()
    local viewer = self
    local window = self.window
    local list = ZO_SortFilterList:New(window)
    list:SetEmptyText(GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_EMPTY))
    list:SetAlternateRowBackgrounds(true)
    list:SetAutomaticallyColorRows(false)

    self.refreshIncidentList = function()
        viewer.pendingRefresh = nil
        list:RefreshFilters()
        if viewer.scrollLockedToBottom then
            ZO_ScrollList_ScrollDataIntoView(list.list, #list.list.data, nil, viewer.skipNextScrollAnimation)
            viewer.skipNextScrollAnimation = false
        end
    end

    local Theme = DacksUGC.Theme
    local function SetupRow(control, data)
        list:SetupRow(control, data)

        local secR, secG, secB, secA = Theme.textSecondary:UnpackRGBA()
        local priR, priG, priB, priA = Theme.textPrimary:UnpackRGBA()
        local accR, accG, accB, accA = Theme.accent:UnpackRGBA()

        local timeControl = control:GetNamedChild("Time")
        timeControl:SetText(data.timeShort or "")
        timeControl:SetColor(secR, secG, secB, secA)
        timeControl.tooltipText = data.formattedTime

        local countControl = control:GetNamedChild("Count")
        countControl:SetText(string_format("%dx", data.reportCount or 0))
        countControl:SetColor(accR, accG, accB, accA)
        countControl.tooltipText = zo_strformat(GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_ROW_COUNT_TT), data.reportCount or 0)

        local globalControl = control:GetNamedChild("Global")
        globalControl:SetText(formatGlobalKey(data.key))
        globalControl:SetColor(priR, priG, priB, priA)
        globalControl.tooltipText = data.globalTooltip

        local frameControl = control:GetNamedChild("Frame")
        frameControl:SetText(data.topFrame or "?")
        frameControl:SetColor(secR, secG, secB, secA)
        frameControl.tooltipText = data.topFrame

        local stackControl = control:GetNamedChild("Stack")
        local names = data.functionNames
        if names and #names > 0 then
            stackControl:SetHidden(false)
            stackControl.tooltipText = table_concat(names, "\n")
        else
            stackControl:SetHidden(true)
        end
    end

    ZO_ScrollList_AddDataType(list.list, UGC_INCIDENT_DATA, "UGCIncidentRow", INCIDENT_ROW_HEIGHT, SetupRow)
    ZO_ScrollList_EnableHighlight(list.list, "ZO_ThinListHighlight")

    function list:FilterScrollList()
        local output = ZO_ScrollList_GetDataList(self.list)
        ZO_ClearNumericallyIndexedTable(output)

        local masterList = self.masterList
        if not masterList then
            return
        end

        for i = 1, #masterList do
            local data = ZO_ScrollList_GetDataEntryData(masterList[i])
            if viewer:ShouldShowIncident(data, viewer.searchFilterLower) then
                output[#output + 1] = masterList[i]
            end
        end
    end

    list.masterList = self.masterList
    self.sortFilterList = list
end

function IncidentViewer:InitializeWindowHandlers()
    local window = self.window
    local list = self.sortFilterList
    local viewer = self

    window.OnMoveStop = function()
        viewer:SaveGeometry()
        ZO_ScrollList_UpdateScroll(list.list)
    end

    window.OnResizeStop = function()
        viewer:ApplyPaneLayout()
        viewer:SaveGeometry()
    end

    window.OnMouseEnterRow = function(control)
        if control.tooltipText then
            InitializeTooltip(InformationTooltip, control, BOTTOM, 5, 0)
            SetTooltipText(InformationTooltip, control.tooltipText)
            control = control:GetParent()
        end
        list:EnterRow(control)
    end

    window.OnMouseExitRow = function(control)
        if control.tooltipText then
            ClearTooltip(InformationTooltip)
            control = control:GetParent()
        end
        list:ExitRow(control)
    end

    window.OnMouseUpRow = function(control, button, upInside)
        if viewer.splitterDragActive then
            if button == MOUSE_BUTTON_INDEX_LEFT then
                viewer:StopPaneSplitterDrag()
            end
            return
        end
        if not upInside or button ~= MOUSE_BUTTON_INDEX_LEFT then
            return
        end
        -- ZO_ScrollList_GetData returns entry.data (see ScrollTemplates.lua), not a data entry wrapper.
        local data = ZO_ScrollList_GetData(control)
        if not data and control.GetParent then
            data = ZO_ScrollList_GetData(control:GetParent())
        end
        viewer:SelectIncident(data)
    end

    window.OnMouseEnter = function(control)
        if control.tooltipText then
            InitializeTooltip(InformationTooltip, control, BOTTOM, 5, 0)
            SetTooltipText(InformationTooltip, control.tooltipText)
        end
    end

    window.OnMouseExit = function(control)
        if control.tooltipText then
            ClearTooltip(InformationTooltip)
        end
    end

    window.OnCloseClicked = function()
        viewer:Hide()
    end

    window.OnHelpClicked = function()
        if DacksUGC.showHelp then
            DacksUGC.showHelp()
        end
    end

    window.OnResetFiltersClicked = function()
        viewer.searchFilter = ""
        viewer.searchFilterLower = ""
        viewer.searchBox:SetText("")
        viewer:RequestRefresh(SKIP_SCROLL_ANIMATION)
    end

    window.OnClearIncidentsClicked = function()
        ZO_Dialogs_ShowPlatformDialog("DACKS_UGC_CLEAR_INCIDENTS")
    end
end

function IncidentViewer:RegisterClearDialog()
    if ESO_Dialogs["DACKS_UGC_CLEAR_INCIDENTS"] then
        return
    end
    ESO_Dialogs["DACKS_UGC_CLEAR_INCIDENTS"] = {
        canQueue = true,
        title = { text = GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_CLEAR_DIALOG_TITLE) },
        mainText = { text = GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_CLEAR_DIALOG_TEXT) },
        buttons = {
            [1] = {
                text = SI_DIALOG_CANCEL,
            },
            [2] = {
                text = SI_DIALOG_CONFIRM,
                callback = function()
                    if DacksUGC.viewer then
                        DacksUGC.viewer:ClearIncidents()
                    end
                end,
            },
        },
    }
end

function IncidentViewer:ClearIncidents()
    ZO_ClearNumericallyIndexedTable(self.masterList)
    self.detailPane:Clear()
    self:RequestRefresh(SKIP_SCROLL_ANIMATION)
end

function IncidentViewer:SelectIncident(data)
    if not data then
        return
    end
    self.detailPane:SetIncident(data)
    local keyText = type(data.key) == "string" and data.key or tostring(data.key)
    self.detailPane:PrefillIgnoreEdit(keyText)
end

function IncidentViewer:OnIncident(incident)
    self.nextIncidentId = self.nextIncidentId + 1
    incident.id = self.nextIncidentId

    local formattedTime = GetTimeString()
    incident.formattedTime = formattedTime
    incident.timeShort = formattedTime:sub(1, 8)
    incident.globalTooltip = zo_strformat(GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_ROW_GLOBAL_TT), formatGlobalKey(incident.key), type(incident.key))

    local dataEntry = ZO_ScrollList_CreateDataEntry(UGC_INCIDENT_DATA, incident)
    table_insert(self.masterList, dataEntry)

    while #self.masterList > MAX_INCIDENTS do
        table_remove(self.masterList, 1)
    end

    self:RequestRefresh()
end

function IncidentViewer:RequestRefresh(skipScrollAnimation)
    if skipScrollAnimation and self.scrollLockedToBottom then
        self.skipNextScrollAnimation = true
    end
    if not self.pendingRefresh and not self.window:IsHidden() then
        self.pendingRefresh = zo_callLater(self.refreshIncidentList, 0)
    elseif not self.pendingRefresh then
        self.pendingRefresh = zo_callLater(function()
            self.pendingRefresh = nil
            self.sortFilterList:RefreshFilters()
        end, 0)
    end
end

function IncidentViewer:AddFragmentToScenes()
    for _, sceneName in ipairs(MESSAGE_WINDOW_SCENE_NAMES) do
        local scene = SCENE_MANAGER:GetScene(sceneName)
        if scene and not scene:HasFragment(self.fragment) then
            scene:AddFragment(self.fragment)
        end
    end
end

function IncidentViewer:RemoveFragmentFromScenes()
    for _, sceneName in ipairs(MESSAGE_WINDOW_SCENE_NAMES) do
        local scene = SCENE_MANAGER:GetScene(sceneName)
        if scene then
            scene:RemoveFragment(self.fragment)
        end
    end
end

function IncidentViewer:Show()
    self:RegisterClearDialog()
    self.window:SetHidden(false)
    self:AddFragmentToScenes()
    self.sortFilterList:RefreshFilters()
    if self.scrollLockedToBottom then
        ZO_ScrollList_ScrollDataIntoView(self.sortFilterList.list, #self.sortFilterList.list.data, nil, true)
    end
end

function IncidentViewer:Hide()
    self:RemoveFragmentFromScenes()
    self.window:SetHidden(true)
end

function IncidentViewer:Toggle()
    if self.window:IsHidden() then
        self:Show()
    else
        self:Hide()
    end
end

function IncidentViewer:IsShowing()
    return not self.window:IsHidden()
end

function IncidentViewer:SetDetailText(text)
    self:Show()
    self.detailPane:SetIncident({ detailText = text })
end
