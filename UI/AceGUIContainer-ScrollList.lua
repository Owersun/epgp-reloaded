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
    local scrollbar, items, rows = self.scrollbar, #self.items, #self.rows;
    if items < self.content:GetHeight() / self.rowHeight then
        scrollbar:Hide()
        return
    end
    scrollbar:SetMinMaxValues(0, math.max(0, items - rows))
    scrollbar:SetValueStep(1);
    scrollbar:SetStepsPerPage(rows);
    scrollbar:SetValue(self.offset);
    scrollbar:Show()
end

local function drawItems(self)
    local items, rows = self.items, self.rows
    for i = 1, #rows do
        local item = items[i + self.offset]
        if item then for n = 1, #item do
            rows[i]["string" .. n]:SetText(item[n])
        end end
    end
end

-- Manage rows in the scrollframe, create missing amount, or remove excessive amount
local function createRows(self)
    local rowHeight = self.rowHeight
    local totalRows = math.ceil(self.content:GetHeight() / rowHeight)
    local needRows = math.min(#self.items, totalRows)
    local hasRows = #self.rows

    -- We already have exactly as much rows as we need
    if hasRows == needRows then return end

    -- Add rows
    if needRows > hasRows then
        for i = hasRows + 1, needRows do
            local row = self.rowsfactory:Acquire()
            row:SetPoint("TOPLEFT", self.content, "TOPLEFT", 0, -1 * i * rowHeight)
            row:SetWidth(self.content:GetWidth())
            local offset = 0
            if #self.columns > 0 then for n = 1, #self.columns do
                local string, config = row["string" .. n], self.columns[n]
                string:SetWidth(config.width)
                string:SetPoint("LEFT", offset, 0)
                string:SetJustifyH(config.justify or "LEFT")
                string:Show()
                offset = offset + config.width
            end end
            row:Show()
            table.insert(self.rows, row)
            --[[
            row = AceGUI:Create("InteractiveLabel")
            row:SetFullWidth(true)
            local fontFace = row.label:GetFont()
            row:SetFont(fontFace, rowHeight)
            row.highlight:SetColorTexture(1, 1, 1, 0.1)
            row:SetCallback("OnClick", function() self:Fire("OnRowClick", i + self.offset) end)
            self:AddChild(row)
            ]]--
        end
        -- redraw rows content as we added few
        drawItems(self)
    -- Remove rows
    else
        for i = hasRows, needRows + 1, -1 do
            table.remove(self.rows, i)
        end
    end

    configureScrollbar(self)
end

local function scrollTo(self, offset)
    local newOffset = math.max(0, math.min(#self.items - #(self.children or {}), offset))
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
    local newOffset = widget.offset - value * #(widget.rows or {})
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
        self.scrollbar:Hide()
        self.scrollbar:SetValue(0)
    end,

    ["OnRelease"] = function(self)
        self.items = {}
        self.offset = 0
        self.rows = {}
        self.rowsfactory:ReleaseAll()
    end,

    ["SetItems"] = function(self, items)
        self.items = items
        createRows(self)
        drawItems(self)
    end,

    ["SetColumns"] = function(self, config)
        self.columns = config
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
    scrollbar:SetPoint("TOPRIGHT", scrollframe, "TOPRIGHT", 4, -16)
    scrollbar:SetPoint("BOTTOMRIGHT", scrollframe, "BOTTOMRIGHT", 4, 16)
    scrollbar:SetWidth(16)
    scrollbar:SetObeyStepOnDrag(true)
    -- set the script as the last step, so it doesn't fire yet
    scrollbar:SetScript("OnValueChanged", ScrollBar_OnScrollValueChanged)

    local scrollbg = scrollbar:CreateTexture(nil, "BACKGROUND")
    scrollbg:SetAllPoints(scrollbar)
    scrollbg:SetColorTexture(0, 0, 0, 0.4)

    -- Container Support
    local content = CreateFrame("Frame", nil, scrollframe)
    scrollframe:SetScrollChild(content)
    content:SetPoint("TOPLEFT")
    content:SetPoint("BOTTOMRIGHT", scrollframe, "BOTTOMRIGHT", -20, 0)

    -- Pool of rows that each scroll container can consume
    local rowsfactory = CreateFramePool("Button", content, "EPGPRScrollListButtonTemplate")

    local widget = {
        rowHeight   = 16,
        frame       = frame,
        scrollframe = scrollframe,
        scrollbar   = scrollbar,
        content     = content,
        columns     = {},
        items       = {},
        rows        = {},
        rowsfactory = rowsfactory,
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
