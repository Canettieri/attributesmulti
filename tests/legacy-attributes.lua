-- Run from the addon root with Lua 5.1. Native combat restrictions need in-game tests.
local configs, vars, updates, locale = {}, {}, 0, "enUS"
local resistance, defense, bonus, rank = 25, 295, 5, 280
local hidden = false
local maceAvailable = true
local level = 60
UnitLevel = function() return level end
UnitAffectingCombat = function() return false end
local secret = newproxy(true)
getmetatable(secret).__add = function() error("Secret arithmetic") end
getmetatable(secret).__tostring = function() error("Secret formatting") end
C_AddOns = { GetAddOnMetadata = function() return "test" end }
GetLocale = function() return locale end
UnitClass = function() return "Mage", "MAGE" end
UnitName = function() return "Tester" end
RAID_CLASS_COLORS = { MAGE = { colorStr = "ffffffff" } }
issecretvalue = function(value) return rawequal(value, secret) end
TitanGetVar = function(id, key) return vars[id][key] end
TitanSetVar = function(id, key, value) vars[id][key] = value end
TitanPanelButton_UpdateButton = function() updates = updates + 1 end
local function Load(path, L) assert(loadfile(path))("TitanAttributesMulti", L) end
local function Register(config) configs[config.id] = config; vars[config.id] = config.savedVariables end
local function Text(id) return (select(2, configs[id].getButtonText()):gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")) end
local function Refresh(id) configs[id].onUpdate() end
local equippedItem = 1
GetInventoryItemTexture = function(unit, slot) assert(unit == "player" and slot == 16); if equippedItem == 3 then return secret end; return equippedItem and 1000 + equippedItem end
GetInventoryItemID = function(_, slot) assert(slot == 16); return equippedItem end
GetItemInfoInstant = function(id) return nil, nil, nil, nil, 1000 + id, 2, id == 1 and 7 or id >= 3 and 4 or 0 end
TitanUtils_GetPlugin = function(id) return configs[id] end
UnitResistance = function(_, school) assert(school >= 2 and school <= 6); return 0, 0, hidden and secret or resistance + school, 0 end
UnitDefenseSkill = function() return hidden and secret or defense, bonus end
local function Skill(id)
	if id == 43 then return { name = "Swords", rank = hidden and secret or rank, maxRank = 300, modifier = 5, tempPoints = 2 } end
	if id == 44 then return { name = "Axes", rank = 100, maxRank = 300, modifier = 0, tempPoints = 0 } end
	if id == 54 and maceAvailable then return { name = "Maces", rank = 125, maxRank = 300, modifier = 0, tempPoints = 0 } end
end
local R, D, W = "TITAN_RESISTANCES", "TITAN_DEFENSE", "TITAN_WEAPON_SKILLS"
for _, language in ipairs({ "enUS", "ptBR", "deDE", "esES", "koKR", "ruRU" }) do
	locale = language
	configs, vars = {}, {}
	equippedItem = 1
	local L = { Elib = Register, IsForever = true, PrepareAttributesMenu = function() end }
	Load("Core/languages/enUS-default.lua", L)
	if locale ~= "enUS" then Load("Core/languages/" .. locale .. ".lua", L) end
	Load("Core/LegacyAttributes.lua", L)
	C_SkillInfo = { GetSkillLineInfoByID = Skill }
	for _, module in ipairs({ "TitanResistances", "TitanDefense", "TitanWeaponSkills" }) do Load("Stats/" .. module .. ".lua", L) end
	resistance, defense, bonus, rank, hidden = 25, 295, 5, 280, false
	for _, id in ipairs({R,D,W}) do Refresh(id); assert(configs[id].getTooltipText():find("Tester", 1, true)) end
	assert(configs[R].hideLabelOption and not configs[R].hideIconOption)
	assert(not configs[D].hideLabelOption and configs[D].hideIconOption)
	assert(not configs[W].hideLabelOption and configs[W].hideIconOption)
	assert(Text(R):find("27", 1, true) and Text(D):find("300", 1, true) and Text(W):find("287/300", 1, true))
	local _, iconCount = Text(R):gsub("|TInterface", "")
	assert(iconCount == 5 and not Text(R):find("Fire:", 1, true))
	for _, top in ipairs({ 0, 29, 87, 116, 58 }) do
		assert(Text(R):find(":32:256:0:32:" .. top .. ":" .. (top + 29) .. "|t", 1, true))
	end
	assert(configs[R].getTooltipText():find(L.LegacyAttributes.Hint() .. "Fire:", 1, true) == 1)
	assert(not configs[R].getTooltipText():find(L.session, 1, true))
	assert(configs[W].getTooltipText():find(L.LegacyAttributes.Hint() .. "Swords:", 1, true) == 1)
	for _, school in ipairs({ "Fire", "Nature", "Frost", "Shadow", "Arcane" }) do assert(configs[R].getTooltipText():find(school .. ":", 1, true)) end
	assert(not Text(R):find("Holy", 1, true) and #configs[R].menus == 1)
	assert(Text(D):find("300/300", 1, true))
	assert(select(2, configs[D].getButtonText()):find("|r/|cFFFF2e2e300|r", 1, true))
	assert(select(2, configs[W].getButtonText()):find("|r/|cFFFF2e2e300|r", 1, true))
	assert(configs[D].getTooltipText():find(L.defense .. ":\t|cFFFFFFFF300|r", 1, true))
	assert(not configs[D].getTooltipText():find(L.attributeBase .. ":", 1, true))
	assert(configs[D].getTooltipText():find(L.defenseMaximum .. ":\t|cFFFFFFFF300|r", 1, true))
	assert(configs[D].getTooltipText():find(L.attributeBonus .. ":", 1, true))
	bonus = 0; Refresh(D)
	assert(not configs[D].getTooltipText():find(L.attributeBonus .. ":", 1, true))
	bonus = 5; Refresh(D)
	level = 61; Refresh(D); assert(Text(D):find("300/305", 1, true))
	level = 60; Refresh(D)
	local before = updates
	for _, id in ipairs({R,D,W}) do Refresh(id) end
	assert(updates == before)
	-- All schools stay on the bar; learned weapon skills remain selectable.
	assert(Text(R):find("31", 1, true))
	assert(configs[W].icon == 1001)
	equippedItem = 3; configs[W].eventsTable.PLAYER_EQUIPMENT_CHANGED()
	assert(Text(W):find("125/300", 1, true) and configs[W].icon == 1003)
	configs[W].menus[7].func()
	assert(vars[W].Skill == 54 and configs[W].icon == 1003)
	equippedItem = 4; configs[W].eventsTable.PLAYER_EQUIPMENT_CHANGED()
	assert(configs[W].icon == 1004)
	equippedItem = 3; configs[W].eventsTable.PLAYER_EQUIPMENT_CHANGED()
	maceAvailable = false; Refresh(W)
	assert(Text(W):find("—", 1, true) and configs[W].icon == 1003)
	configs[W].menus[4].func()
	assert(Text(W):find("—", 1, true) and configs[W].icon == 1003)
	maceAvailable = true; Refresh(W)
	configs[W].menus[4].func()
	equippedItem = 2; configs[W].eventsTable.PLAYER_EQUIPMENT_CHANGED()
	assert(Text(W):find("100/300", 1, true) and configs[W].icon == 1002)
	configs[W].menus[6].func(); assert(vars[W].Skill == 44)
	equippedItem = 1; configs[W].eventsTable.PLAYER_EQUIPMENT_CHANGED()
	assert(Text(W):find("100/300", 1, true) and configs[W].icon == 1001)
	equippedItem = nil; configs[W].eventsTable.PLAYER_EQUIPMENT_CHANGED()
	assert(configs[W].icon == "Interface\\Icons\\ability_meleedamage")
	equippedItem = 1; configs[W].eventsTable.PLAYER_EQUIPMENT_CHANGED()
	configs[W].menus[4].func()
	assert(vars[W].Skill == 0 and Text(W):find("287/300", 1, true) and configs[W].icon == 1001)
	configs[W].menus[6].func()
	bonus = -5; Refresh(D)
	assert(Text(D):find("290", 1, true) and configs[D].getTooltipText():find("|cFFFF2e2e-10", 1, true))
	assert(configs[D].prepareMenu == L.PrepareAttributesMenu and not vars[D].ShowBarBalance)
	assert(not Text(D):find("[-10]", 1, true))
	vars[D].ShowBarBalance = true
	assert(Text(D):find("[-10]", 1, true))
	bonus = 10; Refresh(D); assert(Text(D):find("[5]", 1, true))
	vars[D].ShowBarBalance, bonus = false, -5; Refresh(D)
	hidden = true
	for _, id in ipairs({R,D,W}) do Refresh(id) end
	assert(Text(R):find("—", 1, true) and Text(D):find("—", 1, true))
	configs[D].eventsTable.PLAYER_REGEN_DISABLED()
	assert(select(2, configs[D].getButtonText()) == "|cFFFF2e2e" .. L.healthRegenCombatText .. "|r")
	configs[D].eventsTable.PLAYER_REGEN_ENABLED()
	assert(Text(D):find("—", 1, true))
	configs[D].eventsTable.PLAYER_REGEN_DISABLED()
	hidden = false; Refresh(D)
	assert(Text(D):find("290/300", 1, true))
	configs[D].eventsTable.PLAYER_REGEN_ENABLED()
	hidden = true
	TitanSetVar(W, "Skill", 43); assert(Text(W):find("—/300", 1, true))
	hidden, bonus, rank = false, 5, 285
	Refresh(W); assert(Text(W):find("292/300", 1, true))
	assert(configs[W].getTooltipText():find("|cFF69FF695", 1, true))
	local balanceOption = configs[W].menus[2]
	assert(configs[W].menus[1].type == "rightSideToggle")
	assert(balanceOption.type == "toggle" and balanceOption.var == "ShowBarBalance" and balanceOption.text == L.showbb)
	assert(not Text(W):find("[5]", 1, true))
	vars[W].ShowBarBalance = true
	assert(Text(W):find("[5]", 1, true))
	TitanSetVar(W, "Skill", 44); assert(not Text(W):find("[5]", 1, true))
	TitanSetVar(W, "Skill", 43)
	rank = 270; Refresh(W); assert(Text(W):find("[-10]", 1, true))
	vars[W].ShowBarBalance = false; assert(not Text(W):find("[-10]", 1, true))
	-- Legacy clients: localize proficiency names, exclude professions and headers.
	C_SkillInfo = nil
	GetSpellInfo = function(id) if id == 201 then return "Swords" elseif id == 196 then return "Axes" end end
	GetNumSkillLines = function() return 3 end
	GetSkillLineInfo = function(index)
		if index == 1 then return "Weapons", true end
		if index == 2 then return "Swords", false, false, 250, 2, 5, 300 end
		return "Alchemy", false, false, 300, 0, 0, 300
	end
	issecretvalue = nil
	Load("Stats/TitanWeaponSkills.lua", L); Refresh(W)
	assert(Text(W):find("257/300", 1, true) and #configs[W].menus == 5)
	assert(not configs[W].getTooltipText():find("Alchemy", 1, true))
	SKILL_HEADER_WEAPON_SKILLS = "Weapons"
	GetSpellInfo = function() return "Different proficiency name" end
	GetNumSkillLines = function() return 4 end
	GetSkillLineInfo = function(index)
		if index == 1 then return "Weapons", true end
		if index == 2 then return "Localized Swords", false, false, 250, 2, 5, 300 end
		if index == 3 then return "Professions", true end
		return "Alchemy", false, false, 300, 0, 0, 300
	end
	Load("Stats/TitanWeaponSkills.lua", L); Refresh(W)
	assert(Text(W):find("—", 1, true))
	configs[W].menus[5].func()
	assert(Text(W):find("257/300", 1, true) and #configs[W].menus == 5)
	assert(not configs[W].getTooltipText():find("Alchemy", 1, true))
	SKILL_HEADER_WEAPON_SKILLS = nil
	issecretvalue = function(value) return rawequal(value, secret) end
	-- Legacy resistance signatures return the effective total second, not the buff third.
	L.IsForever = false
	local originalResistance = UnitResistance
	UnitResistance = function(_, school) assert(school >= 2 and school <= 6); return 10, 60 + school, 5, -2 end
	Load("Stats/TitanResistances.lua", L); Refresh(R)
	assert(Text(R):find("62", 1, true) and Text(R):find("66", 1, true))
	UnitResistance = originalResistance
end
local registered = false
UnitResistance, UnitDefenseSkill, C_SkillInfo, GetNumSkillLines, GetSkillLineInfo = nil, nil, nil, nil, nil
local empty = { Elib = function() registered = true end }
for _, module in ipairs({ "TitanResistances", "TitanDefense", "TitanWeaponSkills" }) do Load("Stats/" .. module .. ".lua", empty) end
assert(not registered)
print("PASS: resistances, defense, modern/legacy weapon skills, menus, bonuses, sessions, six locales and protected/missing APIs")
