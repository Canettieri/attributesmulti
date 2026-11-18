local config, value, locale = nil, 100, "enUS"
local secret = newproxy(true)
getmetatable(secret).__tostring = function() error("Secret formatted") end
issecretvalue = function(v) return rawequal(v, secret) end
GetLocale = function() return locale end
C_AddOns = { GetAddOnMetadata = function() return "test" end }
RAID_CLASS_COLORS = { PRIEST = { colorStr = "ffffffff" } }
UnitClass = function() return "Priest", "PRIEST" end
UnitName = function() return "Tester" end
TitanGetVar = function(_, key) return config.savedVariables[key] end
TitanPanelButton_UpdateButton = function() end
local function Load(path, L) assert(loadfile(path))("TitanAttributesMulti", L) end
for _, language in ipairs({ "enUS", "ptBR", "deDE", "esES", "koKR", "ruRU" }) do
	locale = language
	local L = { Elib = function(c) config = c end }
	Load("Core/languages/enUS-default.lua", L)
	if locale ~= "enUS" then Load("Core/languages/" .. locale .. ".lua", L) end
	Load("Core/LegacyAttributes.lua", L)
	GetSpellBonusHealing = function() return value end
	value = secret
	Load("Stats/TitanHealingPower.lua", L)
	local function Text() return select(2, config.getButtonText()) end
	config.eventsTable.PLAYER_ENTERING_WORLD()
	assert(Text():find("—", 1, true))
	value = 100
	config.onUpdate()
	assert(Text():find("100", 1, true))
	assert(config.getTooltipText():find(L.healingPower, 1, true))
	assert(config.icon == "Interface\\Icons\\spell_holy_flashheal")
	config.savedVariables.ShowBarBalance = true
	value = 125
	config.onUpdate()
	assert(Text():find("[|cFF69FF6925|r]", 1, true))
	value = secret
	config.onUpdate()
	assert(Text():find("—", 1, true) and not Text():find("[", 1, true))
	value = 75
	config.onUpdate()
	assert(Text():find("[|cFFFF2e2e-25|r]", 1, true))
	GetSpellBonusHealing = function() error("Unavailable") end
	config.onUpdate()
	assert(Text():find("—", 1, true))
end
GetSpellBonusHealing = nil
local registered = false
Load("Stats/TitanHealingPower.lua", { Elib = function() registered = true end })
assert(not registered)
print("PASS: healing power, six locales, session balances, secret startup and recovery, missing APIs")