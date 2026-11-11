local ADDON_NAME, L = ...
if type(UnitResistance) ~= "function" then return end
local A, ID = L.LegacyAttributes, "TITAN_RESISTANCES"
-- Resistance indices: 0 Physical, 1 Holy, 2 Fire through 6 Arcane.
local schools = { 2, 3, 4, 5, 6 }
-- Native character-sheet resistance icons: a 32x256 sheet with 29px rows.
local iconRows = { [2] = 0, [3] = 1, [4] = 3, [5] = 4, [6] = 2 }
local function SchoolIcon(school)
	local top = iconRows[school] * 29
	return "|TInterface\\PaperDollInfoFrame\\UI-Character-ResistanceIcons:14:14:0:0:32:256:0:32:"
		.. top .. ":" .. (top + 29) .. "|t"
end
local fallback = {}
for index, name in ipairs({ "Fire", "Nature", "Frost", "Shadow", "Arcane" }) do fallback[schools[index]] = name end
local values = {}
local function SchoolName(school) return _G["RESISTANCE" .. school .. "_NAME"] or fallback[school] end
local function Refresh()
	local changed = false
	for _, school in ipairs(schools) do
		local ok, value = pcall(function()
			local _, total, effective = UnitResistance("player", school)
			if L.IsForever then return A.Number(effective) end
			return A.Number(total)
		end)
		if not ok then value = nil end
		if values[school] ~= value then changed = true end
		values[school] = value
	end
	if changed then TitanPanelButton_UpdateButton(ID) end
	return true
end
A.Register(ADDON_NAME, ID, L.resistances, "Interface\\Icons\\spell_nature_resistmagic", Refresh,
	function()
		local parts = {}
		for _, school in ipairs(schools) do
			parts[#parts + 1] = SchoolIcon(school) .. " |cFFFFFFFF" .. A.Format(values[school]) .. "|r"
		end
		return L.resistances .. ": ", table.concat(parts, "  ")
	end,
	function()
		local lines = {}
		for _, school in ipairs(schools) do lines[#lines + 1] = A.Row(SchoolName(school), A.Format(values[school])) end
		return A.Hint() .. table.concat(lines, "\n")
	end, { { type = "rightSideToggle" }, showIconOption = true, hideLabelOption = true })
