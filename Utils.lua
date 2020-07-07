local EPGPR, SendChatMessage, GetRaidRosterInfo, GetItemInfo, time, MAX_RAID_MEMBERS = EPGPR, SendChatMessage, GetRaidRosterInfo, GetItemInfo, time, MAX_RAID_MEMBERS

local function getItemId(link)
    local id = string.match(link, '^|c%x+|Hitem:(%d+):')
    return id and tonumber(id) or nil
end

-- many UI addons that introduce tooltip under cursor implement it the way, the tooltip is constantly redrawn under the cursor
-- to reduce pressure on constant calculation of GP we cache every item we see into memory
-- barely session cache will exceed hundred items, which is a good tradeoff between memory and cpu
local gpValues = {}

-- Calculate GP value of an item from its link
function EPGPR:ItemGPValue(itemLink)
    if gpValues[itemLink] then return gpValues[itemLink] end
    local _, link, rarity, ilvl, _, _, _, _, slot = GetItemInfo(itemLink)
    -- override?
    local id = getItemId(link)
    if self.config.item[id] then
        rarity, ilvl, slot = unpack(self.config.item[id])
    end
    gpValues[itemLink] = math.floor(4.83 * (2 ^ (ilvl/26 + (rarity - 4))) * (self.config.GP.slotModifier[slot] or 1))
    return gpValues[itemLink]
end

-- Item was given to the player for GP using the announcement process
-- Adjust player GP value
-- Save history row for the event
function EPGPR:ItemDistributed(player, itemLink, GP)
    if GP and GP > 0 then EPGPR:GuildChangeMemberEPGP(player, nil, GP, true) end
    self:ChatItemDistributed(player, itemLink, GP)
    self:AddHistory(player, itemLink, nil, GP)
end

-- Encounter has been won
function EPGPR:EncounterWon(encounterId)
    local encounter = self.config.encounter[encounterId]
    if encounter and encounter.track and encounter.EP > 0 then
        local names = {}
        -- everyone from standby list first, as they can have reduced EP ratio
        local standbyList = self.config.standby.list or {}
        local EPRatio = self.config.standby.EPRatio or 1
        for name, _ in pairs(standbyList) do
            names[name] = EPRatio
        end
        -- raid members last, as they can jump on top of standby list, and they always should have full EP
        for i = 1, MAX_RAID_MEMBERS do
            local name, _, _, _, _, _, _, online = GetRaidRosterInfo(i)
            if name and online then names[name] = 1 end
        end
        self:GuildAddEP(names, encounter.EP)
        self:ChatEncounterEPAwarded(encounter.name, encounter.EP)
        self:AddHistory("RAID", encounter.name, encounter.EP, nil)
    end
end

-- Add name to the standby list
function EPGPR:StandbyAdd(name)
    local standbyList = self.config.standby.list or {}
    if standbyList[name] then SendChatMessage("You are already in the standby list", "WHISPER", nil, name); return; end
    standbyList[name] = true
    self:ConfigSet({ standby = { list = standbyList }})
    SendChatMessage("You have been added to the standby list", "WHISPER", nil, name)
end

-- Add history record and broadcast too all other apps in the guild
function EPGPR:AddHistory(targetPlayer, comment, EP, GP)
    local author, timestamp = UnitName("player"), time()
    self:SaveHistoryRow(author, targetPlayer, comment, EP, GP, timestamp)
    self:Broadcast("SaveHistoryRow", author, targetPlayer, comment, EP, GP, timestamp)
end

-- Add a row into persistent history table
function EPGPR:SaveHistoryRow(author, targetPlayer, comment, EP, GP, timestamp)
    table.insert(EPGPRHISTORY, { author, targetPlayer, comment, EP, GP, timestamp or time() })
end

-- When a bid has been placed by a player name, there are many things to take in account and return:
-- - is this player part of the current group? whisper could arrive from absolutely random person
-- - is this player part of the guild? only guild memers has any priority, but actually any group member can demand the loot
-- - what is this player class? for display
-- - what is this player EP/GP priority? for actual bid rating
function EPGPR:GetBidderProperties(name)
    -- check the name is in our group
    for i = 1, MAX_RAID_MEMBERS do
        local playerName, _, _, _, _, playerClass = GetRaidRosterInfo(i);
        if playerName == name then
            -- fetch the guild member, considering alts
            local _, _, playerRank, _, EP, GP, PR = EPGPR:GuildGetMemberInfo(name, true)
            -- return the information immideately, where "rank" and "PR" are going to be empty if the player is not part of the guild
            return { name = name, rank = playerRank, class = playerClass, EP = EP, GP = GP, PR = PR } -- bail out as soon as possible
        end
    end
    return nil
end

-- Set connection alt-main
function EPGPR:SetAlt(alt, main)
    local altList = EPGPR.config.alts.list or {}
    -- main must be member of the guild
    if main and not self.State.guildRoster[main] then return false end
    EPGPR:ConfigSet({ alts = { list = false }})
    altList[alt] = main
    EPGPR:ConfigSet({ alts = { list = altList }})
    return true
end

-- recursively merge b to a
EPGPR.mergeTables = function(a, b)
    if type(b) ~= "table" or type(a) ~= "table" then return b end
    for k, v in pairs(b) do
        a[k] = EPGPR.mergeTables(a[k], v)
    end
    return a
end
