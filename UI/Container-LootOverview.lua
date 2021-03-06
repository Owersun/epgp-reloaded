local EPGPR, LootOverviewItem, AceGUI, GetMasterLootCandidate = EPGPR, EPGPR.UI.LootOverviewItem, EPGPR.Libs.AceGUI, GetMasterLootCandidate

-- Factory of loot overview form
EPGPR.UI.LootOverview = function()

    -- main window
    local LootOverview = AceGUI:Create("Window")
    LootOverview:Hide()
    LootOverview:EnableResize(false)
    LootOverview:SetWidth(400)
    LootOverview:SetLayout("List")
    LootOverview:SetTitle("Loot Overview")

    -- area with list of items in loot
    local ItemList = AceGUI:Create("SimpleGroup")
    ItemList:SetFullWidth(true)
    ItemList:SetLayout("List")
    LootOverview:AddChild(ItemList)

    -- list items in the current item list to the chat
    local function listLootToChat(button, _)
        -- set the button to disabled state to prevent multi announcements and mess in the chat
        button:SetDisabled(true)
        local items = {}
        for _, slot in ipairs(ItemList.children) do
            local item = slot:GetUserData("item")
            if item then table.insert(items, item) end
        end
        EPGPR:ChatListLoot(items)
    end

    -- button "announce all loot to chat"
    local ListButton = AceGUI:Create("Button")
    ListButton:SetText("List all loot to raid chat")
    ListButton:SetCallback("OnClick", listLootToChat)
    LootOverview:AddChild(ListButton)

    -- Current item announce data. slotId - current announcement, name - to whom we confirmed it to be given after announcement, and GP - for how much
    local _announcing = {}

    -- adjust announce window height when content changes
    local function recalculateWindowHeight()
        LootOverview:DoLayout()
        LootOverview:SetHeight(ItemList.frame:GetHeight() + ListButton.frame:GetHeight() + 57)
    end

    -- Refill the form with given items and show it
    local function showItems(_, _, items)
        ItemList:ReleaseChildren()
        for slotId, item in pairs(items) do
            ItemList:AddChild(LootOverviewItem(slotId, item))
        end
        ListButton:SetDisabled(false)
        recalculateWindowHeight()
        LootOverview:Show()
    end

    -- Remove item row from the list. Account for several cases here:
    -- - no announcement is going on and slot is cleared
    -- - announcement is going on and some other item is gone (announcement should stay untouched, and no slot states changed)
    -- - announcement was going on and it is completed, so all other slots should regain their "enabled" state, and this is also the case where we process distributed item
    local function clearSlot(_, _, slotId, item)
        local children = ItemList.children
        -- clear the slot that has gone from the loot, there is no need to change states of slots yet,
        -- as it could be something completely unrelated to current announcement going on
        for i, child in ipairs(children) do
            if child:GetUserData("slotId") == slotId then
                table.remove(children, i)
                child:Release()
                break
            end
        end
        -- if the slot in announcement is gone, record loot distribution happened through the announcement,
        -- signal all slots that announcement has finished, and clear current announcement.
        if _announcing.slotId == slotId then
            -- reset announcement to nil
            local name, GP = _announcing.name, _announcing.GP
            _announcing = {}
            -- process item distribution, recording GP if the item was given to the same player we requested it to be given in "giveSlot",
            -- any other case is either "master looter changed his mind" or most probably the disenchant case without any bids
            if item.candidate then EPGPR:ItemDistributed(item.candidate, item.link, name == item.candidate and GP or nil) end
            -- reset items rows states
            -- second iteration through same children is required due to how lua does table remove inside loop through same table
            for _, child in ipairs(children) do child:Fire("AnnounceFinish", slotId) end
        end
        -- in case all loot is gone, then close
        if #ItemList.children == 0 then LootOverview:Hide()
        -- otherwise redraw
        else recalculateWindowHeight() end
    end

    -- Start/Stop announcement of loot in slot
    -- slotId = nil here would mean we finish the current annoucement if there was any
    local function announceSlot(_, _, slotId)
        -- what type of announcement we send, and about which slotId
        local message, aboutSlotId = unpack(slotId and {"AnnounceStart", slotId} or {"AnnounceFinish", _announcing.slotId})
        -- set the currently announcing slotId
        _announcing.slotId = slotId
        -- Signal all slots that announcement has been started/stopped for slotId
        for _, child in ipairs(ItemList.children) do child:Fire(message, aboutSlotId) end
        recalculateWindowHeight()
    end

    -- Someone bid to the current announcement
    local function bid(_, _, name, message, roll)
        -- if there is current announcement
        if _announcing.slotId then
            local player = EPGPR:GetBidderProperties(name)
            -- there is a player by this name in our group, dispatch the event to item slot
            if player then for _, child in ipairs(ItemList.children) do
                -- Pass the bid to the slot currently in announcement
                if child:GetUserData("slotId") == _announcing.slotId then
                    child:Fire("Bid", player, message, roll)
                    recalculateWindowHeight()
                    break
                end
            end end
        end
    end

    -- Confirmation dialog on loot announce was "OK"-ed to be given to the player for GP
    -- This function is just going to signal the master loot to distribute the item, which can fail in certain circumstances
    -- So to surely track what was given to whom, it is going to be done in "clearSlot", which is going to be called from LOOT_SLOT_CLEARED event,
    -- when actual item is gone from the loot. And here we save to whom and by which price we command to give it
    local function giveSlot(_, _, slotId, name, GP)
        if _announcing.slotId and _announcing.slotId ~= slotId then return end -- confirmation doesn't match what we are currently ditributing
        -- Find the player by name in master loot list and trigger giving the item to him
        for candidateId = 1, 40 do
            if GetMasterLootCandidate(slotId, candidateId) == name then
                -- save to whom we are giving the loot and by which price
                _announcing.name = name
                _announcing.GP = GP
                -- distribute
                -- DO NOT upvalue this function, as this lead hook we do in Events decorate different function, and miss calls done from here
                GiveMasterLoot(slotId, candidateId);
                break;
            end
        end
    end

    -- Form was closed.
    -- As there is no other usual way to open it, as close and open the loot again, reinitializng the form with items, we just wipe the state clean
    local function onClose(_, _)
        _announcing = {}
        ItemList:ReleaseChildren()
    end

    LootOverview:SetCallback("ShowItems", showItems)
    LootOverview:SetCallback("ClearSlot", clearSlot)
    LootOverview:SetCallback("AnnounceSlot", announceSlot)
    LootOverview:SetCallback("Bid", bid)
    LootOverview:SetCallback("GiveSlot", giveSlot)
    LootOverview:SetCallback("OnClose", onClose)

    return LootOverview
end
