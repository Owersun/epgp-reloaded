local EPGPR, RAID_CLASS_COLORS, AceGUI = EPGPR, RAID_CLASS_COLORS, EPGPR.Libs.AceGUI

-- Compare function to sort widget children based on their GPRatio and PR
local function sortFunc(widgetA, widgetB)
    local dataA, dataB = widgetA:GetUserData("data"), widgetB:GetUserData("data")
    -- first sort by GP bidder want to take the item (effectively his priority on the item),
    -- second by bidder priority rating
    return dataA.GP ~= dataB.GP and dataA.GP > dataB.GP or dataA.PR > dataB.PR
end

-- Item announce form that gathers all bids on the item and shows them as rows/buttons
EPGPR.UI.LootOverviewItemAnnounce = function(giveItemTo, itemGP)

    local LootOverviewItemAnnounce = AceGUI:Create("SimpleGroup")
    LootOverviewItemAnnounce:SetFullWidth(true)
    LootOverviewItemAnnounce:SetAutoAdjustHeight(true)
    LootOverviewItemAnnounce:SetLayout("List")

    -- bid has been placed to this announcement
    local function bid(widget, _, player, message, roll)
        local config = EPGPR.config.bidding

        -- check for duplicate bids,
        -- both case multibid is forbidden and this is a second bid, and multibid is allowed and this is second bid within the same group
        for _, child in ipairs(widget.children) do
            local data = child:GetUserData("data")
            if data.name == player.name and (not config.multibid or data.message == message) then return end
        end

        -- calculate bidder properties
        local PR = message and (player.PR or 0) or roll -- bidder PR
        local GPRatio = message and config.messages[message] or (config.rollRatio or 1) -- GP ratio by which GP is going to be reduced for this bidder, e.g. 1/0.5/0.2/etc.
        local GP = math.floor(GPRatio * itemGP) -- actual GP, bidder is going to get this item for
        local classColor = RAID_CLASS_COLORS[player.class] and RAID_CLASS_COLORS[player.class].colorStr or 'ffffffff' -- bidder class color

        -- add another bidder to the list of bidders
        local button = AceGUI:Create("InteractiveLabel")
        button:SetFullWidth(true)
        local fontFace = button.label:GetFont()
        button:SetFont(fontFace, 15)
        button.highlight:SetColorTexture(1, 1, 1, 0.1)
        button:SetText(("|c%s%s|r (%s) %s (for %d GP), rating %d"):format(classColor, player.name, player.rank, (message or "roll"), GP, PR))
        button:SetCallback("OnClick", function() giveItemTo(player.name, GP) end)
        button:SetUserData("data", {name = player.name, message = message, GP = GP, PR = PR})
        widget:AddChild(button)

        -- resort list of bidders (widget children) in place
        table.sort(widget.children, sortFunc)
        widget:DoLayout()
        EPGPR:ChatBidPlaced(player.name, message or "roll", PR)
    end

    LootOverviewItemAnnounce:SetCallback("Bid", bid)

    return LootOverviewItemAnnounce
end
