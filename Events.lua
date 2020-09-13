local EPGPR, GetLootSlotLink, GetLootSlotInfo, GetNumLootItems, GetMasterLootCandidate, LootSlotHasItem, UnitName = EPGPR, GetLootSlotLink, GetLootSlotInfo, GetNumLootItems, GetMasterLootCandidate, LootSlotHasItem, UnitName

-- WoW events we hook to, when activated
local events = { "LOOT_OPENED", "LOOT_CLOSED", "LOOT_SLOT_CLEARED", "ENCOUNTER_END", "GROUP_ROSTER_UPDATE", "CHAT_MSG_SYSTEM", "CHAT_MSG_WHISPER", "CHAT_MSG_LOOT" }
-- Our internal messages we dispatch and listen to
local messages = { "EPGPR_ANNOUNCEMENT_START", "EPGPR_ANNOUNCEMENT_CANCEL" }

-- AceBucket handler that squashes rapid guild roster update events into one call
local guildUpdateHandler

-- Register all events we need to work being active
function EPGPR:EventsRegister()
    guildUpdateHandler = self:RegisterBucketEvent("GUILD_ROSTER_UPDATE", 0.2, "GuildRefreshRoster")
    for _, v in ipairs(events) do self:RegisterEvent(v) end
    for _, v in ipairs(messages) do self:RegisterMessage(v) end
end

-- Release all callbacks
function EPGPR:EventsUnregister()
    for _, v in ipairs(events) do self:UnregisterEvent(v) end
    for _, v in ipairs(messages) do self:UnregisterMessage(v) end
    self:UnregisterBucket(guildUpdateHandler)
end

-- Loot items in currently opened loot form. We need it to track what exactly was distributed at the time slot is cleared
local itemsInLoot = {}

-- Loot was opened
function EPGPR:LOOT_OPENED(_, autoLoot, isFromItem)
    itemsInLoot = {}
    -- build list of items in opened loot
    for slotID = 1, GetNumLootItems() do
        if LootSlotHasItem(slotID) then
            local lootIcon, lootName, _, _, _, _, _, _, _ = GetLootSlotInfo(slotID);
            local itemLink = GetLootSlotLink(slotID)
            if itemLink then
                itemsInLoot[slotID] = {
                    image = lootIcon,
                    link = itemLink,
                    name = lootName,
                    GP = self:ItemGPValue(itemLink),
                    candidate = nil,
                };
            end
        end
    end
    -- if the resulting table is not empty - open the loot overview form
    if not (autoLoot or isFromItem) and next(itemsInLoot) ~= nil then
        self:UILootOverview():Fire("ShowItems", itemsInLoot)
    end
end

-- Loot was closed
function EPGPR:LOOT_CLOSED(_)
    itemsInLoot = {}
    self:UILootOverview():Hide()
end

-- Performed at an encounter (boss fight) finish
function EPGPR:ENCOUNTER_END(_, encounterId, _, _, _, success)
    if success == 1 then self:EncounterWon(encounterId) end
end

-- Left/Joined a group
function EPGPR:GROUP_ROSTER_UPDATE(_)
    self:DetermineTheState()
end

-- We (maybe) got masterlooter role, or lost it
function EPGPR:PARTY_LOOT_METHOD_CHANGED(_)
    self:DetermineTheState()
end

-- Pick up messages we are interested in from system messages (in yellow)
function EPGPR:CHAT_MSG_SYSTEM(_, message)
    local name, roll = message:match("(%S+) выбрасывает (%d+) %(1%-100%)") -- watch for rolls
    if name and self.config.bidding.considerRoll then self:UILootOverview():Fire("Bid", name, nil, tonumber(roll)) end
end

-- Pick up messages we are interested in from whispers
function EPGPR:CHAT_MSG_WHISPER(_, input, _, _, _, name)
    local message = input:lower()
    if self.config.bidding.messages[message] then self:UILootOverview():Fire("Bid", name, message, nil) end
    if self.config.standby.whisper == message then self:StandbyAdd(name) end
end

-- This hook is going to be executed before every attempt to distribute loot through master loot
-- We save here the loot and to whom it is going to be attempted to be given (which can fail)
EPGPR.GiveMasterLootHook = function(slotId, candidateId, ...)
    if itemsInLoot[slotId] then
        itemsInLoot[slotId].candidate = GetMasterLootCandidate(slotId, candidateId)
    end
end

--- This handler gets called when a loot slot is cleared (loot item is given to someone).
--  This is where we enhance it with the candidate we gave it to by master loot, and pass to the LootOverview handler
function EPGPR:LOOT_SLOT_CLEARED(_, slotId, ...)
    self:UILootOverview():Fire("ClearSlot", slotId, itemsInLoot[slotId])
end

-- Announcement of an item start (sent by Widget-LootOverviewItem button)
function EPGPR:EPGPR_ANNOUNCEMENT_START(_, slotId)
    self:UILootOverview():Fire("AnnounceSlot", slotId)
end

-- Announcement has been cancelled (sent by the same button in state "Cancel")
function EPGPR:EPGPR_ANNOUNCEMENT_CANCEL(_)
    self:UILootOverview():Fire("AnnounceSlot", nil)
end

-- Temporary function to track Ahn'Quiraj stash keys looters
function EPGPR:CHAT_MSG_LOOT(_, text, _, _, _, playerName2, _, _, _, _, _, _, _, _, _, _, _, _)
    local item = text:match("|c%x%x%x%x%x%x%x%x|Hitem:21762.+|h|r")
    if item and playerName2 ~= UnitName("player") then
        self:Print((">>>>>>>>>> [|cffff0000|Hplayer:%s:WHISPER:%s|h%s|h|r] looted %s <<<<<<<<<<"):format(playerName2, playerName2, playerName2, item));
    end
end
