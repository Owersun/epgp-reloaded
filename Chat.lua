local EPGPR, SendChatMessage = EPGPR, SendChatMessage
local L = EPGPR.Libs.Locale

-- When loot is being announced
function EPGPR:ChatAnnounceLoot(itemLink, GP)
    local myself = UnitName("player")
    SendChatMessage(("%s %d GP"):format(itemLink, GP), "RAID_WARNING");
    SendChatMessage(L["'/w %s !need' for main spec / %d GP"]:format(myself, GP), "RAID")
    SendChatMessage(L["'/w %s !off' for off spec / %d GP"]:format(myself, GP), "RAID")
    SendChatMessage(L["'/roll' as greed / %d GP"]:format(GP), "RAID")
end

-- When raid EP has been given/taken
function EPGPR:ChatRaidEPGiven(EP)
    local message = EP > 0 and "%d EP added to the Raid" or "%d EP substracted from the Raid"
    SendChatMessage((L[message]):format(math.abs(EP)), "RAID")
end

-- When encounter has been won and EP was awarded
function EPGPR:ChatEncounterEPAwarded(name, EP, bonusEP)
    SendChatMessage((L["%s has been defeated, %s EP awarded to the raid"]):format(name, bonusEP > 0 and (EP .. " + " .. bonusEP) or tostring(EP)), "GUILD")
end

-- When item has been given using the app
function EPGPR:ChatItemDistributed(name, itemLink, GP)
    local message = GP and "%s has been given to %s for %d GP" or "%s has been given to %s without EPGP"
    SendChatMessage(L[message]:format(itemLink, name, GP), "GUILD")
end

-- When a bid has been placed on an item
function EPGPR:ChatBidPlaced(name, message, EP, GP, PR)
    SendChatMessage(("%s (%s) (%d/%d) %.2f PR"):format(name, message, EP, GP, PR), "RAID")
end

-- When someone rolled for an item
function EPGPR:ChatRollPlaced(name, roll)
    SendChatMessage((L["%s rolled %d"]):format(name, roll), "RAID")
end

-- When Guild EPGP is changed by the percent
function EPGPR:ChatGuildEPGPChanged(percent)
    SendChatMessage((L["Guild EPGP changed by %d percent"]):format(percent), "GUILD")
end

-- List items in the given list to raid chat
function EPGPR:ChatListLoot(items)
    for _, item in ipairs(items) do
        SendChatMessage(("%s %d GP"):format(item.link, item.GP), "RAID")
    end
end
