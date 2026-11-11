-- Run from the addon root with Lua 5.1. Native restriction rules need in-game tests.
local config, base, casting, level, locale, fighting, updates
local secret = newproxy(true)
getmetatable(secret).__eq = function() error("Secret comparison") end
getmetatable(secret).__sub = function() error("Secret arithmetic") end
getmetatable(secret).__tostring = function() error("Secret formatting") end
C_AddOns = { GetAddOnMetadata = function() return "test" end }
RAID_CLASS_COLORS = { MAGE = { colorStr = "ffffffff" } }
UnitClass = function() return "Mage", "MAGE" end
UnitName = function() return "Tester" end
GetExpansionLevel = function() return level end
GetLocale = function() return locale end
UnitAffectingCombat = function() return fighting end
local function API() return base, casting end
GetManaRegen = API
TitanGetVar = function(_, key) return config.savedVariables[key] end
TitanPanelButton_UpdateButton = function(id) assert(id == "TITAN_MARGM"); updates = updates + 1 end
local function Load(path, L) assert(loadfile(path))("TitanAttributesMulti", L) end
local function Text() return select(2, config.getButtonText()) end
for _, manifest in ipairs({ "TitanAttributesMulti.toc", "TitanAttributesMulti_Vanilla.toc", "TitanAttributesMulti_TBC.toc", "TitanAttributesMulti_Mists.toc", "TitanAttributesMulti_Camelot.toc" }) do
	local file = assert(io.open(manifest)); local text = file:read("*a"); file:close()
	assert(text:find("Stats\\TitanManaRegen.lua", 1, true))
end
for _, expansion in ipairs({0, 1, 4, 11, 11}) do
	level = expansion
	for _, language in ipairs({"enUS", "ptBR", "deDE", "esES", "koKR", "ruRU"}) do
		locale, fighting, updates, base, casting = language, false, 0, secret, secret
		issecretvalue = function(value) return rawequal(value, secret) end
		local L = { Elib = function(value) config = value end }
		Load("Core/languages/enUS-default.lua", L)
		if locale ~= "enUS" then Load("Core/languages/" .. locale .. ".lua", L) end
		Load("Stats/TitanManaRegen.lua", L)
		config.eventsTable.PLAYER_ENTERING_WORLD(); assert(Text():find("—", 1, true))
		base, casting = 0.4, 0.1
		config.onUpdate(); assert(Text():find("0.4", 1, true))
		assert(not Text():find(L.manaRegenUnit, 1, true))
		assert(config.getTooltipText():find(L.manaRegenCasting, 1, true))
		assert(config.getTooltipText():find("0.1 " .. L.manaRegenUnit, 1, true))
		local count = updates; config.onUpdate(); assert(updates == count)
		base = 0.7; config.onUpdate()
		config.savedVariables.ShowBarBalance = true
		assert(Text():find("|cFF69FF69[0.3]", 1, true))
		base = 0.2; config.onUpdate(); assert(Text():find("|cFFFF2e2e[-0.2]", 1, true))
		base = 0.001; config.onUpdate(); assert(Text():find("<0.1", 1, true))
		base, casting = secret, secret
		config.eventsTable.PLAYER_REGEN_DISABLED()
		assert(Text() == "|cFFFF2e2e" .. L.healthRegenCombatText .. "|r")
		assert(not config.getTooltipText():find("0.2", 1, true))
		config.eventsTable.PLAYER_REGEN_ENABLED(); assert(Text():find("—", 1, true))
		base, casting = 0, 0
		issecretvalue = nil -- Classic clients without the secret-value API.
		config.eventsTable.PLAYER_REGEN_DISABLED(); assert(Text():find("|cFFFFFFFF0|r", 1, true)); assert(config.getTooltipText():find("0 " .. L.manaRegenUnit, 1, true))
		base, casting = 10, nil
		config.onUpdate(); assert(Text():find("10.0", 1, true))
		assert(config.getTooltipText():find("— " .. L.manaRegenUnit, 1, true))
		config.eventsTable.PLAYER_REGEN_ENABLED()
	end
end
GetManaRegen = function() error("Unavailable reading") end
config.onUpdate(); assert(Text():find("—", 1, true))
GetManaRegen = nil
local registered = false
Load("Stats/TitanManaRegen.lua", { Elib = function() registered = true end })
assert(not registered)
print("PASS: mana decimals, session changes, casting rates, secret startup/combat/recovery, legacy clients, five manifests and six locales")
