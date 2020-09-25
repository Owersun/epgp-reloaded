-- Author      : fenrisar
-- Create Date : 7/27/2020 5:20:55 PM

-- Main frame
local mainFrame = CreateFrame("Frame", nil, UIParent)
mainFrame:SetFrameStrata("BACKGROUND")
mainFrame:SetSize(500, 500)
mainFrame:SetMovable(true)
mainFrame:EnableMouse(true)
mainFrame:RegisterForDrag("LeftButton")
-- mainFrame:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background",
--                                             edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
--                                             tile = true, tileSize = 16, edgeSize = 1,
--                                             insets = { left = 4, right = 4, top = 4, bottom = 4 }});
-- mainFrame:SetBackdropColor(0,0,0,1);

local headerTextureLeft = mainFrame:CreateTexture(nil,"BACKGROUND")
headerTextureLeft:SetTexture("Interface\\AddOns\\epgp-reloaded\\Texture\\bagheader.blp")
headerTextureLeft:SetPoint("TOPLEFT", mainFrame ,"TOPLEFT", 0, 30)
mainFrame.texture = headerTextureLeft

local headerTextureRight = mainFrame:CreateTexture(nil,"BACKGROUND")
headerTextureRight:SetTexture("Interface\\AddOns\\epgp-reloaded\\Texture\\bagheader-right.blp")
headerTextureRight:SetPoint("TOPRIGHT", mainFrame ,"TOPRIGHT", 0, 30)
mainFrame.texture = headerTextureRight

local bottomTexture = mainFrame:CreateTexture(nil,"BACKGROUND")
bottomTexture:SetTexture("Interface\\AddOns\\epgp-reloaded\\Texture\\windowbg-brushed.blp")
bottomTexture:SetPoint("TOPLEFT", mainFrame ,"TOPLEFT", 0, -30)
bottomTexture:SetPoint("BOTTOMRIGHT", mainFrame ,"BOTTOMRIGHT", 0, 0)
mainFrame.texture = bottomTexture

local hordeTexture = mainFrame:CreateTexture(nil,"ARTWORK")
hordeTexture:SetTexture("Interface\\AddOns\\epgp-reloaded\\Texture\\Horde.blp")
hordeTexture:SetPoint("TOPLEFT", mainFrame ,"TOPLEFT", 0, 3)
hordeTexture:SetSize(30, 30)
mainFrame.texture = hordeTexture

local playerGuild = mainFrame:CreateFontString(playerGuild, "OVERLAY", "GameFontNormalLarge")
playerGuild:SetPoint("TOPLEFT", 30, -5);
playerGuild:SetJustifyV("MIDDLE");
playerGuild:SetJustifyH("LEFT");
playerGuild:SetTextColor(255, 0, 0, 0.5);

mainFrame:SetScript("OnDragStart", mainFrame.StartMoving)
mainFrame:SetScript("OnDragStop", mainFrame.StopMovingOrSizing)

-- Left Main Menu
local menuFrame = CreateFrame("Frame", nil, mainFrame)
menuFrame:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 0, -30)
menuFrame:SetSize(100, 350)
-- menuFrame:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background",
--                                             edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
--                                             tile = true, tileSize = 16, edgeSize = 1,
--                                             insets = { left = 4, right = 4, top = 4, bottom = 4 }});
-- menuFrame:SetBackdropColor(0,0,0,1);

local buttonCurrentEPGP = CreateFrame("Button", nil, menuFrame)
buttonCurrentEPGP:SetPoint("TOPLEFT", menuFrame, "TOPLEFT", 0, -10)
buttonCurrentEPGP:SetSize(100, 20)
buttonCurrentEPGP:SetText("Guild EPGP")
buttonCurrentEPGP:SetNormalFontObject("GameFontNormal")
buttonCurrentEPGP:SetNormalTexture("Interface\\AddOns\\epgp-reloaded\\Texture\\menu-bg.blp")
buttonCurrentEPGP:SetHighlightTexture("Interface\\AddOns\\epgp-reloaded\\Texture\\menu-hover.blp")

buttonCurrentEPGP:SetScript("OnClick", function()

end)

local buttonCurrentRaid = CreateFrame("Button", nil, menuFrame)
buttonCurrentRaid:SetPoint("TOPLEFT", menuFrame, "TOPLEFT", 0, -40)
buttonCurrentRaid:SetSize(100, 20)
buttonCurrentRaid:SetText("Current Raid")
buttonCurrentRaid:SetNormalFontObject("GameFontNormal")
buttonCurrentRaid:SetNormalTexture("Interface\\AddOns\\epgp-reloaded\\Texture\\menu-bg.blp")
buttonCurrentRaid:SetHighlightTexture("Interface\\AddOns\\epgp-reloaded\\Texture\\menu-hover.blp")

buttonCurrentRaid:SetScript("OnClick", function()

end)

local buttonCurrentStandby = CreateFrame("Button", nil, menuFrame)
buttonCurrentStandby:SetPoint("TOPLEFT", menuFrame, "TOPLEFT", 0, -70)
buttonCurrentStandby:SetSize(100, 20)
buttonCurrentStandby:SetText("Raid Standby")
buttonCurrentStandby:SetNormalFontObject("GameFontNormal")
buttonCurrentStandby:SetNormalTexture("Interface\\AddOns\\epgp-reloaded\\Texture\\menu-bg.blp")
buttonCurrentStandby:SetHighlightTexture("Interface\\AddOns\\epgp-reloaded\\Texture\\menu-hover.blp")

buttonCurrentStandby:SetScript("OnClick", function()

end)

local buttonCurrentAlts = CreateFrame("Button", nil, menuFrame)
buttonCurrentAlts:SetPoint("TOPLEFT", menuFrame, "TOPLEFT", 0, -100)
buttonCurrentAlts:SetSize(100, 20)
buttonCurrentAlts:SetText("Alts")
buttonCurrentAlts:SetNormalFontObject("GameFontNormal")
buttonCurrentAlts:SetNormalTexture("Interface\\AddOns\\epgp-reloaded\\Texture\\menu-bg.blp")
buttonCurrentAlts:SetHighlightTexture("Interface\\AddOns\\epgp-reloaded\\Texture\\menu-hover.blp")

buttonCurrentAlts:SetScript("OnClick", function()

end)

local buttonExport = CreateFrame("Button", nil, menuFrame)
buttonExport:SetPoint("TOPLEFT", menuFrame, "TOPLEFT", 0, -130)
buttonExport:SetSize(100, 20)
buttonExport:SetText("Export")
buttonExport:SetNormalFontObject("GameFontNormal")
buttonExport:SetNormalTexture("Interface\\AddOns\\epgp-reloaded\\Texture\\menu-bg.blp")
buttonExport:SetHighlightTexture("Interface\\AddOns\\epgp-reloaded\\Texture\\menu-hover.blp")

buttonExport:SetScript("OnClick", function()

end)

-- Guild Data Frame
local guildDataFrame = CreateFrame("Frame", nil, mainFrame)
guildDataFrame:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 100, -30)
guildDataFrame:SetSize(400, 350)
-- guildDataFrame:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", 
--                                             edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
--                                             tile = true, tileSize = 16, edgeSize = 1, 
--                                             insets = { left = 4, right = 4, top = 4, bottom = 4 }});
-- guildDataFrame:SetBackdropColor(0,0,0,1);

-- Guild EPGP data
local nickName = guildDataFrame:CreateFontString(nickName, "OVERLAY", "GameFontNormal")
nickName:SetPoint("TOPLEFT", 30, -5);
nickName:SetJustifyV("MIDDLE");
nickName:SetJustifyH("LEFT");
nickName:SetText("Name")

local gudilRank = guildDataFrame:CreateFontString(gudilRank, "OVERLAY", "GameFontNormal")
gudilRank:SetPoint("TOPLEFT", 120, -5);
gudilRank:SetJustifyV("MIDDLE");
gudilRank:SetJustifyH("LEFT");
gudilRank:SetText("Rank")

local eventPoints = guildDataFrame:CreateFontString(eventPoints, "OVERLAY", "GameFontNormal")
eventPoints:SetPoint("TOPLEFT", 210, -5);
eventPoints:SetJustifyV("MIDDLE");
eventPoints:SetJustifyH("LEFT");
eventPoints:SetText("EP")

local gPoints = guildDataFrame:CreateFontString(gPoints, "OVERLAY", "GameFontNormal")
gPoints:SetPoint("TOPLEFT", 250, -5);
gPoints:SetJustifyV("MIDDLE");
gPoints:SetJustifyH("LEFT");
gPoints:SetText("GP")

local percentPoints = guildDataFrame:CreateFontString(percentPoints, "OVERLAY", "GameFontNormal")
percentPoints:SetPoint("TOPLEFT", 280, -5);
percentPoints:SetJustifyV("MIDDLE");
percentPoints:SetJustifyH("LEFT");
percentPoints:SetText("%")

local addEP = guildDataFrame:CreateFontString(addEP, "OVERLAY", "GameFontNormal")
addEP:SetPoint("TOPLEFT", 320, -5);
addEP:SetJustifyV("MIDDLE");
addEP:SetJustifyH("LEFT");
addEP:SetText("Adjust EPGP")

-- Close Button
local buttonClose = CreateFrame("Button", nil, mainFrame)
buttonClose:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", -10, -5)
buttonClose:SetSize(20, 20)
buttonClose:SetNormalTexture("Interface\\AddOns\\epgp-reloaded\\Texture\\window-close-button-normal.blp")
buttonClose:SetHighlightTexture("Interface\\AddOns\\epgp-reloaded\\Texture\\window-close-button-hover.blp")

buttonClose:SetScript("OnClick", function()
    mainFrame:Hide()
end)

-- mainFrame action
mainFrame:SetPoint("CENTER",0,0)
mainFrame:Show()

mainFrame:SetScript("OnEnter", function()
    local guild = GetGuildInfo("player")
    if (guild == nil) then guild = "Not in a Guild"; end
    playerGuild:SetText("" ..guild.. "");
end)