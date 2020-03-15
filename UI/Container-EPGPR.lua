local AceGUI, RAID_CLASS_COLORS, unpack = EPGPR.Libs.AceGUI, RAID_CLASS_COLORS, unpack

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

local function selectTab(container, event, tab)
    container:ReleaseChildren()
    if tab == "Standings" then tabStangings(container)
    elseif tab == "Raid" then tabRaid(container)
    end
end

EPGPR.UI.EPGPR = function()

    -- Create a container frame
    local window = AceGUI:Create("Window")
    window:SetTitle("EPGP Reloaded")
    window:SetLayout("Flow")
    window:SetWidth(300)
    window:SetHeight(300)

    -- Add tabs to the container
    local tabGroup = AceGUI:Create("TabGroup");
    tabGroup:SetFullWidth(true)
    tabGroup:SetFullHeight(true)
    tabGroup:SetLayout("Fill")
    local tab1 = { text = "Standings", value = "Standings" }
    local tab2 = { text = "Raid", value = "Raid" }
    tabGroup:SetTabs({ tab1, tab2 })
    tabGroup:SetCallback("OnGroupSelected", function(container, event, group)
        selectTab(container, event, group)
    end)
    tabGroup:SelectTab("Standings")
    window:AddChild(tabGroup)

    return window
end
