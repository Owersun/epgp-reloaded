local EPGPR, SendChatMessage = EPGPR, SendChatMessage

-- When loot is being announced
function EPGPR:ChatAnnounceLoot(itemLink, GP)
    SendChatMessage(("%s %d GP"):format(itemLink, GP), "RAID_WARNING");
    SendChatMessage("whisper '!need' for main spec / full price", "RAID")
    SendChatMessage("whisper '!off' for off spec / half price", "RAID")
    SendChatMessage("/roll for Bank spec / free", "RAID")
end

-- When encounter has been won and EP was awarded
function EPGPR:ChatEncounterEPAwarded(name, EP)
    SendChatMessage(name .. " has been defeated, " .. EP .. " EP is awarded to the raid", "GUILD")
end

-- When item has been given using the app
function EPGPR:ChatItemDistributed(name, itemLink, GP)
    SendChatMessage(itemLink .. " has been given to " .. name .. (GP and (" for " .. GP .. " GP") or " without EPGP"), "GUILD")
end

-- When a bid has been placed on an item
function EPGPR:ChatBidPlaced(name, message, EP, GP, PR)
    SendChatMessage(("%s (%s) (%d/%d) %.2f PR"):format(name, message, EP, GP, PR), "RAID")
end

-- When someone rolled for an item
function EPGPR:ChatRollPlaced(name, roll)
    SendChatMessage(("%s rolled %d"):format(name, roll), "RAID")
end

-- When Guild EPGP is changed by the percent
function EPGPR:ChatGuildEPGPChanged(percent)
    SendChatMessage(("Guild EPGP changed by %d percent"):format(percent), "GUILD")
end

-- List items in the given list to raid chat
function EPGPR:ChatListLoot(items)
    for _, item in ipairs(items) do
        SendChatMessage(("%s %d GP"):format(item.link, item.GP), "RAID")
    end
end
