local EPGPR, RAID_CLASS_COLORS, ITEM_QUALITY_COLORS, AceGUI = EPGPR, RAID_CLASS_COLORS, ITEM_QUALITY_COLORS, EPGPR.Libs.AceGUI

-- Compare function to sort widget children based on their GPRatio and PR
local function sortFunc(widgetA, widgetB)
    local dataA, dataB = widgetA:GetUserData("data"), widgetB:GetUserData("data")
    -- first sort by GP bidder want to take the item (effectively his priority on the item), second by bidder priority rating
    if dataA.GP ~= dataB.GP then return dataA.GP > dataB.GP else return dataA.PR > dataB.PR end
end

-- return message decorated with wow color brakets depending on GPRatio. Full GPRatio of 1 is going to have color of epic item, which is 4 in color list
local function paintBidMessage(message, GPRatio)
    local i = math.floor(GPRatio * 4)
    local color = ITEM_QUALITY_COLORS[i] and ITEM_QUALITY_COLORS[i].hex or '|cffffffff'
    return color .. message .. "|r"
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
        local Rating = message and (player.PR or 0) or roll -- bidder PR
        local GPRatio = message and config.messages[message] or (config.rollRatio or 1) -- GP ratio by which GP is going to be reduced for this bidder, e.g. 1/0.5/0.2/etc.
        local GP = math.floor(GPRatio * itemGP) -- actual GP, bidder is going to get this item for
        local classColor = RAID_CLASS_COLORS[player.class] and RAID_CLASS_COLORS[player.class].colorStr or 'ffffffff' -- bidder class color
        local coloredMessage = paintBidMessage(message or 'roll', GPRatio)

        -- add another bidder to the list of bidders
        local button = AceGUI:Create("InteractiveLabel")
        button:SetFullWidth(true)
        local fontFace = button.label:GetFont()
        button:SetFont(fontFace, 15)
        button.highlight:SetColorTexture(1, 1, 1, 0.1)
        button:SetText(("|c%s%s|r (%s) %s (for %d GP), rating %.2f"):format(classColor, player.name, player.rank, coloredMessage, GP, Rating))
        button:SetCallback("OnClick", function() giveItemTo(player.name, GP) end)
        button:SetUserData("data", { name = player.name, message = message, GP = GP, PR = Rating })
        widget:AddChild(button)

        -- resort list of bidders (widget children) in place
        table.sort(widget.children, sortFunc)
        widget:DoLayout()
        if message then EPGPR:ChatBidPlaced(player.name, message, player.EP, player.GP, player.PR) else EPGPR:ChatRollPlaced(player.name, roll) end
    end

    LootOverviewItemAnnounce:SetCallback("Bid", bid)

    return LootOverviewItemAnnounce
end
