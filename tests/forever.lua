-- Run from the addon root: lua tests/forever.lua (Lua 5.1).
local configs, states = {}, {}
local stats = { 100, 20, 30, 40, 50 }
local level, xp, maxXP, rating, modifier = 59, 50, 100, 2, 1
local hiddenStat = false
C_AddOns = { GetAddOnMetadata = function() return "test" end }
RAID_CLASS_COLORS = { MAGE = { colorStr = "ffffffff" } }
UnitClass = function() return "Mage", "MAGE" end
UnitName = function() return "Tester" end
UnitFactionGroup = function() return "Alliance" end
UnitStat = function(_, index) return stats[index], stats[index], 0, 0 end
UnitArmor = function() return 100, 120, 120, 20, 0 end
UnitAttackPower = function() return 100, 20, 0 end
UnitRangedAttackPower = UnitAttackPower
GetCombatRatingBonus = function(index) assert(index == 6); return rating end
GetHitModifier = function() return modifier end
GetExpansionLevel = function() return LE_EXPANSION_LEVEL_CURRENT end
LE_EXPANSION_CLASSIC, LE_EXPANSION_BURNING_CRUSADE, LE_EXPANSION_MISTS_OF_PANDARIA = 0, 1, 4
LE_EXPANSION_LEVEL_CURRENT = 11 -- Forever must not inherit a Retail level cap.
GetBlockChance = function() return 5 end
GetDodgeChance = GetBlockChance
GetParryChance = GetBlockChance
GetHaste = GetBlockChance
GetSpellCritChance = GetBlockChance
GetRangedCritChance = GetBlockChance
GetCritChance = GetBlockChance
GetSpellBonusDamage = function() return 30 end
GetManaRegen = function() return 10, 5 end
GetHealthRegen = function() return 12.5, 0 end
UnitAffectingCombat = function() return false end
UnitResistance = function() return 10, 10, 15, 5 end
UnitDefenseSkill = function() return 295, 5 end
C_SkillInfo = { GetSkillLineInfoByID = function(id)
	if id == 43 then return { name = "Swords", rank = 280, maxRank = 300, modifier = 5, tempPoints = 0 } end
end }
UnitXP = function() return xp end
UnitXPMax = function() return maxXP end
UnitLevel = function() return level end
GetXPExhaustion = function() return 0 end
GetLocale = function() return "enUS" end
issecretvalue = function() return hiddenStat end
MAX_SPELL_SCHOOLS, min = 7, math.min
TitanGetVar = function(id, key) return states[id][key] end
TitanPanelButton_UpdateButton = function() end
TitanUtils_GetHighlightText = tostring
ToggleCharacter = function() end
-- Secure click setup waits for the real UI to exist; this suite tests stats.
InCombatLockdown = function() return true end
CreateFrame = function()
	return { SetScript = function() end, RegisterEvent = function() end }
end
ToggleFrame = function() end
WorldMapFrame = {}
local rows = {
	{ isHeader = true }, { questID = 101 }, { questID = 102 },
	{ questID = 103 }, { questID = 104, isHidden = true },
}
C_QuestLog = {
	GetNumQuestLogEntries = function() return #rows, 4 end,
	GetMaxNumQuestsCanAccept = function() return 25 end,
	GetInfo = function(index) return rows[index] end,
	IsComplete = function(id) return id == 101 end,
}
local function register(config)
	assert(not configs[config.id], "Duplicate plugin: " .. config.id)
	configs[config.id], states[config.id] = config, config.savedVariables
	return {}
end
LibStub = function(name)
	if name == "Elib-4.0" then return { Register = register } end
	return { GetLocale = function() return {} end }
end
local L = {}
local function loadAddon(path, namespace) assert(loadfile(path))("TitanAttributesMulti", namespace or L) end
local manifest = assert(io.open("TitanAttributesMulti_Camelot.toc"))
for line in manifest:lines() do
	local path = line:gsub("\r", ""):gsub("\\", "/")
	if path:match("%.lua$") and not path:find("ElioteDropDownMenu", 1, true)
		and not path:find("Elib-4.0", 1, true) then loadAddon(path) end
end
manifest:close()
local frames, count = {}, 0
for id, config in pairs(configs) do
	count = count + 1
	frames[id] = { registry = { id = id }, UnregisterEvent = function() end }
	local event = config.eventsTable and config.eventsTable.PLAYER_ENTERING_WORLD
	if event then event(frames[id]) end
	if config.onUpdate then config.onUpdate(frames[id], id) end
	assert(type(select(2, config.getButtonText(frames[id], id))) == "string", id)
	assert(type(config.getTooltipText(frames[id], id)) == "string", id)
end
assert(count == 23 and L.IsForever)
assert(not configs.TITAN_MASTM) -- No Retail mastery plugin.
local function text(id) return select(2, configs[id].getButtonText(frames[id], id)) end
local function update(id) configs[id].onUpdate(frames[id], id) end
local function balance(id, value)
	states[id].ShowBarBalance = true
	assert(text(id):find(value, 1, true), text(id))
end
local spirit, hit, experience, quests = "TITAN_SPRTM", "TITAN_HTCHM", "TITAN_XPRCTM", "TITAN_QUESSM"
assert(text(spirit):find("50", 1, true))
assert(text(hit):find("3.00%", 1, true))
stats[5], rating = 55, 3
update(spirit); update(hit)
balance(spirit, "[5]"); balance(hit, "[1.00%]")
hiddenStat = true
stats[5], rating = 80, 20
update(spirit); update(hit)
assert(text(spirit):find("55", 1, true) and text(hit):find("4.00%", 1, true))
hiddenStat = false
assert(text(experience):find("50.0%", 1, true))
level, xp, maxXP = 60, 0, 0
configs[experience].eventsTable.PLAYER_XP_UPDATE(frames[experience])
assert(text(experience):find(L.maxlvl, 1, true))
assert(configs[experience].getTooltipText() == L.maxttp)
assert(configs[quests].getTooltipText():find(L.compquest .. "\t|cFFFFFFFF1", 1, true))
assert(configs[quests].getTooltipText():find(L.numquests .. "\t|cFFFFFFFF3", 1, true))
print("PASS: 23 Forever plugins, modern quests, stat sessions, inaccessible stats, level 60 without division by zero")

-- Verify shared XP and icon changes stay isolated from existing clients.
for _, scenario in ipairs({ {0,60}, {1,70}, {4,90}, {11,90} }) do
	LE_EXPANSION_LEVEL_CURRENT = scenario[1]
	level, xp, maxXP = scenario[2] - 1, 50, 100
	configs, states = {}, {}
	local namespace = {}
	loadAddon("Core/languages/enUS-default.lua", namespace)
	loadAddon("Core/AttributesCore.lua", namespace)
	ICON = "sentinel"
	loadAddon("Stats/TitanStrength.lua", namespace)
	loadAddon("Stats/TitanIntellect.lua", namespace)
	loadAddon("Misc/TitanXP.lua", namespace)
	assert(ICON == "sentinel")
	local frame = { registry = { id = experience } }
	configs[experience].eventsTable.PLAYER_XP_UPDATE(frame)
	assert(select(2, configs[experience].getButtonText(frame, experience)):find("50.0%", 1, true))
	level, xp, maxXP = scenario[2], 0, 0
	configs[experience].eventsTable.PLAYER_XP_UPDATE(frame)
	assert(select(2, configs[experience].getButtonText(frame, experience)):find(namespace.maxlvl, 1, true))
end
print("PASS: existing Classic, TBC, Mists and Retail XP paths; local icon variables")
