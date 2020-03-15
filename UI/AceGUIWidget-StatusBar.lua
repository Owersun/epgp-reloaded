--[[-----------------------------------------------------------------------------
StatusBar Widget
Displays text and optionally an icon.
-------------------------------------------------------------------------------]]
local Type, Version = "StatusBar", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

-- Lua APIs
local pairs = pairs

-- WoW APIs
local CreateFrame, UIParent = CreateFrame, UIParent

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local methods = {

    ["OnAcquire"] = function(self)
        self:SetWidth(200)
        self:SetJustifyH("LEFT")
        self:SetJustifyV("TOP")
    end,

    ["SetColor"] = function(self, r, g, b)
        if not (r and g and b) then
            r, g, b = 1, 1, 1
        end
        self.frame:SetStatusBarColor(r, g, b)
    end,

    ["SetValue"] = function(self, v)
        self.frame:SetValue(v)
    end,

    ["SetLabel"] = function(self, text)
        self.label:SetText(text)
    end,

    ["SetMinMaxValues"] = function(self, min, max)
        self.frame:SetMinMaxValues(min, max)
    end,

    ["SetJustifyH"] = function(self, justifyH)
        self.label:SetJustifyH(justifyH)
    end,

    ["SetJustifyV"] = function(self, justifyV)
        self.label:SetJustifyV(justifyV)
    end,

}

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]
local function Constructor()
    local frame = CreateFrame("StatusBar", nil, UIParent)
    frame:Hide()

    frame:SetHeight(20)
    frame:SetStatusBarTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
    frame:GetStatusBarTexture():SetHorizTile(false)
    frame:GetStatusBarTexture():SetVertTile(false)
    frame:SetStatusBarColor(0, 0.65, 0)

    frame.bg = frame:CreateTexture(nil, "BACKGROUND")
    frame.bg:SetTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
    frame.bg:SetAllPoints(true)
    frame.bg:SetVertexColor(0, 0.35, 0)

    local label = frame:CreateFontString(nil, "OVERLAY")
    label:SetFontObject(GameFontNormal)
    label:SetPoint("CENTER", frame, "CENTER")
    label:SetShadowOffset(1, -1)
    label:SetTextColor(0, 1, 0)

    -- create widget
    local widget = {
        frame = frame,
        label = label,
        type  = Type
    }
    for method, func in pairs(methods) do
        widget[method] = func
    end

    return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
