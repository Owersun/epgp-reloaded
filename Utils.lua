local EPGPR, SendChatMessage, GetRaidRosterInfo, GetItemInfo, GetInstanceInfo, time, MAX_RAID_MEMBERS = EPGPR, SendChatMessage, GetRaidRosterInfo, GetItemInfo, GetInstanceInfo, time, MAX_RAID_MEMBERS

local function getItemId(link)
    local id = string.match(link, '^|c%x+|Hitem:(%d+):')
    return id and tonumber(id) or nil
end

-- many UI addons that introduce tooltip under a cursor implement it the way, the tooltip is constantly redrawn when cursor is hovering
-- to reduce pressure of constant GP calculations we cache every item we see into memory
-- barely session cache would exceed a hundred items, which is a good tradeoff between memory and cpu
local gpValues = {}

-- Calculate GP value of an item from its link
function EPGPR:ItemGPValue(itemLink)
    if gpValues[itemLink] then return gpValues[itemLink] end
    local _, link, rarity, ilvl, _, _, _, _, slot = GetItemInfo(itemLink)
    -- override from options?
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

-- There is a possibility on every encounter end, that basic EP is going to have bonus additions
function EPGPR:calculateEncounterBonus(members)
    -- calculate empty slots in the raid, and, if bonus for empty slots is enabled, return the amount of bonus EP for this instance, or 0
    local function calculateMissingManBonus(maxInstancePlayers, instanceConfig)
        if not self.config.missingManBonus or not instanceConfig.missingManBonus then return 0 end
        local count = 0
        for _ in pairs(members) do count = count + 1 end
        return math.max(0, maxInstancePlayers - count) * instanceConfig.EP
    end

    local _, _, _, _, maxPlayers, _, _, instanceID, _, _ = GetInstanceInfo()
    local instanceConfig = self.config.instance[instanceID] or {}

    return calculateMissingManBonus(maxPlayers or 0, instanceConfig)
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
        local bonusEP = EPGPR:calculateEncounterBonus(names)
        self:GuildAddEP(names, encounter.EP + bonusEP)
        self:ChatEncounterEPAwarded(encounter.name, encounter.EP, bonusEP)
        self:AddHistory("RAID", encounter.name, encounter.EP + bonusEP, nil)
    end
end

-- Add the name to the standby list
function EPGPR:StandbyAdd(name)
    local standbyList = self.config.standby.list or {}
    if standbyList[name] then SendChatMessage("You are already in the standby list", "WHISPER", nil, name); return; end
    standbyList[name] = true
    self:ConfigSet({ standby = { list = standbyList }})
    SendChatMessage("You have been added to the standby list", "WHISPER", nil, name)
end

-- Add a history record and broadcast too all apps in the guild
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

-- Save a connection alt-main
function EPGPR:SetAlt(alt, main)
    local altList = EPGPR.config.alts.list or {}
    -- player can be alt of only one other player
    if main and altList[alt] then
        StaticPopup_Show("EPGPR_ERROR_POPUP", nil, nil, { text = ("Player \"%s\" is already set as alt of \"%s\""):format(alt, altList[alt]) })
        return false
    end
    -- main must be member of the guild
    if main and not self.State.guildRoster[main] then
        StaticPopup_Show("EPGPR_ERROR_POPUP", nil, nil, { text = ("Player \"%s\" is not found in the guild"):format(main) })
        return false
    end
    -- main cannot be already an alt of someone else
    if main and altList[main] then
        StaticPopup_Show("EPGPR_ERROR_POPUP", nil, nil, { text = ("Player \"%s\" is set as alt of \"%s\""):format(main, altList[main]) })
        return false
    end
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
