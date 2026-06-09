DacksUGC = DacksUGC or {}

local Theme = {}
DacksUGC.Theme = Theme

Theme.surface = { 0.05, 0.05, 0.07, 1 }
Theme.surfaceAlt = { 0.12, 0.11, 0.14, 1 }
Theme.textPrimary = ZO_DEFAULT_ENABLED_COLOR
Theme.textSecondary = ZO_DEFAULT_DISABLED_COLOR
Theme.accent = ZO_SELECTED_TEXT
Theme.border = { 0.35, 0.32, 0.28, 1 }

Theme.font = {
    title = "ZoFontWinH2",
    body = "ZoFontGame",
    small = "ZoFontGameSmall",
}

Theme.titleBarHeight = 36
Theme.toolbarHeight = 32
Theme.controlHeight = 28

--- @param backdrop BackdropControl
--- @param variant string|nil "surface"|"surfaceAlt"
function Theme.ApplyBackdrop(backdrop, variant)
    if not backdrop then
        return
    end
    variant = variant or "surface"
    local c = Theme[variant] or Theme.surface
    backdrop:SetCenterColor(c[1], c[2], c[3], c[4])
    backdrop:SetEdgeColor(Theme.border[1], Theme.border[2], Theme.border[3], Theme.border[4])
end

--- @param label LabelControl|ButtonControl|nil
--- @param primary boolean|nil
function Theme.ApplyLabelColor(label, primary)
    if not label then
        return
    end
    local c = primary ~= false and Theme.textPrimary or Theme.textSecondary
    local r, g, b, a = c:UnpackRGBA()
    if label.SetColor then
        label:SetColor(r, g, b, a)
    end
    if label.SetNormalFontColor then
        label:SetNormalFontColor(r, g, b, a)
    end
    if label.SetMouseOverFontColor then
        label:SetMouseOverFontColor(r, g, b, math.min(a * 1.2, 1))
    end
end

--- @param button ButtonControl|nil
function Theme.ApplyTextButton(button)
    if not button then
        return
    end
    button:SetFont(Theme.font.body)
    Theme.ApplyLabelColor(button, true)
    button:SetPressedFontColor(Theme.accent:UnpackRGBA())
end

--- @param label LabelControl|nil
--- @param r number
--- @param g number
--- @param b number
--- @param a number|nil
function Theme.SetLabelRGBA(label, r, g, b, a)
    if label then
        label:SetColor(r, g, b, a or 1)
    end
end

--- @param label LabelControl|nil
function Theme.ApplyAccentLabel(label)
    if not label then
        return
    end
    label:SetColor(Theme.accent:UnpackRGBA())
end

--- @return string
function Theme.GetBodyFont()
    if IsInGamepadPreferredMode() or IsConsoleUI() then
        return "$(GAMEPAD_MEDIUM_FONT)|$(GP_18)|soft-shadow-thick"
    end
    return Theme.font.body
end

--- @return string
function Theme.GetDetailFont()
    if IsInGamepadPreferredMode() or IsConsoleUI() then
        return "$(GAMEPAD_MEDIUM_FONT)|$(GP_18)|soft-shadow-thick"
    end
    return "$(BOLD_FONT)|$(KB_16)|soft-shadow-thin"
end
