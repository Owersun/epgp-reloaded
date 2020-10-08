--localization file for english/United States
local L = LibStub("AceLocale-3.0"):NewLocale("EPGPR", "enUS", true)

L["rollPattern"] = "(%S+) rolls (%d+) %(1%-100%)"
L["%s rolled %d"] = true
L["%s has been given to %s for %d GP"] = true
L["%s has been given to %s without EPGP"] = true
L["%s has been defeated, %s EP awarded to the raid"] = true
