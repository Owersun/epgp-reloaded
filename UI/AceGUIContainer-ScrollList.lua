--[[-----------------------------------------------------------------------------
ScrollFrame Container
Plain container that scrolls its content and doesn't grow in height.
-------------------------------------------------------------------------------]]
local Type, Version = "ScrollList", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

-- Lua APIs
local pairs, assert, type = pairs, assert, type
local min, max, floor = math.min, math.max, math.floor

-- WoW APIs
local CreateFrame, UIParent = CreateFrame, UIParent

--[[-----------------------------------------------------------------------------
Support functions
-------------------------------------------------------------------------------]]
local function FixScrollOnUpdate(frame)
    frame:SetScript("OnUpdate", nil)
    frame.obj:FixScroll()
end

--[[-----------------------------------------------------------------------------
Scripts
-------------------------------------------------------------------------------]]
local function ScrollFrame_OnMouseWheel(frame, value)
    EPGPR:Print("ScrollFrame_OnMouseWheel " .. value)
    -- frame.obj:MoveScroll(value)
end

local function ScrollFrame_OnSizeChanged(frame)
    EPGPR:Print("ScrollFrame_OnSizeChanged")
    -- frame:SetScript("OnUpdate", FixScrollOnUpdate)
end

local function ScrollBar_OnScrollValueChanged(frame, value)
    EPGPR:Print("ScrollBar_OnScrollValueChanged " .. value)
    -- frame.obj:SetScroll(value)
end

--[[
["SetScroll"] = function(self, value)
    local status = self.status or self.localstatus
    local viewheight = self.scrollframe:GetHeight()
    local height = self.content:GetHeight()
    local offset

    if viewheight > height then
        offset = 0
    else
        offset = floor((height - viewheight) / 1000.0 * value)
    end
    self.content:ClearAllPoints()
    self.content:SetPoint("TOPLEFT", 0, offset)
    self.content:SetPoint("TOPRIGHT", 0, offset)
    status.offset = offset
    status.scrollvalue = value
end,

["MoveScroll"] = function(self, value)
    local status = self.status or self.localstatus
    local height, viewheight = self.scrollframe:GetHeight(), self.content:GetHeight()

    if self.scrollBarShown then
        local diff = height - viewheight
        local delta = 1
        if value < 0 then
            delta = -1
        end
        self.scrollbar:SetValue(min(max(status.scrollvalue + delta*(1000/(diff/45)),0), 1000))
    end
end,

["FixScroll"] = function(self)
    if self.updateLock then return end
    self.updateLock = true
    local status = self.status or self.localstatus
    local height, viewheight = self.scrollframe:GetHeight(), self.content:GetHeight()
    local offset = status.offset or 0
    -- Give us a margin of error of 2 pixels to stop some conditions that i would blame on floating point inaccuracys
    -- No-one is going to miss 2 pixels at the bottom of the frame, anyhow!
    if viewheight < height + 2 then
        if self.scrollBarShown then
            self.scrollBarShown = nil
            self.scrollbar:Hide()
            self.scrollbar:SetValue(0)
            self.scrollframe:SetPoint("BOTTOMRIGHT")
            if self.content.original_width then
                self.content.width = self.content.original_width
            end
            self:DoLayout()
        end
    else
        if not self.scrollBarShown then
            self.scrollBarShown = true
            self.scrollbar:Show()
            self.scrollframe:SetPoint("BOTTOMRIGHT", -20, 0)
            if self.content.original_width then
                self.content.width = self.content.original_width - 20
            end
            self:DoLayout()
        end
        local value = (offset / (viewheight - height) * 1000)
        if value > 1000 then value = 1000 end
        self.scrollbar:SetValue(value)
        self:SetScroll(value)
        if value < 1000 then
            self.content:ClearAllPoints()
            self.content:SetPoint("TOPLEFT", 0, offset)
            self.content:SetPoint("TOPRIGHT", 0, offset)
            status.offset = offset
        end
    end
    self.updateLock = nil
end,
]]--

local function updateScrollbar(self)
    local scrollbar, items, buttons = self.scrollbar, #self.items, #(self.children or {});
    scrollbar:SetMinMaxValues(0, (items - buttons) * 10)
    scrollbar:SetValueStep(10);
    scrollbar:SetStepsPerPage(buttons * 10);
    scrollbar:SetValue(0);
end

local function drawItems(self, offset)
    local buttons = self.children or {}
    for i, button in pairs(buttons) do
        button:SetText(self.items[i])
    end
end

local function createButtons(self)
    local button
    local buttons, buttonHeight = self.children or {}, self.buttonH

    if not buttons[1] then
        button = AceGUI:Create("InteractiveLabel")
        button:SetFullWidth(true)
        local fontFace = button.label:GetFont()
        button:SetFont(fontFace, buttonHeight)
        self:AddChild(button)
    end

    local numButtons = (math.ceil(self.content:GetHeight() / buttonHeight) or 0) + 1

    if #buttons == numButtons then return end

    -- Add buttons
    if numButtons > #buttons then
        for i = #buttons + 1, numButtons do
            button = AceGUI:Create("InteractiveLabel")
            button:SetFullWidth(true)
            local fontFace = button.label:GetFont()
            button:SetFont(fontFace, buttonHeight)
            self:AddChild(button)
        end
    -- Remove buttons
    else
        for i = #buttons, numButtons + 1, -1 do
            button = buttons[i]
            buttons[i] = nil
            button:Release()
        end
    end

    drawItems(self)
    updateScrollbar(self)
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local methods = {

    ["OnAcquire"] = function(self)
        self.scrollbar:SetValue(0)
    end,

    ["OnRelease"] = function(self)
        -- self.scrollbar:Hide()
    end,

    ["OnWidthSet"] = function(self, width)
        EPGPR:Print("OnWidthSet " .. width)
    end,

    ["OnHeightSet"] = function(self, height)
        EPGPR:Print("OnHeightSet " .. height)
        createButtons(self)
    end,

    --[[
    ["LayoutFinished"] = function(self, width, height)
        self.content:SetHeight(height or 0 + 20)
        -- update the scrollframe
        self:FixScroll()
        -- schedule another update when everything has "settled"
        self.scrollframe:SetScript("OnUpdate", FixScrollOnUpdate)
    end,
    ]]--

    ["SetItems"] = function(self, items)
        self.items = items
        drawItems(self)
        updateScrollbar(self)
    end

}

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]
local function Constructor()
    local frame = CreateFrame("Frame", nil, UIParent)

    local scrollframe = CreateFrame("ScrollFrame", nil, frame)
    scrollframe:SetPoint("TOPLEFT")
    scrollframe:SetPoint("BOTTOMRIGHT")
    scrollframe:EnableMouseWheel(true)
    scrollframe:SetScript("OnMouseWheel", ScrollFrame_OnMouseWheel)
    scrollframe:SetScript("OnSizeChanged", ScrollFrame_OnSizeChanged)

    local scrollbar = CreateFrame("Slider", ("AceConfigDialogScrollList%dScrollBar"):format(AceGUI:GetNextWidgetNum(Type)), scrollframe, "UIPanelScrollBarTemplate")
    scrollbar:SetPoint("TOPRIGHT", scrollframe, "TOPRIGHT", 0, -16)
    scrollbar:SetPoint("BOTTOMRIGHT", scrollframe, "BOTTOMRIGHT", 0, 16)
    scrollbar:SetWidth(16)
    scrollbar:SetObeyStepOnDrag(true)
    -- scrollbar:Hide()
    -- set the script as the last step, so it doesn't fire yet
    scrollbar:SetScript("OnValueChanged", ScrollBar_OnScrollValueChanged)

    local scrollbg = scrollbar:CreateTexture(nil, "BACKGROUND")
    scrollbg:SetAllPoints(scrollbar)
    scrollbg:SetColorTexture(0, 0, 0, 0.4)

    --Container Support
    local content = CreateFrame("Frame", nil, scrollframe)
    scrollframe:SetScrollChild(content)
    content:SetPoint("TOPLEFT", scrollframe, "TOPLEFT")
    content:SetPoint("BOTTOMRIGHT", scrollframe, "BOTTOMRIGHT", -16, 0)

    local widget = {
        buttonH     = 12,
        frame       = frame,
        scrollframe = scrollframe,
        scrollbar   = scrollbar,
        content     = content,
        items       = {},
        type        = Type
    }
    for method, func in pairs(methods) do
        widget[method] = func
    end

    return AceGUI:RegisterAsContainer(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
