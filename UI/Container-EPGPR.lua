local EPGPR, AceGUI, RAID_CLASS_COLORS, unpack, StaticPopup_Show, GetRaidRosterInfo, MAX_RAID_MEMBERS, IsInRaid, CanEditOfficerNote = EPGPR, EPGPR.Libs.AceGUI, RAID_CLASS_COLORS, unpack, StaticPopup_Show, GetRaidRosterInfo, MAX_RAID_MEMBERS, IsInRaid, CanEditOfficerNote

-- will modify byttons be disabled
local canModifyEPGP = CanEditOfficerNote()

local function tabStangings(container)
    container:SetLayout("List")

    EPGPR:GuildRefreshRoster()

    local group = AceGUI:Create("SimpleGroup")
    group:SetLayout("Fill")
    group:SetFullWidth(true)
    group:SetHeight(284)

    local frame = AceGUI:Create("ScrollList")
    local columns = {
        { width = 140, name = "Name", sortby = 6 },
        { width = 100, name = "Rank" },
        { width = 30, name = "EP", justify = "RIGHT" },
        { width = 30, name = "GP", justify = "RIGHT" },
        { width = 30, name = "PR", justify = "RIGHT" },
    }
    frame:SetColumns(columns)
    group:AddChild(frame)
    container:AddChild(group)

    local function getItems()
        local items = {}
        for name, data in pairs(EPGPR.State.guildRoster or {}) do
            local _, playerRank, playerClass, EP, GP, PR = unpack(data)
            local classColor = RAID_CLASS_COLORS[playerClass] and RAID_CLASS_COLORS[playerClass].colorStr or 'ffffffff'
            table.insert(items, { " |c" .. classColor .. name .. "|r", playerRank, EP, GP, PR, name })
        end
        return items
    end

    local changeGuildEPGP = AceGUI:Create("Button")
    changeGuildEPGP:SetDisabled(not changeGuildEPGP)
    container:AddChild(changeGuildEPGP)
    changeGuildEPGP:SetText("Change Guild EPGP")
    changeGuildEPGP:SetCallback("OnClick", function()
        StaticPopup_Show("EPGPR_CHANGE_GUILD_EPGP_POPUP")
    end)

    local items = getItems()
    table.sort(items, function(rowA, rowB) return rowA[5] > rowB[5] end) -- sort by PR
    frame:SetItems(items)
end

local function tabRaid(container)
    container:SetLayout("List")

    EPGPR:GuildRefreshRoster()

    local group = AceGUI:Create("SimpleGroup")
    group:SetLayout("Fill")
    group:SetFullWidth(true)
    group:SetHeight(284)

    local frame = AceGUI:Create("ScrollList")
    group:AddChild(frame)
    container:AddChild(group)

    local columns = {
        { width = 140, name = "Name", sortby = 6 },
        { width = 100, name = "Rank" },
        { width = 30, name = "EP", justify = "RIGHT" },
        { width = 30, name = "GP", justify = "RIGHT" },
        { width = 30, name = "PR", justify = "RIGHT" },
    }
    frame:SetColumns(columns)

    local function getItems()
        local isInRaid = IsInRaid("player")
        local items = {}
        if isInRaid then for n = 1, MAX_RAID_MEMBERS do
            local name, _, _, _, _, playerClass, _, online = GetRaidRosterInfo(n)
            if name then
                local classColor = RAID_CLASS_COLORS[playerClass] and RAID_CLASS_COLORS[playerClass].colorStr or 'ffffffff'
                local color = online and classColor or 'bbbbbbbb'
                local _, i, playerRank, _, EP, GP, PR = EPGPR:GuildGetMemberInfo(name, true)
                if i ~= nil then
                    table.insert(items, { " |c" .. color .. name .. "|r", playerRank, EP, GP, PR, name })
                else
                    table.insert(items, { " |c" .. color .. name .. "|r", "(non-guild member)", 0, 0, 0, name })
                end
            end
        end end
        return items
    end

    local changeRaidEP = AceGUI:Create("Button")
    changeRaidEP:SetDisabled(not isInRaid or not canModifyEPGP)
    container:AddChild(changeRaidEP)
    changeRaidEP:SetText("Add/Remove Raid EP")
    changeRaidEP:SetCallback("OnClick", function()
        StaticPopup_Show("EPGPR_CHANGE_RAID_EP_POPUP")
    end)

    local items = getItems()
    table.sort(items, function(rowA, rowB) return rowA[5] > rowB[5] end) -- sort by PR
    frame:SetItems(items)
end

local function tabStandby(container)
    container:SetLayout("List")

    EPGPR:GuildRefreshRoster()

    -- Standby list
    local standbyGroup = AceGUI:Create("SimpleGroup")
    standbyGroup:SetLayout("Fill")
    standbyGroup:SetFullWidth(true)
    standbyGroup:SetHeight(304)

    local frame = AceGUI:Create("ScrollList")
    standbyGroup:AddChild(frame)
    container:AddChild(standbyGroup)

    local columns = {
        { width = 140, name = "Name", sortby = 6 },
        { width = 100, name = "Rank" },
        { width = 30, name = "EP", justify = "RIGHT" },
        { width = 30, name = "GP", justify = "RIGHT" },
        { width = 30, name = "PR", justify = "RIGHT" },
    }
    frame:SetColumns(columns)

    local function getItems()
        local items = {}
        for name, _ in pairs(EPGPR.config.standby.list or {}) do
            local _, _, playerRank, playerClass, EP, GP, PR = EPGPR:GuildGetMemberInfo(name)
            local classColor = RAID_CLASS_COLORS[playerClass] and RAID_CLASS_COLORS[playerClass].colorStr or 'ffffffff'
            -- there are 5 setup columns and 6 values in the row. 6-th value hold uncolorised player name, which going to be hidden and used in sorting and when row returned in OnClick
            table.insert(items, { " |c" .. classColor .. name .. "|r", playerRank, EP, GP, PR, name })
        end
        return items
    end

    frame:SetCallback("OnRowClick", function(widget, event, row)
        EPGPR.config.standby.list[row[6]] = nil
        local items = getItems()
        frame:SetItems(items)
    end)

    local items = getItems()
    table.sort(items, function(rowA, rowB) return rowA[5] > rowB[5] end) -- sort by PR
    frame:SetItems(items)
end

local function tabAlts(container)
    container:SetLayout("List")

    EPGPR:GuildRefreshRoster()

    -- Alts list
    local altsGroup = AceGUI:Create("SimpleGroup")
    altsGroup:SetLayout("Fill")
    altsGroup:SetFullWidth(true)
    altsGroup:SetHeight(284)

    local frame = AceGUI:Create("ScrollList")
    altsGroup:AddChild(frame)
    container:AddChild(altsGroup)

    local columns = {
        { width = 100, name = "Alt" },
        { width = 140, name = "Main", sortby = 6 },
        { width = 30, name = "EP", justify = "RIGHT" },
        { width = 30, name = "GP", justify = "RIGHT" },
        { width = 30, name = "PR", justify = "RIGHT" },
    }
    frame:SetColumns(columns)

    local function getItems()
        local items = {}
        EPGPR:GuildRefreshRoster()
        for alt, main in pairs(EPGPR.config.alts.list or {}) do
            local name, _, playerRank, playerClass, EP, GP, PR = EPGPR:GuildGetMemberInfo(main)
            local classColor = RAID_CLASS_COLORS[playerClass] and RAID_CLASS_COLORS[playerClass].colorStr or 'ffffffff'
            table.insert(items, { alt, " |c" .. classColor .. name .. "|r (" .. playerRank .. ")", EP, GP, PR, name })
        end
        return items
    end

    frame:SetCallback("OnRowClick", function(widget, event, row)
        EPGPR:SetAlt(row[1], nil)
        local items = getItems()
        frame:SetItems(items)
    end)

    -- Alts controls
    local addAlt = AceGUI:Create("SimpleGroup")
    addAlt:SetLayout("Flow")
    addAlt:SetFullWidth(true)
    container:AddChild(addAlt)
    local a = AceGUI:Create("EditBox")
    addAlt:AddChild(a)
    a:SetWidth(120)
    a:DisableButton(true)
    local b = AceGUI:Create("EditBox")
    addAlt:AddChild(b)
    b:SetWidth(120)
    b:DisableButton(true)
    local ok = AceGUI:Create("Button")
    addAlt:AddChild(ok)
    ok:SetText("add alt")
    ok:SetWidth(100)
    ok:SetCallback("OnClick", function()
        -- on success clear the fields and refresh the form
        if EPGPR:SetAlt(a:GetText(), b:GetText()) then
            a:SetText()
            b:SetText()
            local items = getItems()
            frame:SetItems(items)
        end
    end)

    local items = getItems()
    table.sort(items, function(rowA, rowB) return rowA[5] > rowB[5] end) -- sort by PR
    frame:SetItems(items)
end

local function tabExport(container)
    container:SetLayout("Fill")

    EPGPR:GuildRefreshRoster()

    local exportGroup = AceGUI:Create("SimpleGroup")
    exportGroup:SetLayout("Fill")
    local scroll = AceGUI:Create("ScrollFrame")
    scroll:SetLayout("Fill")
    local box = AceGUI:Create("EditBox")
    box:DisableButton(true)
    box.editbox:SetMultiLine(true)
    scroll:AddChild(box)
    exportGroup:AddChild(scroll)
    container:AddChild(exportGroup)

    local roster, names = {}, {}
    for k, _ in pairs(EPGPR.State.guildRoster) do
        table.insert(names, k)
    end
    table.sort(names)
    -- use the keys to retrieve the values in the sorted order
    for _, name in ipairs(names) do
        local player = EPGPR.State.guildRoster[name]
        table.insert(roster, '["' .. name .. '","' .. player[2] .. '","' .. player[3] .. '",' .. player[4] .. ',' .. player[5] .. ',' .. player[6] .. ']')
    end
    local json = '[' .. table.concat(roster, ',') .. ']'
    box:SetText(json)
end

local function tabAbout(container)
    container:SetLayout("Fill")

    local aboutGroup = AceGUI:Create("SimpleGroup")
    aboutGroup:SetLayout("Fill")
    aboutGroup:SetFullWidth(true)
    container:AddChild(aboutGroup)

    local label = AceGUI:Create("Label")
    label:SetFont(label.label:GetFont(), 24)
    label:SetColor(1, 1, 0)
    label:SetText("\n\n\n\n\nОверсан / Оверскай\nПламегор - Firemaw")
    label:SetJustifyH("CENTER")
    aboutGroup:AddChild(label)
end

local function selectTab(container, event, tab)
    container:ReleaseChildren()
    if tab == "Standings" then
        tabStangings(container)
    elseif tab == "Raid" then
        tabRaid(container)
    elseif tab == "Standby" then
        tabStandby(container)
    elseif tab == "Alts" then
        tabAlts(container)
    elseif tab == "Export" then
        tabExport(container)
    elseif tab == "About" then
        tabAbout(container)
    end
end

EPGPR.UI.EPGPR = function()

    -- Create a container frame
    local window = AceGUI:Create("Window")
    window:SetTitle("EPGP Reloaded")
    window:EnableResize(false)
    window:SetLayout("Fill")
    window:SetWidth(400)
    window:SetHeight(400)

    -- Add tabs to the container
    local tabGroup = AceGUI:Create("TabGroup");
    tabGroup:SetLayout("Fill")
    window:AddChild(tabGroup)

    local tab1 = { text = "Standings", value = "Standings" }
    local tab2 = { text = "Raid", value = "Raid" }
    local tab3 = { text = "Standby", value = "Standby" }
    local tab4 = { text = "Alts", value = "Alts" }
    local tab5 = { text = "Export", value = "Export" }
    local tab6 = { text = "About", value = "About" }
    tabGroup:SetTabs({ tab1, tab2, tab3, tab4, tab5, tab6 })
    tabGroup:SetCallback("OnGroupSelected", selectTab)
    tabGroup:SelectTab("Standings")

    return window
end
