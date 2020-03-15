local EPGPR, mergeTables = EPGPR, EPGPR.mergeTables

-- set config value to current config and persistent config
-- "change" is expected to be table with path to the changed key, like {general = {debug = true}}
function EPGPR:ConfigSet(change)
    EPGPRCONFIG = mergeTables(EPGPRCONFIG, change)
    self.config = mergeTables(self.config, change)
end

-- Base config with defaults
local defaultConfig = {
    general = {
        debug = false,
    },
    encounter = {
        -- moltern core
        [663] = { name = "Lucifron", track = true, EP = 5 },
        [664] = { name = "Magmadar", track = true, EP = 5 },
        [665] = { name = "Gehennas", track = true, EP = 5 },
        [666] = { name = "Garr", track = true, EP = 5 },
        [667] = { name = "Baron Geddon", track = true, EP = 5 },
        [668] = { name = "Shazzrah", track = true, EP = 5 },
        [669] = { name = "Sulfuron Harbinger", track = true, EP = 5 },
        [670] = { name = "Golemagg the Incinerator", track = true, EP = 5 },
        [671] = { name = "Majordomo Executus", track = true, EP = 5 },
        [672] = { name = "Ragnaros", track = true, EP = 7 },
        -- onyxia lair
        [1084] = { name = "Onyxia", track = true, EP = 5 },
        -- blackwing lair --
        [610] = { name = "Razorgore the Untamed", track = true, EP = 7 },
        [611] = { name = "Vaelastrasz the Corrupt", track = true, EP = 7 },
        [612] = { name = "Broodlord Lashlayer", track = true, EP = 7 },
        [613] = { name = "Firemaw", track = true, EP = 7 },
        [614] = { name = "Ebonroc", track = true, EP = 7 },
        [615] = { name = "Flamegor", track = true, EP = 7 },
        [616] = { name = "Chromaggus", track = true, EP = 7 },
        [617] = { name = "Nefarian", track = true, EP = 7 },
    },
    GP = {
        basegp = 1,
        slotModifier = {
            INVTYPE_2HWEAPON = 2,
            INVTYPE_WEAPON = 1.5,
            INVTYPE_WEAPONMAINHAND = 1.5,
            INVTYPE_HOLDABLE = 0.5,
            INVTYPE_HEAD = 1,
            INVTYPE_BODY = 1,
            INVTYPE_CHEST = 1,
            INVTYPE_ROBE = 1,
            INVTYPE_LEGS = 1,
            INVTYPE_BAG = 1,
            INVTYPE_SHOULDER = 0.75,
            INVTYPE_WAIST = 0.75,
            INVTYPE_FEET = 0.75,
            INVTYPE_HAND = 0.75,
            INVTYPE_TRINKET = 0.75,
            INVTYPE_FINGER = 0.5,
            INVTYPE_WRIST = 0.5,
            INVTYPE_NECK = 0.5,
            INVTYPE_CLOAK = 0.5,
            INVTYPE_SHIELD = 0.5,
            INVTYPE_WEAPONOFFHAND = 0.5,
            INVTYPE_RANGED = 0.5,
            INVTYPE_THROWN = 0.5,
            INVTYPE_RANGEDRIGHT = 0.5,
            INVTYPE_RELIC = 0.5,
            INVTYPE_QUIVER = 0.5,
            INVTYPE_TABARD = 0,
        }
    },
    bidding = {
        messages = {
            ["!need"] = 1,
            ["!off"] = 0.5
        },
        countdownEnable = true,
        countdown = 20,
        considerRoll = true,
        rollRatio = 0,
        multibid = false,
    },
    alts = {

    },
    standby = {
        list = false,
        EPRatio = 1,
        whisper = "!standby",
    },
}

-- Config Table for AceConfigRegistry/AceConfigDialog
local configOptions = {
    type = "group",
    name = EPGPR.Const.AppName,
    args = {
        general = {
            name = "General Options",
            type = "group",
            set = function(info, val) EPGPR:ConfigSet({[info[1]] = {[info[2]] = val}}) end,
            get = function(info)
                local option = EPGPR.config[info[1]][info[2]]
                return info.type == "input" and tostring(option) or option
            end,
            args = {
                debug = {
                    name = "Debug",
                    type = "toggle",
                }
            }
        },
        encounter = {
            name = "Encounters",
            type = "group",
            set = function(info, val) EPGPR:ConfigSet({ encounter = { [info.arg[1]] = { [info.arg[2]] = val } } }) end,
            get = function(info)
                local option = EPGPR.config.encounter[info.arg[1]][info.arg[2]]
                return info.type == "input" and tostring(option) or option
            end,
            args = {
                MoltenCore = { name = "Molten Core", type = "header", order = 1 },
                Lucifron = { name = "Lucifron", type = "description", order = 2, width = 2 },
                LucifronTrack = { arg = { 663, "track" }, name = "track", type = "toggle", order = 3, width = 0.5 },
                LucifronEP = { arg = { 663, "EP" }, name = "EP", type = "input", order = 4, width = 0.5 },
                Magmadar = { name = "Magmadar", type = "description", order = 5, width = 2 },
                MagmadarTrack = { arg = { 664, "track" }, name = "track", type = "toggle", order = 6, width = 0.5 },
                MagmadarEP = { arg = { 664, "EP" }, name = "EP", type = "input", order = 7, width = 0.5 },
                Gehennas = { name = "Gehennas", type = "description", order = 8, width = 2 },
                GehennasTrack = { arg = { 665, "track" }, name = "track", type = "toggle", order = 9, width = 0.5 },
                GehennasEP = { arg = { 665, "EP" }, name = "EP", type = "input", order = 10, width = 0.5 },
                Garr = { name = "Garr", type = "description", order = 11, width = 2 },
                GarrTrack = { arg = { 666, "track" }, name = "track", type = "toggle", order = 12, width = 0.5 },
                GarrEP = { arg = { 666, "EP" }, name = "EP", type = "input", order = 13, width = 0.5 },
                BaronGeddon = { name = "Baron Geddon", type = "description", order = 14, width = 2 },
                BaronGeddonTrack = { arg = { 667, "track" }, name = "track", type = "toggle", order = 15, width = 0.5 },
                BaronGeddonEP = { arg = { 667, "EP" }, name = "EP", type = "input", order = 16, width = 0.5 },
                Shazzrah = { name = "Shazzrah", type = "description", order = 17, width = 2 },
                ShazzrahTrack = { arg = { 668, "track" }, name = "track", type = "toggle", order = 18, width = 0.5 },
                ShazzrahEP = { arg = { 668, "EP" }, name = "EP", type = "input", order = 19, width = 0.5 },
                Sulfuron = { name = "Sulfuron Harbinger", type = "description", order = 20, width = 2 },
                SulfuronTrack = { arg = { 669, "track" }, name = "track", type = "toggle", order = 21, width = 0.5 },
                SulfuronEP = { arg = { 669, "EP" }, name = "EP", type = "input", order = 22, width = 0.5 },
                Golemagg = { name = "Golemagg the Incinerator", type = "description", order = 23, width = 2 },
                GolemaggTrack = { arg = { 670, "track" }, name = "track", type = "toggle", order = 24, width = 0.5 },
                GolemaggEP = { arg = { 670, "EP" }, name = "EP", type = "input", order = 25, width = 0.5 },
                Majordomo = { name = "Majordomo Executus", type = "description", order = 26, width = 2 },
                MajordomoTrack = { arg = { 671, "track" }, name = "track", type = "toggle", order = 27, width = 0.5 },
                MajordomoEP = { arg = { 671, "EP" }, name = "EP", type = "input", order = 28, width = 0.5 },
                Ragnaros = { name = "Ragnaros", type = "description", order = 29, width = 2 },
                RagnarosTrack = { arg = { 672, "track" }, name = "track", type = "toggle", order = 30, width = 0.5 },
                RagnarosEP = { arg = { 672, "EP" }, name = "EP", type = "input", order = 31, width = 0.5 },
                OnyxiaLair = { name = "Onyxia Lair", type = "header", order = 32, },
                Onyxia = { name = "Onyxia", type = "description", order = 33, width = 2 },
                OnyxiaTrack = { arg = { 1084, "track" }, name = "track", type = "toggle", order = 34, width = 0.5 },
                OnyxiaEP = { arg = { 1084, "EP" }, name = "EP", type = "input", order = 35, width = 0.5 },
                BWL = { name = "Black Wing Lair", type = "header", order = 36, },
                Razorgore = { name = "Razorgore the Untamed", type = "description", order = 37, width = 2 },
                RazorgoreTrack = { arg = { 610, "track" }, name = "track", type = "toggle", order = 38, width = 0.5 },
                RazorgoreEP = { arg = { 610, "EP" }, name = "EP", type = "input", order = 39, width = 0.5 },
                Vaelastrasz = { name = "Vaelastrasz the Corrupt", type = "description", order = 40, width = 2 },
                VaelastraszTrack = { arg = { 611, "track" }, name = "track", type = "toggle", order = 41, width = 0.5 },
                VaelastraszEP = { arg = { 611, "EP" }, name = "EP", type = "input", order = 42, width = 0.5 },
                Broodlord = { name = "Broodlord Lashlayer", type = "description", order = 43, width = 2 },
                BroodlordTrack = { arg = { 612, "track" }, name = "track", type = "toggle", order = 44, width = 0.5 },
                BroodlordEP = { arg = { 612, "EP" }, name = "EP", type = "input", order = 45, width = 0.5 },
                Firemaw = { name = "Firemaw", type = "description", order = 46, width = 2 },
                FiremawTrack = { arg = { 613, "track" }, name = "track", type = "toggle", order = 47, width = 0.5 },
                FiremawEP = { arg = { 613, "EP" }, name = "EP", type = "input", order = 48, width = 0.5 },
                Ebonroc = { name = "Ebonroc", type = "description", order = 49, width = 2 },
                EbonrocTrack = { arg = { 614, "track" }, name = "track", type = "toggle", order = 50, width = 0.5 },
                EbonrocEP = { arg = { 614, "EP" }, name = "EP", type = "input", order = 51, width = 0.5 },
                Flamegor = { name = "Flamegor", type = "description", order = 52, width = 2 },
                FlamegorTrack = { arg = { 615, "track" }, name = "track", type = "toggle", order = 53, width = 0.5 },
                FlamegorEP = { arg = { 615, "EP" }, name = "EP", type = "input", order = 54, width = 0.5 },
                Chromaggus = { name = "Chromaggus", type = "description", order = 55, width = 2 },
                ChromaggusTrack = { arg = { 616, "track" }, name = "track", type = "toggle", order = 56, width = 0.5 },
                ChromaggusEP = { arg = { 616, "EP" }, name = "EP", type = "input", order = 57, width = 0.5 },
                Nefarian = { name = "Nefarian", type = "description", order = 58, width = 2 },
                NefarianTrack = { arg = { 617, "track" }, name = "track", type = "toggle", order = 59, width = 0.5 },
                NefarianEP = { arg = { 617, "EP" }, name = "EP", type = "input", order = 60, width = 0.5 },
            }
        },
        GP = {
            name = "Gear Points",
            type = "group",
            set = function(info, val) EPGPR:ConfigSet({[info[1]] = {[info[2]] = val}}) end,
            get = function(info)
                local option = EPGPR.config[info[1]][info[2]]
                return info.type == "input" and tostring(option) or option
            end,
            args = {
                basegp = {
                    name = "Base GP",
                    type = "input",
                    width = 1,
                },
            }
        },
        bidding = {
            name = "Bidding",
            type = "group",
            set = function(info, val) EPGPR:ConfigSet({[info[1]] = {[info[2]] = val}}) end,
            get = function(info)
                local option = EPGPR.config[info[1]][info[2]]
                return info.type == "input" and tostring(option) or option
            end,
            args = {
                countdownEnable = {
                    name = "Countdown timer",
                    type = "toggle",
                    order = 1,
                    width = 2,
                },
                countdown = {
                    name = "seconds",
                    type = "input",
                    width = 0.5,
                    order = 2,
                },
                considerRoll = {
                    name = "Consider Roll",
                    type = "toggle",
                    width = 2,
                    order = 3,
                },
                rollRatio = {
                    name = "GP Ratio for Roll",
                    type = "input",
                    width = 0.5,
                    order = 4,
                },
                multibid = {
                    name = "Allow multibid",
                    type = "toggle",
                    width = "full",
                    order = 5,
                }
            }
        }
    }
}

-- Initialize
function EPGPR:ConfigSetup()
    local appName = self.Const.AppName
    -- Build this session config from defaults, plus everything that was saved merged in
    self.config = mergeTables(defaultConfig, EPGPRCONFIG)
    -- Initialize "Interface -> AddOn"'s config dialogs
    LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable(appName, configOptions)
    local ACD = LibStub("AceConfigDialog-3.0")
    ACD:AddToBlizOptions(appName, appName, nil, "general")
    ACD:AddToBlizOptions(appName, "Encounters", appName, "encounter")
    ACD:AddToBlizOptions(appName, "Gear Points", appName, "GP")
    ACD:AddToBlizOptions(appName, "Bidding", appName, "bidding")
end
