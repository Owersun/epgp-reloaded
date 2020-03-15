local LootOverviewItem, AceGUI = EPGPR.UI.LootOverviewItem, EPGPR.Libs.AceGUI

-- Current item announce data. slotId is current announcement, player is to whom we confirmed it to be given after announcement, and GP for how much
local _announcing = {slotId = nil, player = nil, GP = nil}

-- Refill the form with given items and show it
local function showItems(widget, _, items)
    widget:ReleaseChildren()
    for slotId, item in pairs(items) do
        widget:AddChild(LootOverviewItem(slotId, item))
    end
    widget:DoLayout()
    widget:Show()
end

-- Remove item row from the list. Account for several cases here:
-- - no announcement is going on and slot is cleared
-- - announcement is going on and some other item is gone (announcement should stay untouched, and no slot states changed)
-- - announcement was going on and it is completed, so all other slots should regain their "enabled" state, and this is also the case where we process distributed item
local function clearSlot(widget, _, slotId, item)
    local children = widget.children
    -- clear the slot that has gone from the loot, there is no need to change states of slots yet,
    -- as it could be something completely unrelated to current announcement being given
    for i, child in ipairs(children) do
        if child:GetUserData("slotId") == slotId then
            table.remove(children, i)
            child:Release()
            break
        end
    end
    -- if the slot in announcement is gone, record loot distribution happened through the announcement,
    -- signal all slots that announcement has finished, and clear current announcement.
    if _announcing.slotId and _announcing.slotId == slotId then
        -- reset announcement to nil
        local annoncingPlayer, GP = _announcing.player, _announcing.GP
        _announcing = {slotId = nil, player = nil, GP = nil}
        -- process item distribution, recording GP if the item was given to the same player we requested it to be given in "giveSlot",
        -- any other case is either "master looter changed his mind" or most probably the disenchant case without any bids
        if item.candidate then EPGPR:ItemDistributed(item.candidate, item.link, annoncingPlayer == item.candidate and GP or nil) end
        -- reset items rows states
        -- second iteration through same children is required due to how lua does table remove inside loop through same table
        for _, child in ipairs(children) do child:Fire("AnnounceFinish", slotId) end
    end
    -- in case all loot is gone, then close
    if #widget.children == 0 then widget:Hide()
    -- otherwise redraw
    else widget:DoLayout() end
end

-- Start/Stop announcement of loot in slot
-- slotId = nil here would mean we finish the current annoucement if there was any
local function announceSlot(widget, _, slotId)
    -- what type of announcement we send, and about which slotId
    local message, aboutSlotId = unpack(slotId and {"AnnounceStart", slotId} or {"AnnounceFinish", _announcing.slotId})
    -- set the currently announcing slotId
    _announcing.slotId = slotId
    -- Signal all slots that announcement has been started/stopped for slotId
    for _, child in ipairs(widget.children) do child:Fire(message, aboutSlotId) end
    widget:DoLayout()
end

-- Someone bid to the current announcement
local function bid(widget, _, name, message, roll)
    -- if there is current announcement
    if _announcing.slotId then
        local player = EPGPR:GetBidderProperties(name)
        -- there is a player by this name in our group, dispatch the event to item slot
        if player then for _, child in ipairs(widget.children) do
            -- Pass the bid to the slot currently in announcement
            if child:GetUserData("slotId") == _announcing.slotId then
                child:Fire("Bid", player, message, roll)
                widget:DoLayout()
                break
            end
        end end
    end
end

-- Confirmation dialog on loot announce was "OK"-ed to be given to the player for GP
-- This function is just going to signal the master loot to distribute the item, which can fail in certain circumstances
-- So to surely track what was given to whom, this is going to be done in "clearSlot", which is going to be called from LOOT_SLOT_CLEARED event,
-- when actual item is gone from the loot, and here we just save to whom and by which price we intended to give the loot
local function giveSlot(_, _, slotId, player, GP)
    if _announcing.slotId and _announcing.slotId ~= slotId then return end -- confirmation doesn't match what we are currently ditributing
    -- save to whom we are giving the loot and by which price
    _announcing.player = player
    _announcing.GP = GP
    -- Find the player by name in master loot list and trigger giving the item to him
    for i = 1, 40 do
        if GetMasterLootCandidate(slotId, i) == player then
            GiveMasterLoot(slotId, i);
            break;
        end
    end
end

-- Form was closed.
-- As there is no other way to open it, as close and open the loot again, reinitializng the form, we just wipe it state clean
local function onClose(widget, _)
    _announcing = {slotId = nil, player = nil, GP = nil}
    widget:ReleaseChildren()
end

-- Factory of loot overview form
EPGPR.UI.LootOverview = function()

    local LootOverview = AceGUI:Create("Window")
    LootOverview:SetAutoAdjustHeight(true)
    LootOverview:SetWidth(400)
    LootOverview.frame:SetMinResize(400, 100)
    LootOverview:SetLayout("List")
    LootOverview:SetTitle("Loot Overview")

    LootOverview:SetCallback("ShowItems", showItems)
    LootOverview:SetCallback("ClearSlot", clearSlot)
    LootOverview:SetCallback("AnnounceSlot", announceSlot)
    LootOverview:SetCallback("Bid", bid)
    LootOverview:SetCallback("GiveSlot", giveSlot)
    LootOverview:SetCallback("OnClose", onClose)

    return LootOverview
end
