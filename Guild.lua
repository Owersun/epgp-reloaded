local EPGPR, GetNumGuildMembers, GetGuildRosterInfo, GuildRosterSetOfficerNote = EPGPR, GetNumGuildMembers, GetGuildRosterInfo, GuildRosterSetOfficerNote
local max, floor, unpack = math.max, math.floor, unpack

-- Return player EP/GP and priority from his officer notes
local function guildGetMemeberEPGP(officerNote)
    local noteEP, noteGP = officerNote:match("(%d+),(%d+)")
    local EP = noteEP or 0;
    local GP = noteGP or EPGPR.config.GP.basegp;
    return tonumber(EP), tonumber(GP), floor((EP / GP) * 100) / 100
end

-- Get guild member data from the guild roster, and return it in format we work with
local function guildFetchMember(i)
    local name, rank, _, _, _, _, _, officernote, _, _, classEnglish = GetGuildRosterInfo(i);
    if not name then return nil end
    local playerName = name:match("(%S+)-%S+")
    local EP, GP, PR = guildGetMemeberEPGP(officernote)
    return playerName, {
        i, -- [1]
        rank, -- [2]
        classEnglish, -- [3]
        EP, -- [4]
        GP, -- [5]
        PR  -- [6]
    }
end

-- refresh guild roster
function EPGPR:GuildRefreshRoster()
    local guildRoster, guildMembers = {}, GetNumGuildMembers()
    for i = 1, guildMembers do
        local playerName, playerData = guildFetchMember(i)
        if playerName then guildRoster[playerName] = playerData end
    end
    self.State.guildRoster = guildRoster
end

-- Refresh guild member in local state and return his data
function EPGPR:GuildGetMemberInfo(name, considerAlts)
    if considerAlts then
        -- look in the alts list
        local alts = self.config.alts.list or {}
        name = alts[name] or name
    end
    -- Refresh guild member info to the most recent state
    if self.State.guildRoster[name] then
        local playerName, playerData = guildFetchMember(self.State.guildRoster[name][1])
        if name == playerName then self.State.guildRoster[name] = playerData end
        local i, playerRank, playerClass, EP, GP, PR = unpack(self.State.guildRoster[name])
        -- we're going to return either fresh data of the player, or our cache data by the name, with i being null in that case,
        -- indicating that the player data is stale and must not be changed by index in this case.
        -- this allows showing data in cases of viewing forms and bidding, and prevent wrong writes (with silent fails)
        if name ~= playerName then EPGPR:Print('Found ' .. playerName .. ' on index of ' .. name) end
        return name, name == playerName and i or nil, playerRank, playerClass, EP, GP, PR
    end
    -- no guild member by that name found at all
    return name, nil, "?", "?", 0, 0, 0
end

-- Change guild member EP/GP values
function EPGPR:GuildChangeMemberEPGP(name, diffEP, diffGP, considerAlts)
    local playerName, i, _, _, oldEP, oldGP, _ = self:GuildGetMemberInfo(name, considerAlts)
    if i == nil then return end -- guild member index cannot be determined properly
    local newEP = floor(max(0, oldEP + tonumber(diffEP or 0)))
    local newGP = floor(max(self.config.GP.basegp, oldGP + tonumber(diffGP or 0)))
    if newEP ~= oldEP or newGP ~= oldGP then
        -- change values
        GuildRosterSetOfficerNote(i, newEP .. "," .. newGP)
        -- refresh the member that we just updated
        self:GuildGetMemberInfo(playerName, false)
    end
end

-- Decay guild EP/GP by percentage
function EPGPR:GuildChangeEPGP(percent)
    local change = tonumber(percent)
    if (tostring(change) ~= tostring(percent)) then
        self:Print("GuildChangeEPGP " .. tostring(percent) .. " percent is not a number")
        return
    end
    local basegp, guildMembers = self.config.GP.basegp, GetNumGuildMembers()
    for i = 1, guildMembers do
        local _, playerData = guildFetchMember(i)
        local _, _, _, oldEP, oldGP, _ = unpack(playerData)
        local newEP = floor(max(0, oldEP * (100 + percent) / 100))
        local newGP = floor(max(basegp, oldGP * (100 + percent) / 100))
        if newEP ~= oldEP or newGP ~= oldGP then GuildRosterSetOfficerNote(i, newEP .. "," .. newGP) end
    end
    self:GuildRefreshRoster()
    self:ChatGuildEPGPChanged(percent)
    self:AddHistory("GUILD", "Guild EPGP change " .. percent .. "%", nil, nil)
end

-- Add EP to all names from the list that are found in the guild
-- names have to be in the format "{[nameN] = ratioN, [nameM] = ratioM, ...}
function EPGPR:GuildAddEP(names, EP)
    -- filter out all alts on the list and move their EPRating to their mains
    local alts = self.config.alts.list or {}
    for alt, main in pairs(alts) do -- iterate through alts table
        if names[alt] then -- if there is alt in the list
            names[main] = max(names[main] or 0, names[alt]) -- assign biggest EPRatio between alt and main to the main
            names[alt] = nil -- remove the alt from the list
        end
    end
    self:GuildRefreshRoster()
    -- change all EP of people in the list by the ratio
    for name, ratio in pairs(names) do
        -- we don't need to consider alts here as they are already replaced by their mains
        self:GuildChangeMemberEPGP(name, floor(EP * ratio), nil, false)
    end
end

-- Apply increased base guild GP
function EPGPR:GuildApplyBaseGP()
    local basegp, guildMembers, n = self.config.GP.basegp, GetNumGuildMembers(), 0
    for i = 1, guildMembers do
        local _, playerData = guildFetchMember(i)
        local _, _, _, EP, oldGP, _ = unpack(playerData)
        local newGP = max(basegp, oldGP)
        if newGP ~= oldGP then
            GuildRosterSetOfficerNote(i, EP .. "," .. newGP)
            n = n + 1
        end
    end
    self:GuildRefreshRoster()
    self:Print("Base GP changed for " .. tostring(n) .. " members")
end
