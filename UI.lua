local EPGPR = EPGPR

-- Structure that holds forms initializers, every key here is a function that when called return _new_ AceGUI frame
EPGPR.UI = {
    EPGPR = nil,
    LootOverview = nil,
    LootOverviewItem = nil,
    LootOverviewItemAnnounce = nil,
}

-- Get interface theme
-- local UITheme
-- if EPGPR.config.general.ui == "default" then UITheme = EPGPR.UI.EPGPR() else UITheme = EPGPR.UI.EPGPRGW() end

-- Console command /epgp
local _UIEPGPFrame
function EPGPR:UIEPGPFrame()
    -- Don't duplicate if we're already shown
    -- if not _UIEPGPFrame then _UIEPGPFrame = UITheme end
	if not _UIEPGPFrame then _UIEPGPFrame = EPGPR.UI.EPGPR() end -- UITheme
    _UIEPGPFrame:Show()
end

-- LootOverview frame
local _UILootOverview
function EPGPR:UILootOverview()
    -- Never duplicate
    if not _UILootOverview then _UILootOverview = EPGPR.UI.LootOverview() end
    return _UILootOverview
end

StaticPopupDialogs["EPGPR_ACTIVATE_POPUP"] = {
    text = "Do you want to use EPGP Reloaded to manage loot?",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function()
        EPGPR:Activate()
    end,
    OnCancel = function()
        EPGPR.State.active = false;
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

StaticPopupDialogs["EPGPR_GIVE_LOOT_POPUP"] = {
    text = "",
    button1 = "Yes",
    button2 = "Cancel",
    OnShow = function(self)
        self.text:SetFormattedText("Do you want to give %s to %s for %d GP?", self.data.itemLink, self.data.name, self.data.GP);
    end,
    OnAccept = function(self)
        EPGPR:UILootOverview():Fire("GiveSlot", self.data.slotId, self.data.name, self.data.GP)
    end,
    timeout = 0,
    whileDead = false,
    hideOnEscape = true,
    preferredIndex = 3,
}

StaticPopupDialogs["EPGPR_CHANGE_GUILD_EPGP_POPUP"] = {
    text = "Change Guild EPGP by percent (negative deflate, positive inflate)",
    button1 = "Change",
    button2 = "Cancel",
    OnShow = function (self, data)
        self.editBox:SetText("0")
    end,
    OnAccept = function(self)
        EPGPR:GuildChangeEPGP(self.editBox:GetText())
    end,
    EditBoxOnTextChanged = function (self, data) -- careful! 'self' here points to the editbox, not the dialog
        local text = self:GetText()
        local value = tonumber(text)
        if (tostring(value) == text and value ~= 0) then
            self:GetParent().button1:Enable()
        else
            self:GetParent().button1:Disable()
        end
    end,
    hasEditBox = true,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

StaticPopupDialogs["EPGPR_CHANGE_RAID_EP_POPUP"] = {
    text = "Add/Remove Raid EP (negative removes, positive adds)",
    button1 = "Award",
    button2 = "Cancel",
    OnShow = function (self, data)
        self.editBox:SetText("0")
    end,
    OnAccept = function(self)
        EPGPR:RaidAddEP(self.editBox:GetText())
    end,
    EditBoxOnTextChanged = function (self, data) -- careful! 'self' here points to the editbox, not the dialog
        local text = self:GetText()
        local value = tonumber(text)
        if (tostring(value) == text and value ~= 0) then
            self:GetParent().button1:Enable()
        else
            self:GetParent().button1:Disable()
        end
    end,
    hasEditBox = true,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

StaticPopupDialogs["EPGPR_ERROR_POPUP"] = {
    text = "",
    button1 = "Ok",
    OnShow = function(self) self.text:SetText(self.data.text) end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}
