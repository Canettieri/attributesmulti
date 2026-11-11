local ADDON_NAME, L = ...
local modern = C_SkillInfo and type(C_SkillInfo.GetSkillLineInfoByID) == "function"
local legacy = type(GetNumSkillLines) == "function" and type(GetSkillLineInfo) == "function"
if not modern and not legacy then return end
local A, ID = L.LegacyAttributes, "TITAN_WEAPON_SKILLS"
-- Skill line ID and corresponding weapon-proficiency spell for localized legacy lookup.
local weapons = { {43,201}, {44,196}, {45,264}, {46,266}, {54,198}, {55,202}, {136,227},
	{160,199}, {162,203}, {172,197}, {173,1180}, {176,2567}, {226,5011}, {228,5009}, {229,200}, {473,15590} }
local rows, starts, snapshot = {}, {}, ""
local defaultIcon = "Interface\\Icons\\ability_meleedamage"
local subclassSkills = { [0] = 44, 172, 45, 46, 54, 160, 229, 43, 55,
	[10] = 136, [13] = 473, [15] = 173, [16] = 176, [18] = 226, [19] = 228 }
local equippedSkill, equippedName, equippedIcon

local function ProficiencyName(spellID)
	if C_Spell and C_Spell.GetSpellInfo then
		local spell = C_Spell.GetSpellInfo(spellID)
		return spell and A.Text(spell.name)
	end
	if GetSpellInfo then return A.Text(GetSpellInfo(spellID)) end
end

local function ReadEquipment()
	if not GetInventoryItemID then return end
	local slot = INVSLOT_MAINHAND or 16
	local item = GetInventoryItemID("player", slot)
	if issecretvalue and issecretvalue(item) then return end
	local skill, icon
	if item == nil then
		skill = 162
	else
		local itemInfo = C_Item and C_Item.GetItemInfoInstant or GetItemInfoInstant
		if not itemInfo then return end
		local _, _, _, _, texture, class, subclass = itemInfo(item)
		icon = A.Number(texture) or A.Text(texture)
		if A.Number(class) ~= 2 then return nil, nil, icon end
		subclass = A.Number(subclass)
		skill = subclass and subclassSkills[subclass]
	end
	for _, weapon in ipairs(weapons) do
		if weapon[1] == skill then return skill, ProficiencyName(weapon[2]), icon end
	end
	return nil, nil, icon
end

local function Selected()
	local selected = TitanGetVar(ID, "Skill")
	if not selected or selected == 0 then
		for _, row in ipairs(rows) do
			if row.id == equippedSkill or row.name == equippedName then return row end
		end
	else
		for _, row in ipairs(rows) do
			if row.id == selected or row.name == selected then return row end
		end
	end
end
local function SkillText(row)
	if not row then return "—" end
	return A.Format(row.value) .. "/" .. A.Format(row.maximum)
end
local function ReadSkills()
	local result, legacyNames = {}, {}
	if not modern then
		local weaponHeader = SKILL_HEADER_WEAPON_SKILLS or HEADER_WEAPON_SKILLS or WEAPON_SKILLS
		local inWeapons, foundHeader = false, false
		for index = 1, GetNumSkillLines() do
			local name, header, _, rank, temp, modifier, maximum = GetSkillLineInfo(index)
			name = A.Text(name)
			if header then
				inWeapons = weaponHeader ~= nil and name == weaponHeader
				if inWeapons then foundHeader = true end
	elseif name then
				legacyNames[name] = { name = name, rank = rank, tempPoints = temp, modifier = modifier, maxRank = maximum }
				if inWeapons then
					rank, temp, modifier, maximum = A.Number(rank), A.Number(temp), A.Number(modifier), A.Number(maximum)
					local value
					if rank ~= nil and temp ~= nil and modifier ~= nil then value = rank + temp + modifier end
					result[#result + 1] = { id = name, name = name, value = value, maximum = maximum }
				end
			end
		end
		if foundHeader then return result end
	end
	for _, weapon in ipairs(weapons) do
		local skill
		if modern then skill = C_SkillInfo.GetSkillLineInfoByID(weapon[1])
		else
			local name = ProficiencyName(weapon[2])
			if name then skill = legacyNames[name] end
		end
		if skill then
			local name, rank, maximum = A.Text(skill.name), A.Number(skill.rank), A.Number(skill.maxRank)
			local modifier, temp = A.Number(skill.modifier), A.Number(skill.tempPoints)
			local value
			if rank ~= nil and modifier ~= nil and temp ~= nil then value = rank + modifier + temp end
			if name then result[#result + 1] = { id = weapon[1], name = name, value = value, maximum = maximum } end
		end
	end
	return result
end
local menus = {
	{ type = "rightSideToggle" },
	{ type = "toggle", text = L.showbb, var = "ShowBarBalance", def = false, keepShown = true, barOption = true },
	{ type = "title", text = L.weaponSkillSelect },
}
local function UpdateDisplay()
	local plugin = TitanUtils_GetPlugin and TitanUtils_GetPlugin(ID) or TitanPlugins and TitanPlugins[ID]
	if plugin then plugin.icon = equippedIcon or defaultIcon end
	TitanPanelButton_UpdateButton(ID)
end

local function Refresh()
	local ok, result = pcall(ReadSkills)
	rows = ok and result or {}
	local equipmentOK, skill, name, itemIcon = pcall(ReadEquipment)
	if not equipmentOK then skill, name = nil, nil end
	local iconOK, texture = pcall(GetInventoryItemTexture, "player", INVSLOT_MAINHAND or 16)
	local icon = iconOK and (A.Number(texture) or A.Text(texture)) or itemIcon
	local equipmentChanged = equippedSkill ~= skill or equippedName ~= name or equippedIcon ~= icon
	equippedSkill, equippedName, equippedIcon = skill, name, icon
	local lines = {}
	for _, row in ipairs(rows) do
		if starts[row.id] == nil and row.value ~= nil then starts[row.id] = row.value end
		lines[#lines + 1] = row.name .. ":" .. SkillText(row)
	end
	-- Reuse the menu table retained by Elib; include only learned weapon skills.
	for index = #menus, 4, -1 do menus[index] = nil end
	menus[4] = { type = "button", text = L.weaponSkillAutomatic, func = function()
		TitanSetVar(ID, "Skill", 0)
		UpdateDisplay()
	end }
	for _, row in ipairs(rows) do
		local choice = row.id
		menus[#menus + 1] = { type = "button", text = row.name, func = function()
			TitanSetVar(ID, "Skill", choice)
			UpdateDisplay()
		end }
	end
	local nextSnapshot = table.concat(lines, "\n")
	local plugin = TitanUtils_GetPlugin and TitanUtils_GetPlugin(ID) or TitanPlugins and TitanPlugins[ID]
	if equipmentChanged or nextSnapshot ~= snapshot or (plugin and plugin.icon ~= (icon or defaultIcon)) then
		snapshot = nextSnapshot
		UpdateDisplay()
	end
	return true
end
A.Register(ADDON_NAME, ID, L.weaponSkills, defaultIcon, Refresh,
	function()
		local row = Selected()
		local text = "—"
		if row then text = A.Format(row.value) .. "|r/|cFFFF2e2e" .. A.Format(row.maximum) end
		local balance = ""
		if TitanGetVar(ID, "ShowBarBalance") and row and row.value ~= nil and starts[row.id] ~= nil then
			local delta = row.value - starts[row.id]
			if delta ~= 0 then
				local color = delta > 0 and "|cFF69FF69" or "|cFFFF2e2e"
				balance = " " .. color .. "[" .. A.Format(delta) .. "]|r"
			end
		end
		return (row and row.name or L.weaponSkills) .. ": ", "|cFFFFFFFF" .. text .. "|r" .. balance
	end,
	function()
		local lines = {}
		for _, row in ipairs(rows) do lines[#lines + 1] = A.Row(row.name, SkillText(row)) end
		if #rows == 0 then lines[#lines + 1] = "—" end
		local row = Selected()
		lines[#lines + 1] = L.session .. "\t" .. (row and A.Balance(row.value, starts[row.id]) or "—")
		return A.Hint() .. table.concat(lines, "\n")
	end, menus, { Skill = 0, ShowBarBalance = false }, nil, {
		PLAYER_ENTERING_WORLD = Refresh,
		PLAYER_EQUIPMENT_CHANGED = Refresh,
	})
