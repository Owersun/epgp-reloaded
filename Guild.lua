local EPGPR, GetNumGuildMembers, GetGuildRosterInfo, GuildRosterSetOfficerNote = EPGPR, GetNumGuildMembers, GetGuildRosterInfo, GuildRosterSetOfficerNote
local max, floor, unpack = math.max, math.floor, unpack

-- Return player EP/GP and priority from its officer note
local function guildGetMemeberEPGP(officerNote)
    local noteEP, noteGP = officerNote:match("(%d+),(%d+)")
    local EP = noteEP or 0;
    local GP = noteGP or EPGPR.config.GP.basegp;
    return EP, GP, floor((EP / GP) * 100) / 100
end

-- Get guild member data in format we work on from roster
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
    -- Refresh guildmember info to the most recent state
    if self.State.guildRoster[name] then
        local playerName, playerData = guildFetchMember(self.State.guildRoster[name][1])
        if name == playerName then self.State.guildRoster[name] = playerData end
        local i, playerRank, playerClass, EP, GP, PR = unpack(self.State.guildRoster[name])
        -- we're going to return either fresh data of the player, or our cache data by the name, with i being null in that case,
        -- indicating that the player data is stale and must not be changed by index in this case.
        -- this allows showing data in most cases of viewing forms and bidding, and prevent wrong writes (with silent fails)
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
        -- refresh member that we just updated
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
    self:ChatGuildEPGPChanged(percent)
    self:AddHistory("GUILD", "Guild EPGP change " .. percent .. "%", nil, nil)
end

-- Add EP to all names from the list that are found in the guild
-- names has to be in the format "{[nameN] = ratioN, [nameM] = ratioM, ...}
function EPGPR:GuildAddEP(names, EP)
    -- filter out all alts on the list and converge their EPRating to their mains
    local alts = self.config.alts.list or {}
    for alt, main in pairs(alts) do -- iterate through alts table
        if names[alt] then -- if there is alt in the list
            names[main] = math.max(names[main] or 0, names[alt]) -- assign biggest EPRatio between alt and main to the main
            names[alt] = nil -- remove the alt from the list
        end
    end
    self:GuildRefreshRoster()
    -- change all people in the list EP by the ratio
    for name, ratio in pairs(names) do
        -- we don't need to consider alts here as they are already replaced by their mains
        self:GuildChangeMemberEPGP(name, math.floor(EP * ratio), nil, false)
    end
end
