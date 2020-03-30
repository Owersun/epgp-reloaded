local EPGPR, AceGUI, RAID_CLASS_COLORS, unpack = EPGPR, EPGPR.Libs.AceGUI, RAID_CLASS_COLORS, unpack

local function tabStangings(container)
    container:SetLayout("List")

    EPGPR:GuildRefreshRoster()
    local group = AceGUI:Create("SimpleGroup")
    group:SetLayout("Fill")
    group:SetFullWidth(true)
    group:SetHeight(280)
    local guildList = {}
    for name, data in pairs(EPGPR.State.guildRoster or {}) do
        local _, playerRank, playerClass, EP, GP, PR = unpack(data)
        local classColor = RAID_CLASS_COLORS[playerClass] and RAID_CLASS_COLORS[playerClass].colorStr or 'ffffffff'
        table.insert(guildList, "|c" .. classColor .. name .. "|r (" .. playerRank .. ") " .. ": EP/GP " .. EP .. "/" .. GP .. ", PR " .. PR)
    end
    local frame = AceGUI:Create("ScrollList")
    frame:SetLayout("List")
    frame:SetItems(guildList)
    group:AddChild(frame)
    container:AddChild(group)

    local changeGuildEPGP = AceGUI:Create("Button")
    changeGuildEPGP:SetText("Change Guild EPGP")
    changeGuildEPGP:SetCallback("OnClick", function()
        StaticPopup_Show("EPGPR_CHANGE_GUILD_EPGP_POPUP")
    end)
    container:AddChild(changeGuildEPGP)
end

local function tabRaid(container)

end

local function tabStandby(container)
    container:SetLayout("List")

    EPGPR:GuildRefreshRoster()

    -- Standby list
    local standbyGroup = AceGUI:Create("SimpleGroup")
    standbyGroup:SetLayout("Fill")
    standbyGroup:SetFullWidth(true)
    standbyGroup:SetHeight(140)
    local standbyList = {}
    for name, _ in pairs(EPGPR.config.standby.list or {}) do
        local _, _, playerRank, playerClass, EP, GP, PR = EPGPR:GuildGetMemberInfo(name)
        local classColor = RAID_CLASS_COLORS[playerClass] and RAID_CLASS_COLORS[playerClass].colorStr or 'ffffffff'
        table.insert(standbyList, ("|c%s%s|r (%s): EP/GP: %d/%d, PR %.2f"):format(classColor, name, playerRank, EP, GP, PR))
    end
    local standby = AceGUI:Create("ScrollList")
    standby:SetLayout("List")
    standby:SetItems(standbyList)
    standbyGroup:AddChild(standby)
    container:AddChild(standbyGroup)

    -- Alts list
    local altsGroup = AceGUI:Create("SimpleGroup")
    altsGroup:SetLayout("Fill")
    altsGroup:SetFullWidth(true)
    altsGroup:SetHeight(140)
    local alts = AceGUI:Create("ScrollList")
    alts:SetLayout("List")
    local function refreshAltsList()
        local altsList = {}
        for alt, main in pairs(EPGPR.config.alts.list or {}) do
            local playerName, _, playerRank, playerClass, EP, GP, PR = EPGPR:GuildGetMemberInfo(main)
            local classColor = RAID_CLASS_COLORS[playerClass] and RAID_CLASS_COLORS[playerClass].colorStr or 'ffffffff'
            table.insert(altsList, ("%s is alt of |c%s%s|r (%s): EP/GP: %d/%d, PR %.2f"):format(alt, classColor, playerName, playerRank, EP, GP, PR))
        end
        alts:SetItems(altsList)
    end
    refreshAltsList()
    altsGroup:AddChild(alts)
    container:AddChild(altsGroup)

    -- Alts controls
    local addAlt = AceGUI:Create("SimpleGroup")
    addAlt:SetLayout("Flow")
    addAlt:SetFullWidth(true)
    addAlt:SetHeight(40)
    local a = AceGUI:Create("EditBox")
    a:SetRelativeWidth(0.3)
    a:DisableButton(true)
    local b = AceGUI:Create("EditBox")
    b:SetRelativeWidth(0.3)
    b:DisableButton(true)
    local ok = AceGUI:Create("Button")
    ok:SetText("add alt")
    ok:SetRelativeWidth(0.3)
    ok:SetCallback("OnClick", function()
        -- on success clear the fields and refresh the form
        if EPGPR:SetAlt(a:GetText(), b:GetText()) then
            a:SetText()
            b:SetText()
            refreshAltsList()
        end
    end)
    addAlt:AddChild(a)
    addAlt:AddChild(b)
    addAlt:AddChild(ok)
    container:AddChild(addAlt)
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

    local roster = {}
    for name, player in pairs(EPGPR.State.guildRoster) do
        roster[player[1]] = '["' .. name .. '","' .. player[2] .. '","' .. player[3] .. '",' .. player[4] .. ',' .. player[5] .. ',' .. player[6] .. ']'
    end
    local json = '[' .. table.concat(roster, ',') .. ']'
    box:SetText(json)
end

local function selectTab(container, event, tab)
    container:ReleaseChildren()
    if tab == "Standings" then tabStangings(container)
    elseif tab == "Raid" then tabRaid(container)
    elseif tab == "Standby" then tabStandby(container)
    elseif tab == "Export" then tabExport(container)
    end
end

EPGPR.UI.EPGPR = function()

    -- Create a container frame
    local window = AceGUI:Create("Window")
    window:SetTitle("EPGP Reloaded")
    window:SetLayout("Flow")
    window:SetWidth(300)
    window:SetHeight(400)

    -- Add tabs to the container
    local tabGroup = AceGUI:Create("TabGroup");
    tabGroup:SetFullWidth(true)
    tabGroup:SetFullHeight(true)
    tabGroup:SetLayout("Fill")
    local tab1 = { text = "Standings", value = "Standings" }
    local tab2 = { text = "Raid", value = "Raid" }
    local tab3 = { text = "Standby", value = "Standby" }
    local tab4 = { text = "Export", value = "Export" }
    tabGroup:SetTabs({ tab1, tab2, tab3, tab4 })
    tabGroup:SetCallback("OnGroupSelected", selectTab)
    tabGroup:SelectTab("Standings")
    window:AddChild(tabGroup)

    return window
end
