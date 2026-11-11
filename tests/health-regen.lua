-- Run from the addon root with Lua 5.1. Native rates still need in-game validation.
local config, fighting, base, combat, updates = nil, false, 12.5, 0, 0
local locale = "enUS"
GetLocale = function() return locale end
C_AddOns = { GetAddOnMetadata = function() return "test" end }
RAID_CLASS_COLORS = { MAGE = { colorStr = "ffffffff" } }
UnitClass = function() return "Mage", "MAGE" end
UnitName = function() return "Tester" end
UnitAffectingCombat = function(unit) assert(unit == "player"); return fighting end
GetHealthRegen = function() return base, combat end
TitanPanelButton_UpdateButton = function(id) assert(id == "TITAN_HEALTH_REGEN"); updates = updates + 1 end
local secret = newproxy(true)
issecretvalue = function(value) return rawequal(value, secret) end
local function Load(path, L) assert(loadfile(path))("TitanAttributesMulti", L) end
local function Text() return select(2, config.getButtonText()) end
TitanGetVar = function(_, key) return config.savedVariables[key] end
for _, language in ipairs({ "enUS", "ptBR", "deDE", "esES", "koKR", "ruRU" }) do
	locale = language
	local L = { Elib = function(value) config = value end }
	Load("Core/languages/enUS-default.lua", L)
	if locale ~= "enUS" then Load("Core/languages/" .. locale .. ".lua", L) end
	Load("Stats/TitanHealthRegen.lua", L)
	assert(not config.hideLabelOption and config.hideIconOption)
	base, combat, fighting = 12.5, 0, false
	config.eventsTable.PLAYER_ENTERING_WORLD()
	assert(Text():find("12.5", 1, true))
	assert(not Text():find(L.healthRegenUnit, 1, true))
	assert(config.getTooltipText():find("12.5 " .. L.healthRegenUnit, 1, true))
	local count = updates
	config.onUpdate(); assert(updates == count)
	config.eventsTable.PLAYER_REGEN_DISABLED()
	assert(Text():find(L.healthRegenCombatText, 1, true))
	assert(Text():find("|cFFFF2e2e" .. L.healthRegenCombatText .. "|r", 1, true))
	assert(config.getTooltipText():find("0.0 " .. L.healthRegenUnit, 1, true))
	combat = 3.2
	config.onUpdate(); assert(Text():find("3.2", 1, true))
	assert(config.getTooltipText():find("3.2", 1, true))
	assert(config.getTooltipText():find(L.healthRegenNormal, 1, true))
	assert(not config.getTooltipText():find(L.healthRegen .. ":\t", 1, true))
	assert(config.getTooltipText():find(L.healthRegenCombat, 1, true))
	assert(config.getTooltipText():find(L.moreinfo, 1, true))
	assert(config.getTooltipText():find("Tester", 1, true))
	assert(config.getTooltipText():find(L.session, 1, true))
	assert(config.getTooltipText():find("|cFF69FF693.2", 1, true))
	assert(config.menus[2].var == "ShowBarBalance" and config.menus[2].barOption)
	assert(not Text():find("[3.2]", 1, true))
	config.savedVariables.ShowBarBalance = true
	assert(Text():find("|cFF69FF69[3.2]", 1, true))
	assert(not config.getTooltipText():find(L.healthRegenInfo, 1, true))
	combat = secret
	config.onUpdate(); assert(Text():find("—", 1, true))
	assert(config.getTooltipText():find("—", 1, true))
	config.eventsTable.PLAYER_REGEN_ENABLED()
	assert(Text():find("12.5", 1, true))
	assert(config.getTooltipText():find("|cFFFFFFFF0.0", 1, true))
	base = 10
	config.onUpdate()
	assert(config.getTooltipText():find("|cFFFF2e2e-2.5", 1, true))
	assert(Text():find("|cFFFF2e2e[-2.5]", 1, true))
	assert(not Text():find(L.healthRegenUnit, 1, true))
	config.savedVariables.ShowBarBalance = false
	assert(not Text():find("[-2.5]", 1, true))
	combat, fighting = 4, true
	config.eventsTable.PLAYER_ENTERING_WORLD(); assert(Text():find("4.0", 1, true))
	assert(config.getTooltipText():find("4.0", 1, true))
	combat = nil
	config.onUpdate(); assert(Text():find("—", 1, true))
	assert(config.getTooltipText():find("—", 1, true))
	base, combat = 0, 0
	config.eventsTable.PLAYER_REGEN_ENABLED()
	local beforeCombat = updates
	config.eventsTable.PLAYER_REGEN_DISABLED()
	assert(updates == beforeCombat + 1 and Text():find(L.healthRegenCombatText, 1, true))
	config.eventsTable.PLAYER_REGEN_ENABLED()
	assert(updates == beforeCombat + 2 and Text():find("0.0", 1, true))
end
GetHealthRegen = function() error("Unavailable") end
config.onUpdate(); assert(config.getTooltipText():find("—", 1, true))
local registered = false
GetHealthRegen = nil
Load("Stats/TitanHealthRegen.lua", { Elib = function() registered = true end })
assert(not registered, "Clients without a native API must not register the plugin")
print("PASS: health regeneration, combat transitions, zero regen, six locales, restricted and missing APIs")
