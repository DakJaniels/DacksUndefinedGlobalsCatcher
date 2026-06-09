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

local LIST_ROW_LEFT_INSET = 8
local LIST_COL_TIME_WIDTH = 72
local LIST_COL_COUNT_WIDTH = 48
local LIST_COL_GAP = 6
local LIST_COL_GLOBAL_FRAME_GAP = 10
local LIST_COL_STACK_WIDTH = 30
local LIST_COL_STACK_RIGHT_INSET = 4
local LIST_COL_SPLITTER_WIDTH = 6
local LIST_COL_FIXED_LEFT_WIDTH = LIST_ROW_LEFT_INSET + LIST_COL_TIME_WIDTH + LIST_COL_GAP + LIST_COL_COUNT_WIDTH + LIST_COL_GAP
local LIST_COL_FIXED_RIGHT_WIDTH = LIST_COL_STACK_WIDTH + LIST_COL_STACK_RIGHT_INSET + LIST_COL_GLOBAL_FRAME_GAP
local DEFAULT_GLOBAL_COLUMN_WIDTH = 340
local MIN_GLOBAL_COLUMN_WIDTH = 100
local MIN_FRAME_COLUMN_WIDTH = 80

local MESSAGE_WINDOW_SCENE_NAMES = { "hud", "hudui", "gameMenuInGame", "siegeBar", "siegeBarUI" }

local string_format = string.format
local string_lower = string.lower
local table_concat = table.concat
local table_insert = table.insert
local table_remove = table.remove
local zo_strformat = zo_strformat

local GLOBAL_VALUE_PREVIEW_MAX = 72
local GLOBAL_UNDEFINED_COLOR = ZO_ColorDef:New(1, 0.45, 0.45)

local function formatGlobalKey(key)
    if type(key) == "string" then
        return string_format("%q", key)
    end
    return tostring(key)
end

local function truncatePreview(text, maxLen)
    if #text <= maxLen then
        return text
    end
    return text:sub(1, maxLen) .. "..."
end

local function formatValuePreview(value)
    local valueType = type(value)
    if valueType == "string" then
        return string_format("%q", truncatePreview(value, GLOBAL_VALUE_PREVIEW_MAX))
    elseif valueType == "number" or valueType == "boolean" then
        return tostring(value)
    end
    return nil
end

--- @return boolean isUndefined
--- @return string statusLine
--- @return string|nil previewLine
local function describeGlobalLookup(key)
    if type(key) ~= "string" then
        return false, zo_strformat(GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_ROW_GLOBAL_TT_KEY_TYPE), type(key)), nil
    end
    local value = rawget(_G, key)
    if value == nil then
        return true, GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_ROW_GLOBAL_TT_UNDEFINED), nil
    end
    local valueType = type(value)
    local statusLine = zo_strformat(GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_ROW_GLOBAL_TT_DEFINED), valueType)
    local preview = formatValuePreview(value)
    if preview then
        preview = zo_strformat(GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_ROW_GLOBAL_TT_VALUE), preview)
    end
    return false, statusLine, preview
end

local function addGlobalTooltipLine(text, r, g, b)
    InformationTooltip:AddLine(text, "", r, g, b, TOPLEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT)
end

local function hideGlobalIncidentTooltip()
    ClearTooltip(InformationTooltip)
end

local function showGlobalIncidentTooltip(control)
    local data = control.ugcIncidentData
    if not data then
        return
    end
    InitializeTooltip(InformationTooltip, control, BOTTOM, 0, -3)
    local Theme = DacksUGC.Theme
    local accR, accG, accB = Theme.accent:UnpackRGB()
    local secR, secG, secB = Theme.textSecondary:UnpackRGB()
    local priR, priG, priB = Theme.textPrimary:UnpackRGB()

    local title = zo_strformat(GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_ROW_GLOBAL_TT_TITLE), formatGlobalKey(data.key))
    addGlobalTooltipLine(title, accR, accG, accB)

    local isUndefined, statusLine, previewLine = describeGlobalLookup(data.key)
    if isUndefined then
        local ur, ug, ub = GLOBAL_UNDEFINED_COLOR:UnpackRGB()
        addGlobalTooltipLine(statusLine, ur, ug, ub)
    else
        addGlobalTooltipLine(statusLine, secR, secG, secB)
    end
    if previewLine then
        addGlobalTooltipLine(previewLine, secR, secG, secB)
    end

    ZO_Tooltip_AddDivider(InformationTooltip)

    local frame = data.topFrame
    if frame and frame ~= "" and frame ~= "?" then
        addGlobalTooltipLine(zo_strformat(GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_ROW_GLOBAL_TT_FRAME), frame), secR, secG, secB)
    end
    addGlobalTooltipLine(zo_strformat(GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_ROW_COUNT_TT), data.reportCount or 0), priR, priG, priB)
end

local function hookGlobalLabelTooltip(globalControl)
    if globalControl.ugcGlobalTooltipHooked then
        return
    end
    globalControl.ugcGlobalTooltipHooked = true
    globalControl.tooltipText = ""
    globalControl:SetHandler("OnMouseEnter", showGlobalIncidentTooltip)
    globalControl:SetHandler("OnMouseExit", hideGlobalIncidentTooltip)
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
    self.globalColumnWidth = (sv and sv.window and sv.window.globalColumnWidth) or DEFAULT_GLOBAL_COLUMN_WIDTH
    self.paneSplitter = self.window:GetNamedChild("PaneSplitter")

    self:ApplyWindowTheme()
    self:InitializeToolbar()
    self:InitializeList()
    self:InitializeListColumnSplitter()
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
    sv.window.globalColumnWidth = self.globalColumnWidth
end

function IncidentViewer:GetListColumnLayoutWidth()
    local list = self.sortFilterList and self.sortFilterList.list
    if not list then
        return 0
    end
    return list:GetWidth()
end

function IncidentViewer:ClampGlobalColumnWidth(width, listWidth)
    listWidth = listWidth or self:GetListColumnLayoutWidth()
    if listWidth <= 0 then
        return zo_clamp(width, MIN_GLOBAL_COLUMN_WIDTH, DEFAULT_GLOBAL_COLUMN_WIDTH)
    end
    local maxWidth = listWidth - LIST_COL_FIXED_LEFT_WIDTH - LIST_COL_FIXED_RIGHT_WIDTH - MIN_FRAME_COLUMN_WIDTH
    maxWidth = zo_max(maxWidth, MIN_GLOBAL_COLUMN_WIDTH)
    return zo_clamp(width, MIN_GLOBAL_COLUMN_WIDTH, maxWidth)
end

function IncidentViewer:GetGlobalColumnSplitterOffsetX()
    return LIST_COL_FIXED_LEFT_WIDTH + self.globalColumnWidth
end

function IncidentViewer:ApplyIncidentRowColumnLayout(rowControl)
    if not rowControl then
        return
    end
    local countControl = rowControl:GetNamedChild("Count")
    local globalControl = rowControl:GetNamedChild("Global")
    local frameControl = rowControl:GetNamedChild("Frame")
    local stackControl = rowControl:GetNamedChild("Stack")
    local globalWidth = self.globalColumnWidth

    globalControl:ClearAnchors()
    globalControl:SetAnchor(LEFT, countControl, RIGHT, LIST_COL_GAP, 0)
    globalControl:SetDimensions(globalWidth, INCIDENT_ROW_HEIGHT)

    stackControl:ClearAnchors()
    stackControl:SetAnchor(RIGHT, rowControl, RIGHT, -LIST_COL_STACK_RIGHT_INSET, -3)

    frameControl:ClearAnchors()
    frameControl:SetAnchor(LEFT, globalControl, RIGHT, LIST_COL_GLOBAL_FRAME_GAP, 0)
    frameControl:SetAnchor(RIGHT, stackControl, LEFT, -LIST_COL_GLOBAL_FRAME_GAP, 0)
    frameControl:SetHeight(INCIDENT_ROW_HEIGHT)
end

local function prepareEllipsisLabel(label)
    if label and not label.ugcEllipsisPrepared then
        label.ugcEllipsisPrepared = true
        label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    end
end

function IncidentViewer:ApplyListColumnLayout()
    local list = self.sortFilterList and self.sortFilterList.list
    if not list then
        return
    end
    local listWidth = list:GetWidth()
    self.globalColumnWidth = self:ClampGlobalColumnWidth(self.globalColumnWidth, listWidth)

    local splitter = self.listColumnSplitter
    if splitter then
        local offsetX = self:GetGlobalColumnSplitterOffsetX()
        splitter:ClearAnchors()
        splitter:SetAnchor(TOPLEFT, list, TOPLEFT, offsetX - LIST_COL_SPLITTER_WIDTH * 0.5, 0)
        splitter:SetAnchor(BOTTOMLEFT, list, BOTTOMLEFT, offsetX - LIST_COL_SPLITTER_WIDTH * 0.5, 0)
        splitter:SetWidth(LIST_COL_SPLITTER_WIDTH)
    end

    ZO_ScrollList_RefreshVisible(list)
end

function IncidentViewer:InstallDragOnUpdateHandler()
    self.window:SetHandler("OnUpdate", function()
        if self.listColSplitterDragActive then
            self:OnListColumnSplitterDragUpdate()
        elseif self.splitterDragActive then
            self:OnPaneSplitterDragUpdate()
        end
    end)
end

function IncidentViewer:StopListColumnSplitterDrag()
    if not self.listColSplitterDragActive then
        return
    end
    self.listColSplitterDragActive = false
    if not self.splitterDragActive then
        self.window:SetHandler("OnUpdate", nil)
    end
    if self.listColSplitterDragShield then
        self.listColSplitterDragShield:SetHidden(true)
    end
    if self.listColSplitterRootDragShield then
        self.listColSplitterRootDragShield:SetHidden(true)
    end
    WINDOW_MANAGER:SetMouseCursor(MOUSE_CURSOR_DO_NOT_CARE)
    self:SaveGeometry()
end

function IncidentViewer:OnListColumnSplitterDragUpdate()
    if not self.listColSplitterDragActive then
        return
    end
    local list = self.sortFilterList.list
    local listLeft = select(1, list:GetScreenRect())
    local scale = list:GetScale()
    if scale == 0 then
        scale = 1
    end
    local mouseX = select(1, GetUIMousePosition())
    local relativeX = (mouseX - listLeft) / scale
    self.globalColumnWidth = self:ClampGlobalColumnWidth(relativeX - LIST_COL_FIXED_LEFT_WIDTH)
    self:ApplyListColumnLayout()
end

function IncidentViewer:InitializeListColumnSplitter()
    local viewer = self
    local list = self.sortFilterList and self.sortFilterList.list
    local window = self.window
    if not list or not window then
        return
    end

    local splitter = WINDOW_MANAGER:CreateControl("$(parent)ListColumnSplitter", list, CT_CONTROL)
    splitter:SetMouseEnabled(true)
    splitter:SetDrawTier(DT_HIGH)
    splitter.tooltipText = GetString(DACKS_UNDEFINED_GLOBALS_CATCHER_LIST_COL_SPLITTER_TT)
    viewer.listColumnSplitter = splitter

    local grip = WINDOW_MANAGER:CreateControl("$(parent)Grip", splitter, CT_TEXTURE)
    grip:SetColor(1, 1, 1, 0.35)
    grip:SetAnchor(TOPLEFT)
    grip:SetAnchor(BOTTOMRIGHT)
    grip:SetWidth(1)

    local dragShield = WINDOW_MANAGER:CreateControl("$(parent)ListColSplitterDragShield", window, CT_CONTROL)
    dragShield:SetAnchor(TOPLEFT, window, TOPLEFT, 0, 0)
    dragShield:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, 0, 0)
    dragShield:SetMouseEnabled(true)
    dragShield:SetDrawTier(DT_HIGH)
    dragShield:SetHidden(true)
    viewer.listColSplitterDragShield = dragShield

    local rootDragShield = WINDOW_MANAGER:CreateControl("DacksUGCListColSplitterDragShieldRoot", GuiRoot, CT_CONTROL)
    rootDragShield:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 0, 0)
    rootDragShield:SetAnchor(BOTTOMRIGHT, GuiRoot, BOTTOMRIGHT, 0, 0)
    rootDragShield:SetMouseEnabled(true)
    rootDragShield:SetDrawTier(DT_MAX_VALUE)
    rootDragShield:SetHidden(true)
    viewer.listColSplitterRootDragShield = rootDragShield

    local function tryStopDrag(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT and viewer.listColSplitterDragActive then
            viewer:StopListColumnSplitterDrag()
        end
    end

    dragShield:SetHandler("OnMouseUp", tryStopDrag)
    rootDragShield:SetHandler("OnMouseUp", tryStopDrag)
    splitter:SetHandler("OnMouseUp", tryStopDrag)
    window:SetHandler("OnMouseUp", tryStopDrag)

    local function startDrag()
        if viewer.splitterDragActive then
            return
        end
        viewer.listColSplitterDragActive = true
        WINDOW_MANAGER:SetMouseCursor(MOUSE_CURSOR_RESIZE_EW)
        dragShield:SetHidden(false)
        rootDragShield:SetHidden(false)
        viewer:InstallDragOnUpdateHandler()
    end

    splitter:SetHandler("OnMouseDown", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            startDrag()
        end
    end)
    splitter:SetHandler("OnDragStart", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT and not viewer.listColSplitterDragActive then
            startDrag()
        end
    end)
    splitter:SetHandler("OnMouseEnter", function()
        if not viewer.listColSplitterDragActive then
            WINDOW_MANAGER:SetMouseCursor(MOUSE_CURSOR_RESIZE_EW)
        end
    end)
    splitter:SetHandler("OnMouseExit", function()
        if not viewer.listColSplitterDragActive then
            WINDOW_MANAGER:SetMouseCursor(MOUSE_CURSOR_DO_NOT_CARE)
        end
    end)

    self:ApplyListColumnLayout()
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
    self:ApplyListColumnLayout()
end

function IncidentViewer:StopPaneSplitterDrag()
    if not self.splitterDragActive then
        return
    end
    self.splitterDragActive = false
    if not self.listColSplitterDragActive then
        self.window:SetHandler("OnUpdate", nil)
    end
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
        if viewer.listColSplitterDragActive then
            return
        end
        viewer.splitterDragActive = true
        viewer.splitterDragStartY = select(2, GetUIMousePosition())
        viewer.splitterDragStartHeight = viewer.detailPaneHeight
        WINDOW_MANAGER:SetMouseCursor(MOUSE_CURSOR_RESIZE_NS)
        dragShield:SetHidden(false)
        rootDragShield:SetHidden(false)
        viewer:InstallDragOnUpdateHandler()
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
    if DacksUGC.shouldSkipIncident and DacksUGC.shouldSkipIncident(data.key, data.functionNames) then
        return false
    end
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
        globalControl.ugcIncidentData = data
        hookGlobalLabelTooltip(globalControl)
        prepareEllipsisLabel(globalControl)

        local frameControl = control:GetNamedChild("Frame")
        frameControl:SetText(data.topFrame or "?")
        frameControl:SetColor(secR, secG, secB, secA)
        frameControl.tooltipText = data.topFrame
        prepareEllipsisLabel(frameControl)

        viewer:ApplyIncidentRowColumnLayout(control)

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

function IncidentViewer:RemoveIncidentsMatchingIgnoreRules()
    if not DacksUGC.shouldSkipIncident then
        return
    end
    local masterList = self.masterList
    local removed = false
    for i = #masterList, 1, -1 do
        local data = ZO_ScrollList_GetDataEntryData(masterList[i])
        if DacksUGC.shouldSkipIncident(data.key, data.functionNames) then
            table_remove(masterList, i)
            removed = true
        end
    end
    if removed then
        local current = self.detailPane:GetIncident()
        if current and DacksUGC.shouldSkipIncident(current.key, current.functionNames) then
            self.detailPane:Clear()
        end
        self:RequestRefresh(SKIP_SCROLL_ANIMATION)
    end
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
    if DacksUGC.shouldSkipIncident and DacksUGC.shouldSkipIncident(incident.key, incident.functionNames) then
        return
    end

    self.nextIncidentId = self.nextIncidentId + 1
    incident.id = self.nextIncidentId

    local formattedTime = GetTimeString()
    incident.formattedTime = formattedTime
    incident.timeShort = formattedTime:sub(1, 8)

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
    self:RemoveIncidentsMatchingIgnoreRules()
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
