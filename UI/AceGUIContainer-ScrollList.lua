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
    if items < rows then
        scrollbar:Disable()
        scrollbar:Hide()
        return
    end
    scrollbar:SetMinMaxValues(0, math.max(0, items - rows + 1))
    scrollbar:SetStepsPerPage(rows);
    scrollbar:SetValue(self.offset);
    scrollbar:Enable()
    scrollbar:Show()
end

-- sort items by column
local function sort(self, by)
    local sortby = self.columns[by].sortby or by
    self.sortedBy = self.sortedBy == sortby and -1 * sortby or sortby
    local i = math.abs(self.sortedBy)
    if self.sortedBy > 0 then
        table.sort(self.items, function(rowA, rowB) return rowA[i] < rowB[i] end)
    else
        table.sort(self.items, function(rowA, rowB) return rowA[i] > rowB[i] end)
    end
end

-- Called when row that is a button is clicked
local function rowClick(self, i)
    self:Fire("OnRowClick", self.items[i + self.offset])
end

-- Fill rows with items
local function drawItems(self)
    local items, rows, columns = self.items, self.rows, #self.columns
    for i, row in ipairs(rows) do
        local itemIndex = i + self.offset
        local item = items[itemIndex]
        -- show item, if there is one
        if item then for n = 1, columns do
            row["string" .. n]:SetText(item[n])
        end else -- hide row if there is no item
            row:Hide()
        end
    end
end

-- callback when header button is clicked
local function headerClick(self, i)
    if self.columns[i].sortable == false then return end
    sort(self, i)
    drawItems(self)
end

-- put buttons on the header
local function drawHeader(self)
    local offset = 0
    for i, config in ipairs(self.columns) do
        local button = self.headerfactory:Acquire()
        button:SetWidth(config.width)
        button.Middle:SetWidth(config.width - 9)
        button:GetFontString():SetJustifyH(config.justify or "LEFT")
        button:SetPoint("TOPLEFT", offset, 0)
        button:SetText(config.name)
        button:SetScript("OnClick", function() headerClick(self, i) end)
        button:Show()
        offset = offset + config.width
    end
end

-- Manage rows in the content frame, create missing amount, or remove excessive amount
local function createRows(self)
    local rowHeight, hasRows = self.rowHeight, #self.rows
    local needRows = math.floor(self.content:GetHeight() / rowHeight) + 1 -- there always must be 1 line more than the form height

    -- We already have exactly as much rows as we need
    if hasRows == needRows then return end

    -- Add rows
    local width = self.content:GetWidth()
    if needRows > hasRows then
        for i = hasRows + 1, needRows do
            local row = self.rowsfactory:Acquire()
            table.insert(self.rows, i, row)
            row:SetPoint("TOPLEFT", self.content, "TOPLEFT", 0, -1 * i * rowHeight + rowHeight)
            row:SetWidth(width)
            local offset = 0
            for n, column in ipairs(self.columns) do
                local string = row["string" .. n]
                string:SetWidth(column.width)
                string:SetPoint("LEFT", offset, 0)
                string:SetJustifyH(column.justify or "LEFT")
                string:Show()
                offset = offset + column.width
            end
            row:SetScript("OnClick", function(_) rowClick(self, i) end)
            row:Show()
        end
        -- redraw rows content as we added few
        drawItems(self)
    -- Remove rows
    else
        for i = hasRows, needRows + 1, -1 do
            self.rows[i]:Hide() -- hide
            self.rows[i]:SetParent(nil) -- release
            table.remove(self.rows, i)
        end
    end

    configureScrollbar(self)
end

local function scrollTo(self, offset)
    local newOffset = math.max(0, math.min(#self.items - #self.rows + 1, offset))
    if newOffset == self.offset then return end
    self.offset = newOffset
    self.scrollbar:SetValue(newOffset)
    drawItems(self)
end

--[[-----------------------------------------------------------------------------
Scripts
-------------------------------------------------------------------------------]]

local function ScrollFrame_OnMouseWheel(frame, value)
    local widget = frame.obj
    local newOffset = widget.offset - value * #widget.rows
    scrollTo(widget, newOffset)
end

local function ScrollFrame_OnSizeChanged(frame)
    createRows(frame.obj)
end

local function ScrollBar_OnScrollValueChanged(frame, value)
    scrollTo(frame.obj, value)
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local methods = {

    ["OnAcquire"] = function(self)

    end,

    ["OnRelease"] = function(self)
        self.offset = 0
        self.sortedBy = 0
        self.items = {}
        self.columns = {}
        self.rowsfactory:ReleaseAll()
        self.headerfactory:ReleaseAll()
        self.rows = {}
    end,

    ["SetItems"] = function(self, items)
        self.items = items
        createRows(self)
        if (self.sortedBy ~= 0) then sort(self, self.sortedBy) end
        drawItems(self)
    end,

    ["SetColumns"] = function(self, config)
        self.columns = config
        drawHeader(self)
    end

}

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]
local function Constructor()
    local frame = CreateFrame("Frame", nil, UIParent)
    local num = AceGUI:GetNextWidgetNum(Type)

    local header = CreateFrame("Frame", nil, frame)
    header:SetPoint("TOPLEFT")
    header:SetPoint("TOPRIGHT")
    header:SetHeight(24)

    local scrollframe = CreateFrame("ScrollFrame", nil, frame)
    scrollframe:SetPoint("TOPLEFT", header, "BOTTOMLEFT")
    scrollframe:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT")
    scrollframe:EnableMouseWheel(true)
    scrollframe:SetScript("OnMouseWheel", ScrollFrame_OnMouseWheel)
    scrollframe:SetScript("OnSizeChanged", ScrollFrame_OnSizeChanged)

    local content = CreateFrame("Frame", nil, scrollframe)
    scrollframe:SetScrollChild(content)
    content:SetPoint("TOPLEFT")
    content:SetPoint("BOTTOMRIGHT", scrollframe, "BOTTOMRIGHT", -16, 0)

    local scrollbar = CreateFrame("Slider", ("AceConfigDialogScrollFrame%dScrollBar"):format(num), scrollframe, "UIPanelScrollBarTemplate")
    scrollbar:SetValue(0)
    scrollbar:SetValueStep(1)
    scrollbar:SetPoint("TOPRIGHT", scrollframe, "TOPRIGHT", 0, -16)
    scrollbar:SetPoint("BOTTOMRIGHT", scrollframe, "BOTTOMRIGHT", 0, 16)
    scrollbar:SetWidth(16)
    scrollbar:SetObeyStepOnDrag(true)
    scrollbar:Hide()
    -- set the script as the last step, so it doesn't fire yet
    scrollbar:SetScript("OnValueChanged", ScrollBar_OnScrollValueChanged)

    local scrollbg = scrollbar:CreateTexture(nil, "BACKGROUND")
    scrollbg:SetAllPoints(scrollbar)
    scrollbg:SetTexture(0, 0, 0, 0.4)

    -- Pool of rows that scroll container can consume
    local rowsfactory = CreateFramePool("Button", content, "EPGPRScrollListButtonTemplate")
    local headerfactory = CreateFramePool("Button", header, "EPGPRScrollListColumnButtonTemplate")

    local widget = {
        rowHeight   = 20,
        frame       = frame,
        scrollframe = scrollframe,
        scrollbar   = scrollbar,
        header      = header,
        content     = content,
        columns     = {},
        headerfactory = headerfactory,
        sortedBy    = 0,
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
