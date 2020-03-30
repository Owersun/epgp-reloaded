--[[-----------------------------------------------------------------------------
ScrollFrame Container
Plain container that scrolls its content and doesn't grow in height.
-------------------------------------------------------------------------------]]
local Type, Version = "ScrollList", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

-- WoW APIs
local CreateFrame, UIParent = CreateFrame, UIParent

--[[-----------------------------------------------------------------------------
Support functions
-------------------------------------------------------------------------------]]

local function configureScrollbar(self)
    local scrollbar, items, rows = self.scrollbar, #self.items, #(self.children or {});
    if not (rows < items) then scrollbar:Hide(); return end
    scrollbar:SetMinMaxValues(0, math.max(0, items - rows))
    scrollbar:SetValueStep(1);
    scrollbar:SetStepsPerPage(rows);
    scrollbar:SetValue(self.offset);
    scrollbar:Show()
end

local function drawItems(self)
    local rows, items = self.children or {}, #self.items
    local toDraw = math.min(#rows, items)
    for i = 1, toDraw do
        rows[i]:SetText(self.items[i + self.offset])
    end
end

local function onRowClick(row)
    EPGPR:Print("OnRowClick")
end

-- Manage rows in the scrollframe, create missing amount, or remove excessive amount
local function createRows(self)
    local row
    local rowHeight = self.rowHeight
    local needRows = (math.ceil(self.content:GetHeight() / rowHeight) or 0) + 1
    local rows = self.children or {}

    if #rows == needRows then return end

    -- Add rows
    if needRows > #rows then
        for _ = #rows + 1, needRows do
            row = AceGUI:Create("InteractiveLabel")
            row:SetFullWidth(true)
            local fontFace = row.label:GetFont()
            row:SetFont(fontFace, rowHeight)
            row.highlight:SetColorTexture(1, 1, 1, 0.1)
            row:SetCallback("OnClick", onRowClick)
            self:AddChild(row)
        end
        -- redraw rows content as we added few
        drawItems(self)
    -- Remove rows
    else
        for i = #rows, needRows + 1, -1 do
            row = rows[i]
            rows[i] = nil
            row:Release()
        end
    end

    configureScrollbar(self)
end

local function scrollTo(self, offset)
    local newOffset = math.max(0, math.min(#self.items, offset))
    if newOffset == self.offset then return end
    self.offset = newOffset
    self.scrollbar:SetValue(newOffset)
    drawItems(self)
end

--[[-----------------------------------------------------------------------------
Scripts
-------------------------------------------------------------------------------]]

local function ScrollFrame_OnMouseWheel(scrollframe, value)
    local widget = scrollframe.obj
    local newOffset = widget.offset - value * #(widget.children or {})
    scrollTo(widget, newOffset)
end

local function ScrollFrame_OnSizeChanged(scrollframe)
    createRows(scrollframe.obj)
end

local function ScrollBar_OnScrollValueChanged(scrollbar, value)
    scrollTo(scrollbar.obj, value)
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local methods = {

    ["OnAcquire"] = function(self)

    end,

    ["OnRelease"] = function(self)
        self.items = {}
        self.offset = 0
    end,

    ["SetItems"] = function(self, items)
        self.items = items
        createRows(self)
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
    scrollbar:Hide()
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
        rowHeight   = 12,
        frame       = frame,
        scrollframe = scrollframe,
        scrollbar   = scrollbar,
        content     = content,
        items       = {},
        offset      = 0,
        type        = Type
    }
    for method, func in pairs(methods) do
        widget[method] = func
    end
    scrollframe.obj, scrollbar.obj = widget, widget

    return AceGUI:RegisterAsContainer(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
