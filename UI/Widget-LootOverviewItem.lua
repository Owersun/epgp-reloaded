local EPGPR, LootOverviewItemAnnouncement, AceGUI, SendAddonMessage = EPGPR, EPGPR.UI.LootOverviewItemAnnounce, EPGPR.Libs.AceGUI, C_ChatInfo.SendAddonMessage

-- LootOverviewItem factory that produce item rows for LootOverview
EPGPR.UI.LootOverviewItem = function(slotId, item)

    -- container for item and announcement frame
    local container = AceGUI:Create("SimpleGroup")
    container:SetFullWidth(true)
    container:SetHeight(40)
    container:SetLayout("List")

    -- item row
    local LootOverviewItem = AceGUI:Create("SimpleGroup")
    LootOverviewItem:SetFullWidth(true)
    LootOverviewItem:SetHeight(40)
    -- LootOverviewItem:SetHeight(50)
    LootOverviewItem:SetLayout("Flow")
    container:AddChild(LootOverviewItem)

    local label = AceGUI:Create("Label")
    label:SetImage(item.image)
    label:SetImageSize(40, 40)
    label:SetText(item.link)
    -- label:SetRelativeWidth(0.7)
    label:SetWidth(250)
    label.frame:SetMinResize(250, 40)
    label:SetHeight(40)
    label:SetJustifyH("LEFT")
    label:SetJustifyV("MIDDLE")
    LootOverviewItem:AddChild(label)

    -- button is going to send this message on click (used to change button behaviour without creating new buttons)
    local buttonSendsMessage = "EPGPR_ANNOUNCEMENT_START"

    -- instance of "announcement" widget, that is attached to bottom of the item form when this item slot is announced
    local _UILootOverviewItemAnnouncement

    local editbox = AceGUI:Create("EditBox")
    editbox:DisableButton(true)
    editbox:SetText(item.GP)
    editbox:SetWidth(30)
    LootOverviewItem:AddChild(editbox)
    -- attach to the left button on the right of the frame
    -- editbox:ClearAllPoints()
    -- editbox:SetPoint("RIGHT", button.frame, "LEFT")

    local button = AceGUI:Create("Button")
    button:SetText("Announce")
    button:SetAutoWidth(true)
    button:SetCallback("OnClick", function() EPGPR:SendMessage(buttonSendsMessage, slotId) end)
    LootOverviewItem:AddChild(button)
    -- attach to the right of the frame
    -- button.frame:ClearAllPoints()
    -- button.frame:SetPoint("RIGHT", LootOverviewItem.content, "RIGHT")

    -- callback that is going to be called when a player row is pressed in the announcement frame
    local function giveItemTo(player, GP)
        -- show confirmation popup "Really give this to that for that price?"
        StaticPopup_Show("EPGPR_GIVE_LOOT_POPUP", nil, nil, {player = player, itemLink = item.link, slotId = slotId, GP = GP})
    end

    -- a slot is being announced, change our state accordingly
    local function announceStart(widget, _, announceSlotId)
        -- this slot is being announced
        if slotId == announceSlotId then
            -- modify item row state
            editbox:SetDisabled(true)
            button:SetText("Cancel")
            buttonSendsMessage = "EPGPR_ANNOUNCEMENT_CANCEL"
            -- add two new elements
            -- countdown
            if EPGPR.config.bidding.countdownEnable then
                local statusbar = AceGUI:Create("StatusBar")
                statusbar:SetHeight(20)
                statusbar:SetFullWidth(true)
                local seconds = EPGPR.config.bidding.countdown
                local max = seconds * 50
                local i = max
                statusbar:SetMinMaxValues(0, max)
                statusbar:SetLabel(seconds)
                statusbar:SetValue(max)
                local countdown = C_Timer.NewTicker(0.02, function()
                    i = i - 1
                    statusbar:SetLabel(math.floor(i / 5) / 10)
                    statusbar:SetValue(i)
                end, max)
                statusbar:SetCallback("OnRelease", function() countdown:Cancel() end)
                widget:AddChild(statusbar)
                -- DBM/BigWigs countdown
                SendAddonMessage("D4C", ("U\t%d\t%s"):format(seconds, item.link), "RAID")
            end
            -- create announcement table with bidders and announce to loot
            local GP = tonumber(editbox:GetText()) or item.GP
            _UILootOverviewItemAnnouncement = LootOverviewItemAnnouncement(giveItemTo, GP)
            widget:AddChild(_UILootOverviewItemAnnouncement)
            EPGPR:ChatAnnounceLoot(item.link, GP)
        -- some other slot is being announced
        else
            editbox:SetDisabled(true)
            button:SetDisabled(true)
        end
        widget:DoLayout()
    end

    -- announcement has been finished/canceled, all slots can be re-enabled, and if it was for this slot, the announcement frame cleared
    local function announceFinish(widget, _, announceSlotId)
        -- Remove "announcement" sub-frame and reset own state
        if slotId == announceSlotId and _UILootOverviewItemAnnouncement then
            -- reset item row state
            _UILootOverviewItemAnnouncement = nil
            buttonSendsMessage = "EPGPR_ANNOUNCEMENT_START"
            -- remove countdown in place
            if EPGPR.config.bidding.countdownEnable then
                widget.children[2]:Release()
                table.remove(widget.children, 2)
            end
            -- remove annoncement widget in place
            widget.children[2]:Release()
            table.remove(widget.children, 2)
            button:SetText("Announce")
        end
        button:SetDisabled(false)
        editbox:SetDisabled(false)
        widget:DoLayout()
    end

    -- bid has been placed for this slotId
    local function bid(_, _, player, message, roll)
        -- if there is currently announcement going on, pass the bid to it
        if _UILootOverviewItemAnnouncement then
            _UILootOverviewItemAnnouncement:Fire("Bid", player, message, roll)
        end
    end

    container:DoLayout()

    -- save our slotId in userdata
    container:SetUserData("slotId", slotId)

    -- callbacks
    container:SetCallback("AnnounceStart", announceStart)
    container:SetCallback("AnnounceFinish", announceFinish)
    container:SetCallback("Bid", bid)

    return container
end
