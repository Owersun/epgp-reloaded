local EPGPR, AceGUI, RAID_CLASS_COLORS, unpack = EPGPR, EPGPR.Libs.AceGUI, RAID_CLASS_COLORS, unpack

local function tabStangings(container)
    local l = AceGUI:Create("Label")
    l:SetText(tab)
    l:SetFullWidth(true)
    container:AddChild(l)
end

local function tabRaid(container)
    local scroll = AceGUI:Create("ScrollFrame")
    scroll:SetFullWidth(true)
    scroll:SetFullHeight(true)
    scroll:SetLayout("List")
    EPGPR:GuildRefreshRoster()
    for name, data in pairs(EPGPR.State.guildRoster) do
        local _, playerRank, playerClass, EP, GP, PR = unpack(data)
        local classColor = RAID_CLASS_COLORS[playerClass] and RAID_CLASS_COLORS[playerClass].colorStr or 'ffffffff'
        local l = AceGUI:Create("Label")
        l:SetFullWidth(true)
        l:SetText("|c" .. classColor .. name .. "|r (" .. playerRank .. ") " .. ": EP/GP " .. EP .. "/" .. GP .. ", PR " .. PR)
        scroll:AddChild(l)
    end
    container:AddChild(scroll)
end

local function tabStandby(container)

    local standby = AceGUI:Create("ScrollFrame")
    standby:SetFullWidth(true)
    standby:SetHeight(80)
    standby:SetLayout("List")
    local standbyList = EPGPR.config.standby.list or {}
    for name, _ in pairs(standbyList) do
        local _, _, playerRank, playerClass, EP, GP, PR = EPGPR:GuildGetMemberInfo(name)
        local classColor = RAID_CLASS_COLORS[playerClass] and RAID_CLASS_COLORS[playerClass].colorStr or 'ffffffff'
        local l = AceGUI:Create("InteractiveLabel")
        l:SetFullWidth(true)
        l:SetCallback("OnClick", function()
            EPGPR:ConfigSet({ standby = { list = false }})
            standbyList[name] = nil
            EPGPR:ConfigSet({ standby = { list = standbyList }})
        end)
        l:SetText(("|c%s%s|r (%s): EP/GP: %d/%d, PR %.2f"):format(classColor, name, playerRank, EP, GP, PR))
        standby:AddChild(l)
    end
    container:AddChild(standby)

    local alts = AceGUI:Create("ScrollFrame")
    alts:SetFullWidth(true)
    alts:SetHeight(80)
    alts:SetLayout("List")
    local function refreshAltsList()
        alts:ReleaseChildren()
        local altsList = EPGPR.config.alts.list or {}
        for alt, main in pairs(altsList) do
            local playerName, _, playerRank, playerClass, EP, GP, PR = EPGPR:GuildGetMemberInfo(main)
            local classColor = RAID_CLASS_COLORS[playerClass] and RAID_CLASS_COLORS[playerClass].colorStr or 'ffffffff'
            local l = AceGUI:Create("InteractiveLabel")
            l:SetFullWidth(true)
            l:SetCallback("OnClick", function()
                EPGPR:SetAlt(alt, nil)
                refreshAltsList()
            end) -- remove alt on click
            l:SetText(("%s is alt of |c%s%s|r (%s): EP/GP: %d/%d, PR %.2f"):format(alt, classColor, playerName, playerRank, EP, GP, PR))
            alts:AddChild(l)
        end
    end
    refreshAltsList()
    container:AddChild(alts)

    local addAlt = AceGUI:Create("SimpleGroup")
    addAlt:SetLayout("Flow")
    addAlt:SetFullWidth(true)
    addAlt:SetHeight(40)
    local a = AceGUI:Create("EditBox")
    a:SetRelativeWidth(0.3)
    a:DisableButton(true)
    addAlt:AddChild(a)
    local b = AceGUI:Create("EditBox")
    b:SetRelativeWidth(0.3)
    b:DisableButton(true)
    addAlt:AddChild(b)
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
    addAlt:AddChild(ok)
    container:AddChild(addAlt)
end

local function selectTab(container, event, tab)
    container:ReleaseChildren()
    local content = AceGUI:Create("SimpleGroup")
    content:SetLayout("Flow")
    container:AddChild(content)
    if tab == "Standings" then tabStangings(content)
    elseif tab == "Raid" then tabRaid(content)
    elseif tab == "Standby" then tabStandby(content)
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
    tabGroup:SetTabs({ tab1, tab2, tab3 })
    tabGroup:SetCallback("OnGroupSelected", selectTab)
    tabGroup:SelectTab("Standings")
    window:AddChild(tabGroup)

    return window
end
