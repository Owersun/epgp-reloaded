local EPGPR, mergeTables = EPGPR, EPGPR.mergeTables

-- set the config value to the current config and persistent config
-- "change" is expected to be table with path to the changed key, like {general = {debug = true}}
function EPGPR:ConfigSet(change)
    EPGPRCONFIG = mergeTables(EPGPRCONFIG, change)
    self.config = mergeTables(self.config, change)
end

-- Base config with defaults
local defaultConfig = {
    general = {
        debug = false,
        missingManBonus = false,
    },
    instance = {
        [249] = { name = "Onyxia Lair", missingManBonus = false, EP = 1 },
        [409] = { name = "Molten Core", missingManBonus = false, EP = 1 },
        [469] = { name = "Black Wing Lair", missingManBonus = false, EP = 1 },
        [531] = { name = "Ahn'Qiraj", missingManBonus = false, EP = 1 },
        [533] = { name = "Naxxramas", missingManBonus = false, EP = 1 },
    },
    encounter = {
        -- moltern core
        [663] = { name = "Lucifron", track = true, EP = 5 },
        [664] = { name = "Magmadar", track = true, EP = 5 },
        [665] = { name = "Gehennas", track = true, EP = 5 },
        [666] = { name = "Garr", track = true, EP = 5 },
        [667] = { name = "Shazzrah", track = true, EP = 5 },
        [668] = { name = "Baron Geddon", track = true, EP = 5 },
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
        -- Ahn'Qiraj
        [709] = { name = "The Prophet Skeram", track = true, EP = 10 },
        [710] = { name = "Silithid Royalty", track = true, EP = 10 },
        [711] = { name = "Battleguard Sartura", track = true, EP = 10 },
        [712] = { name = "Fankriss the Unyielding", track = true, EP = 10 },
        [713] = { name = "Viscidus", track = true, EP = 10 },
        [714] = { name = "Princess Huhuran", track = true, EP = 10 },
        [715] = { name = "Twin Emperors", track = true, EP = 10 },
        [716] = { name = "Ouro", track = true, EP = 10 },
        [717] = { name = "C'thun", track = true, EP = 12 },
        -- Naxxramas
        [1107] = { name = "Anub'Rekhan", track = true, EP = 12 },
        [1108] = { name = "Gluth", track = true, EP = 12 },
        [1109] = { name = "Gothik the Harvester", track = true, EP = 12 },
        [1110] = { name = "Grand Widow Faerlina", track = true, EP = 12 },
        [1111] = { name = "Grobbulus", track = true, EP = 12 },
        [1112] = { name = "Heigan the Unclean", track = true, EP = 12 },
        [1113] = { name = "Instructor Razuvious", track = true, EP = 12 },
        [1114] = { name = "Kel'Thuzad", track = true, EP = 15 },
        [1115] = { name = "Loatheb", track = true, EP = 15 },
        [1116] = { name = "Maexxna", track = true, EP = 15 },
        [1117] = { name = "Noth the Plaguebringer", track = true, EP = 12 },
        [1118] = { name = "Patchwerk", track = true, EP = 12 },
        [1119] = { name = "Sapphiron", track = true, EP = 15 },
        [1120] = { name = "Thaddius", track = true, EP = 15 },
        [1121] = { name = "The Four Horsemen", track = true, EP = 15 },
    },
    item = {
        -- Imperial Qiraji Armaments
        [21232] = {
            4, -- rarity
            79, -- iLvl
            'INVTYPE_WEAPON' -- slot
        },
        -- Imperial Qiraji Regalia
        [21237] = { 4, 79, 'INVTYPE_WEAPON' },
        -- Vek'nilash's Circlet
        [20926] = { 4, 81, 'INVTYPE_HEAD' },
        -- Ouro's Intact Hide
        [20927] = { 4, 81, 'INVTYPE_LEGS' },
        -- Qiraji Bindings of Command
        [20928] = { 4, 78, 'INVTYPE_FEET' },
        -- Carapace of the Old God
        [20929] = { 4, 88, 'INVTYPE_CHEST' },
        -- Vek'lor's Diadem
        [20930] = { 4, 81, 'INVTYPE_HEAD' },
        -- Skin of the Great Sandworm
        [20931] = { 4, 81, 'INVTYPE_LEGS' },
        -- Qiraji Bindings of Dominance
        [20932] = { 4, 78, 'INVTYPE_SHOULDER' },
        -- Husk of the Old God
        [20933] = { 4, 88, 'INVTYPE_CHEST' },
        -- Eye of C'Thun
        [21221] = { 4, 88, 'INVTYPE_TRINKET' },
        -- Head of Onyxia Hore
        [18422] = { 4, 74, 'INVTYPE_TRINKET' },
        -- Head of Onyxia Alliance
        [18423] = { 4, 74, 'INVTYPE_TRINKET' },
        -- Head of Nefarian Horde
        [19002] = { 4, 83, 'INVTYPE_TRINKET' },
        -- Head of Nefarian Alliance
        [19003] = { 4, 83, 'INVTYPE_TRINKET' },
        -- Desecrated Breastplate
        [22349] = { 4, 92, 'INVTYPE_CHEST' },
        -- Desecrated Tunic
        [22350] = { 4, 92, 'INVTYPE_CHEST' },
        -- Desecrated Robe
        [22351] = { 4, 92, 'INVTYPE_CHEST' },
        -- Desecrated Legplates
        [22352] = { 4, 88, 'INVTYPE_LEGS' },
        -- Desecrated Helmet
        [22353] = { 4, 88, 'INVTYPE_HEAD' },
        -- Desecrated Pauldrons
        [22354] = { 4, 88, 'INVTYPE_SHOULDER' },
        -- Desecrated Bracers
        [22355] = { 4, 88, 'INVTYPE_WRIST' },
        -- Desecrated Waistguard
        [22356] = { 4, 88, 'INVTYPE_WAIST' },
        -- Desecrated Gauntlets
        [22357] = { 4, 88, 'INVTYPE_HAND' },
        -- Desecrated Sabatons
        [22358] = { 4, 88, 'INVTYPE_FEET' },
        -- Desecrated Legguards
        [22359] = { 4, 88, 'INVTYPE_LEGS' },
        -- Desecrated Headpiece
        [22360] = { 4, 88, 'INVTYPE_HEAD' },
        -- Desecrated Spaulders
        [22361] = { 4, 88, 'INVTYPE_SHOULDER' },
        -- Desecrated Wristguards
        [22362] = { 4, 88, 'INVTYPE_WRIST' },
        -- Desecrated Girdle
        [22363] = { 4, 88, 'INVTYPE_WAIST' },
        -- Desecrated Handguards
        [22364] = { 4, 88, 'INVTYPE_HAND' },
        -- Desecrated Boots
        [22365] = { 4, 88, 'INVTYPE_FEET' },
        -- Desecrated Leggings
        [22366] = { 4, 88, 'INVTYPE_LEGS' },
        -- Desecrated Circlet
        [22367] = { 4, 88, 'INVTYPE_HEAD' },
        -- Desecrated Shoulderpads
        [22368] = { 4, 88, 'INVTYPE_SHOULDER' },
        -- Desecrated Bindings
        [22369] = { 4, 88, 'INVTYPE_WRIST' },
        -- Desecrated Belt
        [22370] = { 4, 88, 'INVTYPE_WAIST' },
        -- Desecrated Gloves
        [22371] = { 4, 88, 'INVTYPE_HAND' },
        -- Desecrated Sandals
        [22372] = { 4, 88, 'INVTYPE_FEET' },
        -- The Phylactery of Kel'Thuzad
        [22520] = { 4, 90, 'INVTYPE_TRINKET' },
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
        list = false
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
        instance = {
            name = "Instances",
            type = "group",
            set = function(info, val) EPGPR:ConfigSet({ instance = { [info.arg[1]] = { [info.arg[2]] = val } } }) end,
            get = function(info)
                local option = EPGPR.config.instance[info.arg[1]][info.arg[2]]
                return info.type == "input" and tostring(option) or option
            end,
            args = {
                EnableMissingManBonus = {
                    set = function(_, val) EPGPR:ConfigSet({ missingManBonus = val }) end,
                    get = function(_) return EPGPR.config.missingManBonus end,
                    name = "Enable Missing Man Bonus", type = "toggle", order = 1
                },
                MissingManBonus = { name = "Missing Man Bonus", type = "header", order = 2 },
                Onyxia = { name = "Onyxia's Lair", type = "description", order = 3, width = 2 },
                OnyxiaBonus = { arg = { 249, "missingManBonus" }, name = "award", type = "toggle", order = 4, width = 0.5 },
                OnyxiaBonusBonusEP = { arg = { 249, "EP" }, name = "EP", type = "input", order = 5, width = 0.5 },
                MoltenCore = { name = "Molten Core", type = "description", order = 6, width = 2 },
                MoltenCoreBonus = { arg = { 409, "missingManBonus" }, name = "award", type = "toggle", order = 7, width = 0.5 },
                MoltenCoreBonusEP = { arg = { 409, "EP" }, name = "EP", type = "input", order = 8, width = 0.5 },
                BlackWingLair = { name = "Black Wing Lair", type = "description", order = 9, width = 2 },
                BlackWingLairBonus = { arg = { 469, "missingManBonus" }, name = "award", type = "toggle", order = 10, width = 0.5 },
                BlackWingLairBonusEP = { arg = { 469, "EP" }, name = "EP", type = "input", order = 11, width = 0.5 },
                ["Ahn'Qiraj"] = { name = "Ahn'Qiraj", type = "description", order = 12, width = 2 },
                ["Ahn'QirajBonus"] = { arg = { 531, "missingManBonus" }, name = "award", type = "toggle", order = 13, width = 0.5 },
                ["Ahn'QirajBonusEP"] = { arg = { 531, "EP" }, name = "EP", type = "input", order = 14, width = 0.5 },
                Naxxramas = { name = "Naxxramas", type = "description", order = 15, width = 2 },
                NaxxramasBonus = { arg = { 533, "missingManBonus" }, name = "award", type = "toggle", order = 16, width = 0.5 },
                NaxxramasBonusEP = { arg = { 533, "EP" }, name = "EP", type = "input", order = 17, width = 0.5 },
            },
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
                BaronGeddonTrack = { arg = { 668, "track" }, name = "track", type = "toggle", order = 15, width = 0.5 },
                BaronGeddonEP = { arg = { 668, "EP" }, name = "EP", type = "input", order = 16, width = 0.5 },
                Shazzrah = { name = "Shazzrah", type = "description", order = 17, width = 2 },
                ShazzrahTrack = { arg = { 667, "track" }, name = "track", type = "toggle", order = 18, width = 0.5 },
                ShazzrahEP = { arg = { 667, "EP" }, name = "EP", type = "input", order = 19, width = 0.5 },
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
                ["Ahn'Qiraj"] = { name = "Ahn'Qiraj", type = "header", order = 61, },
                Skeram = { name = "The Prophet Skeram", type = "description", order = 62, width = 2 },
                SkeramTrack = { arg = { 709, "track" }, name = "track", type = "toggle", order = 63, width = 0.5 },
                SkeramEP = { arg = { 709, "EP" }, name = "EP", type = "input", order = 64, width = 0.5 },
                Trio = { name = "Silithid Royalty", type = "description", order = 65, width = 2 },
                TrioTrack = { arg = { 710, "track" }, name = "track", type = "toggle", order = 66, width = 0.5 },
                TrioEP = { arg = { 710, "EP" }, name = "EP", type = "input", order = 67, width = 0.5 },
                Sartura = { name = "Battleguard Sartura", type = "description", order = 68, width = 2 },
                SarturaTrack = { arg = { 711, "track" }, name = "track", type = "toggle", order = 69, width = 0.5 },
                SarturaEP = { arg = { 711, "EP" }, name = "EP", type = "input", order = 70, width = 0.5 },
                Fankriss = { name = "Fankriss the Unyielding", type = "description", order = 71, width = 2 },
                FankrissTrack = { arg = { 712, "track" }, name = "track", type = "toggle", order = 72, width = 0.5 },
                FankrissEP = { arg = { 712, "EP" }, name = "EP", type = "input", order = 73, width = 0.5 },
                Viscidus = { name = "Viscidus", type = "description", order = 74, width = 2 },
                ViscidusTrack = { arg = { 713, "track" }, name = "track", type = "toggle", order = 75, width = 0.5 },
                ViscidusEP = { arg = { 713, "EP" }, name = "EP", type = "input", order = 76, width = 0.5 },
                Huhuran = { name = "Princess Huhuran", type = "description", order = 77, width = 2 },
                HuhuranTrack = { arg = { 714, "track" }, name = "track", type = "toggle", order = 78, width = 0.5 },
                HuhuranEP = { arg = { 714, "EP" }, name = "EP", type = "input", order = 79, width = 0.5 },
                Emperors = { name = "Twin Emperors", type = "description", order = 80, width = 2 },
                EmperorsTrack = { arg = { 715, "track" }, name = "track", type = "toggle", order = 81, width = 0.5 },
                EmperorsEP = { arg = { 715, "EP" }, name = "EP", type = "input", order = 82, width = 0.5 },
                Ouro = { name = "Ouro", type = "description", order = 83, width = 2 },
                OuroTrack = { arg = { 716, "track" }, name = "track", type = "toggle", order = 84, width = 0.5 },
                OuroEP = { arg = { 716, "EP" }, name = "EP", type = "input", order = 85, width = 0.5 },
                Cthun = { name = "C'thun", type = "description", order = 86, width = 2 },
                CthunTrack = { arg = { 717, "track" }, name = "track", type = "toggle", order = 87, width = 0.5 },
                CthunEP = { arg = { 717, "EP" }, name = "EP", type = "input", order = 88, width = 0.5 },
                Naxxramas = { name = "Naxxramas", type = "header", order = 89, },
                ["Anub'Rekhan"] = { name = "Anub'Rekhan", type = "description", order = 90, width = 2 },
                ["Anub'RekhanTrack"] = { arg = { 1107, "track" }, name = "track", type = "toggle", order = 91, width = 0.5 },
                ["Anub'RekhanEP"] = { arg = { 1107, "EP" }, name = "EP", type = "input", order = 92, width = 0.5 },
                ["Grand Widow Faerlina"] = { name = "Grand Widow Faerlina", type = "description", order = 93, width = 2 },
                ["Grand Widow FaerlinaTrack"] = { arg = { 1110, "track" }, name = "track", type = "toggle", order = 94, width = 0.5 },
                ["Grand Widow FaerlinaEP"] = { arg = { 1110, "EP" }, name = "EP", type = "input", order = 95, width = 0.5 },
                ["Maexxna"] = { name = "Maexxna", type = "description", order = 96, width = 2 },
                ["MaexxnaEP"] = { arg = { 1116, "track" }, name = "track", type = "toggle", order = 97, width = 0.5 },
                ["MaexxnaTrack"] = { arg = { 1116, "EP" }, name = "EP", type = "input", order = 98, width = 0.5 },
                ["Instructor Razuvious"] = { name = "Instructor Razuvious", type = "description", order = 99, width = 2 },
                ["Instructor RazuviousEP"] = { arg = { 1113, "track" }, name = "track", type = "toggle", order = 101, width = 0.5 },
                ["Instructor RazuviousTrack"] = { arg = { 1113, "EP" }, name = "EP", type = "input", order = 102, width = 0.5 },
                ["Gothik the Harvester"] = { name = "Gothik the Harvester", type = "description", order = 103, width = 2 },
                ["Gothik the HarvesterEP"] = { arg = { 1109, "track" }, name = "track", type = "toggle", order = 104, width = 0.5 },
                ["Gothik the HarvesterTrack"] = { arg = { 1109, "EP" }, name = "EP", type = "input", order = 105, width = 0.5 },
                ["The Four Horsemen"] = { name = "The Four Horsemen", type = "description", order = 106, width = 2 },
                ["The Four HorsemenEP"] = { arg = { 1121, "track" }, name = "track", type = "toggle", order = 107, width = 0.5 },
                ["The Four HorsemenTrack"] = { arg = { 1121, "EP" }, name = "EP", type = "input", order = 108, width = 0.5 },
                ["Noth the Plaguebringer"] = { name = "Noth the Plaguebringer", type = "description", order = 109, width = 2 },
                ["Noth the PlaguebringerEP"] = { arg = { 1117, "track" }, name = "track", type = "toggle", order = 110, width = 0.5 },
                ["Noth the PlaguebringerTrack"] = { arg = { 1117, "EP" }, name = "EP", type = "input", order = 111, width = 0.5 },
                ["Heigan the Unclean"] = { name = "Heigan the Unclean", type = "description", order = 112, width = 2 },
                ["Heigan the UncleanEP"] = { arg = { 1112, "track" }, name = "track", type = "toggle", order = 113, width = 0.5 },
                ["Heigan the UncleanTrack"] = { arg = { 1112, "EP" }, name = "EP", type = "input", order = 114, width = 0.5 },
                ["Loatheb"] = { name = "Loatheb", type = "description", order = 115, width = 2 },
                ["LoathebEP"] = { arg = { 1115, "track" }, name = "track", type = "toggle", order = 116, width = 0.5 },
                ["LoathebTrack"] = { arg = { 1115, "EP" }, name = "EP", type = "input", order = 117, width = 0.5 },
                ["Patchwerk"] = { name = "Patchwerk", type = "description", order = 118, width = 2 },
                ["PatchwerkEP"] = { arg = { 1118, "track" }, name = "track", type = "toggle", order = 119, width = 0.5 },
                ["PatchwerkTrack"] = { arg = { 1118, "EP" }, name = "EP", type = "input", order = 120, width = 0.5 },
                ["Grobbulus"] = { name = "Grobbulus", type = "description", order = 121, width = 2 },
                ["GrobbulusEP"] = { arg = { 1111, "track" }, name = "track", type = "toggle", order = 122, width = 0.5 },
                ["GrobbulusTrack"] = { arg = { 1111, "EP" }, name = "EP", type = "input", order = 123, width = 0.5 },
                ["Gluth"] = { name = "Gluth", type = "description", order = 124, width = 2 },
                ["GluthEP"] = { arg = { 1108, "track" }, name = "track", type = "toggle", order = 125, width = 0.5 },
                ["GluthTrack"] = { arg = { 1108, "EP" }, name = "EP", type = "input", order = 126, width = 0.5 },
                ["Thaddius"] = { name = "Thaddius", type = "description", order = 127, width = 2 },
                ["ThaddiusEP"] = { arg = { 1120, "track" }, name = "track", type = "toggle", order = 128, width = 0.5 },
                ["ThaddiusTrack"] = { arg = { 1120, "EP" }, name = "EP", type = "input", order = 129, width = 0.5 },
                ["Sapphiron"] = { name = "Sapphiron", type = "description", order = 130, width = 2 },
                ["SapphironEP"] = { arg = { 1119, "track" }, name = "track", type = "toggle", order = 131, width = 0.5 },
                ["SapphironTrack"] = { arg = { 1119, "EP" }, name = "EP", type = "input", order = 132, width = 0.5 },
                ["Kel'Thuzad"] = { name = "Kel'Thuzad", type = "description", order = 133, width = 2 },
                ["Kel'ThuzadEP"] = { arg = { 1114, "track" }, name = "track", type = "toggle", order = 134, width = 0.5 },
                ["Kel'ThuzadTrack"] = { arg = { 1114, "EP" }, name = "EP", type = "input", order = 135, width = 0.5 },
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
    ACD:AddToBlizOptions(appName, "Instances", appName, "instance")
    ACD:AddToBlizOptions(appName, "Encounters", appName, "encounter")
    ACD:AddToBlizOptions(appName, "Gear Points", appName, "GP")
    ACD:AddToBlizOptions(appName, "Bidding", appName, "bidding")
end
