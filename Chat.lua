local EPGPR, SendChatMessage, UnitName = EPGPR, SendChatMessage, UnitName

-- When loot is being announced
function EPGPR:ChatAnnounceLoot(itemLink, GP)
    SendChatMessage(itemLink .. " " .. tostring(GP) .. " GP", "RAID_WARNING");
    SendChatMessage("whisper '!need' for main spec", "RAID")
    SendChatMessage("whisper '!off' for off spec", "RAID")
    SendChatMessage("/roll for Donyshko spec", "RAID")
end

-- When encounter has been won and EP was awarded
function EPGPR:ChatEncounterEPAwarded(name, EP)
    SendChatMessage(name .. " has been defeated, " .. EP .. " EP is awarded to the raid", "GUILD")
end

-- When item has been given using the app
function EPGPR:ChatItemDistributed(name, itemLink, GP)
    SendChatMessage(itemLink .. " has been given to " .. name .. (GP and (" for " .. GP .. " GP") or " without EPGP"), "GUILD")
end

-- When a bit has been placed on an item
function EPGPR:ChatBidPlaced(name, message, PR)
    SendChatMessage(name .. " (" .. message .. "), priority " .. PR, "RAID")
end

-- When Guild EPGP is changed by percent
function EPGPR:ChatGuildEPGPChanged(percent)
    SendChatMessage(("Guild EPGP changed by %d percent"):format(percent), "GUILD")
end
