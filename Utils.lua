local EPGPR, SendChatMessage, GetRaidRosterInfo, MAX_RAID_MEMBERS = EPGPR, SendChatMessage, GetRaidRosterInfo, MAX_RAID_MEMBERS

-- Calculate GP value of an item from its link
function EPGPR:ItemGPValue(itemLink)
    local _, _, rarity, ilvl, _, _, _, _, slot = GetItemInfo(itemLink)
    return math.floor(4.83 * (2 ^ (ilvl/26 + (rarity - 4))) * (self.config.GP.slotModifier[slot] or 1))
end

-- Item was given to the player for GP using the announcement process
-- Adjust player GP value
-- Save history row for the event
function EPGPR:ItemDistributed(player, itemLink, GP)
    if GP and GP > 0 then EPGPR:GuildChangeMemberEPGP(player, nil, GP) end
    self:ChatItemDistributed(player, itemLink, GP)
    self:SaveHistoryRow(player, itemLink, nil, GP)
end

-- Encounter has been won
function EPGPR:EncounterWon(encounterId)
    EPGPR:Print("Encounter won " .. encounterId)
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
        self:SaveHistoryRow(nil, encounter.name, encounter.EP, nil)
    end
end

-- Add name to the standby list
function EPGPR:StandbyAdd(name)
    local standbyList = self.config.standby.list or {}
    if standbyList[name] then SendChatMessage("You are already in the standby list", "WHISPER", nil, name); return; end
    standbyList[name] = true
    self:ConfigSet({standby = { list = standbyList }})
    SendChatMessage("You have been added to the standby list", "WHISPER", nil, name)
end

-- Check that anyone from standby list has joined the raid and should go out of it
-- @Not used
function EPGPR:CheckStandbyList()
    local standbyList = self.config.standby.list or {}
    for i = 1, MAX_RAID_MEMBERS do
        local raidName = GetRaidRosterInfo(i)
        if raidName then standbyList[raidName] = nil end
    end
    self.config.standby.list = standbyList
end

-- Add a row into persistent history table
function EPGPR:SaveHistoryRow(targetPlayer, comment, EP, GP)
    table.insert(EPGPRHISTORY, { UnitName("player"), targetPlayer, comment, EP, GP, time() })
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
            -- fetch the guild member
            local _, playerRank, _, _, _, playerPR = EPGPR:GuildGetMemberInfo(name)
            -- return the information immideately, where "rank" and "PR" are going to be empty if the player is not part of the guild
            return {name = playerName, rank = playerRank or "?", class = playerClass or "?", PR = playerPR or 0} -- bail out as soon as possible
        end
    end
    return nil
end

-- Set connection alt-main
function EPGPR:SetAlt(alt, main)
    local altList = EPGPR.config.alts.list
    EPGPR:ConfigSet({alts = { list = false }})
    altList[alt] = main
    EPGPR:ConfigSet({alts = { list = altList}})
end

-- recursively merge b to a
EPGPR.mergeTables = function(a, b)
    if type(b) ~= "table" or type(a) ~= "table" then return b end
    for k, v in pairs(b) do
        a[k] = EPGPR.mergeTables(a[k], v)
    end
    return a
end
