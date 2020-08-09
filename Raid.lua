local EPGPR, MAX_RAID_MEMBERS, GetRaidRosterInfo = EPGPR, MAX_RAID_MEMBERS, GetRaidRosterInfo

-- Award/Substract EP from the whole raid (excluding standby list, excluding offline people)
function EPGPR:RaidAddEP(EP)
    local change = tonumber(EP)
    if (tostring(change) ~= tostring(EP)) then
        self:Print("RaidAddEP " .. tostring(EP) .. " value is not a number")
        return
    end
    local names = {}
    for i = 1, MAX_RAID_MEMBERS do
        local name, _, _, _, _, _, _, online = GetRaidRosterInfo(i)
        if name and online then names[name] = 1 end
    end
    self:GuildAddEP(names, change)
    self:ChatRaidEPGiven(change)
    self:AddHistory("RAID", "Raid Adjust", change, nil)
end
