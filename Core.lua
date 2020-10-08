local IsInRaid, ItemRefTooltip, GameTooltip, GetLootMethod, CanEditOfficerNote, StaticPopup_Show, StaticPopup_Hide = IsInRaid, ItemRefTooltip, GameTooltip, GetLootMethod, CanEditOfficerNote, StaticPopup_Show, StaticPopup_Hide
EPGPR = LibStub("AceAddon-3.0"):NewAddon("EPGPR", "AceEvent-3.0", "AceConsole-3.0", "AceHook-3.0", "AceComm-3.0", "AceSerializer-3.0", "AceBucket-3.0")

-- Local instances of ACE Libraries
EPGPR.Libs = {
    AceGUI = LibStub("AceGUI-3.0"),
    Locale = LibStub("AceLocale-3.0"):GetLocale("EPGPR"),
}
-- Constants that are used here and there, like message names, channel names to send/receive message and so on
EPGPR.Const = {
    AppName = "EPGPReloaded",
    CommunicationPrefix = "EPGPR"
}
-- Our state
EPGPR.State = {
    -- nil: we don't know our state, true: we're active, false: we're disabled (and shouldn't be enabled for this session / in this group)
    active = nil,
    -- Our internal guild roster cache, as we need to look into it quite often
    guildRoster = {},
}

-- Initialize
function EPGPR:OnInitialize()
    -- Initialize saved variables
    EPGPRHISTORY = EPGPRHISTORY or {}
    EPGPRCONFIG = EPGPRCONFIG or {}
    -- Read configuration
    self:ConfigSetup()
    -- Register for addon-addon communication messages
    self:RegisterComm(self.Const.CommunicationPrefix)
    -- Register slash command
    self:RegisterChatCommand("epgp", "UIEPGPFrame")
    -- Hook tooltips to add the line "GP Value: "
    self:HookScript(GameTooltip, "OnTooltipSetItem", EPGPR.OnTooltipSetItem)
    self:HookScript(ItemRefTooltip, "OnTooltipSetItem", EPGPR.OnTooltipSetItem)
end

-- The part where we start
function EPGPR:OnEnable()
    -- Register events that we need to operate in any state (active/inactive)
    self:RegisterEvent("PARTY_LOOT_METHOD_CHANGED")
    -- Print we are done
    self:Print("Enabled. Type /epgp to show options.")
    -- find out our own state after the start (for cases of ui reload)
    self:DetermineTheState()
end

-- Ther part where we end
function EPGPR:OnDisable()
    -- Deactivate forcefully
    self:Deactivate()
    -- Release events
    self:UnregisterEvent("PARTY_LOOT_METHOD_CHANGED")
    self:Print("Disabled")
end

-- Determine/Ask for our state (enabled/disabled)
function EPGPR:DetermineTheState()
    local _, isMasterLooter = GetLootMethod()
    local isInRaid = IsInRaid("player")
    if self.State.active == true and not (isInRaid or isMasterLooter == 0) then
        -- we're active and left the group/lost master looter
        self:Deactivate() -- implicitly
    elseif self.State.active == false and not isInRaid then
        -- we're disabled and left the group
        self.State.active = nil -- reset the state
    elseif self.State.active == nil and isMasterLooter == 0 and CanEditOfficerNote() then
        -- we're in a blank state and are master looter and can edit officer notes (it doesn't make sense otherwise)
        StaticPopup_Show("EPGPR_ACTIVATE_POPUP") -- Popup dialog is going to set us to either enabled or disabled
    end
end

-- The function is going to be called when all conditions are met:
-- We are in a guild
-- We can edit officer notes
-- We are in a group
-- We are master looter
-- Dialog confirmed we are going to use EPGPR for this raid
function EPGPR:Activate()
    if self.State.active then return end
    self.State.active = true
    -- Refresh guild roster
    EPGPR:GuildRefreshRoster()
    -- Register our events
    self:EventsRegister()
    -- Hook to master loot function to track all items being distributed
    if not self:IsHooked("GiveMasterLoot") then self:Hook("GiveMasterLoot", self.GiveMasterLootHook, true) end
    self:Print("Activated")
end

-- Unregister all event handlers used to distribute loot in the group
function EPGPR:Deactivate()
    if self.State.active ~= true then return end
    self.State.active = nil
    StaticPopup_Hide("EPGPR_ACTIVATE_POPUP")
    -- Unhook functions we monitor
    if self:IsHooked("GiveMasterLoot") then self:Unhook("GiveMasterLoot") end
    -- Unregister our events
    self:EventsUnregister()
    -- Clean standby list in case we left the raid
    if not IsInRaid("player") then self:ConfigSet({standby = { list = false }}) end
    self:Print("Deactivated")
end

-- Tooltips hook to add "GP Value: " hint to them
EPGPR.OnTooltipSetItem = function(frame, ...)
    local _, itemLink = frame:GetItem()
    if itemLink then
        local itemId = itemLink:match("item:(%d+):")
        if itemId then Item:CreateFromItemID(tonumber(itemId)):ContinueOnItemLoad(function()
            local GP = EPGPR:ItemGPValue(itemLink)
            frame:AddLine("GP Value: " .. tostring(GP))
        end) end
    end
end
