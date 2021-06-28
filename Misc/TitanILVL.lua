--[[
Description: This plugin is part of the "Titan Panel [Attributes] Multi" addon. It shows your Item Level.
Site: https://www.curseforge.com/wow/addons/titan-panel-attributes-multi
Author: Eliote, Canettieri
--]]

local ADDON_NAME, L = ...;
local version = GetAddOnMetadata(ADDON_NAME, "Version")
local ID = "TITAN_ILEM"
local playerilvl = 0.0
local startattribute

local PLAYER_NAME, PLAYER_REALM
local PLAYER_KEY
local PLAYER_FACTION
local PLAYER_CLASS_COLOR
-----------------------------------------------
local function OnClick(self, button)
	if (button == "LeftButton") then
		ToggleCharacter("PaperDollFrame");
	end
end
-----------------------------------------------
local function GetCharTable()
	TitanAttributesMultiDb = TitanAttributesMultiDb or {}
	TitanAttributesMultiDb[ID] = TitanAttributesMultiDb[ID] or { charTable = {} }
	return TitanAttributesMultiDb[ID].charTable
end
local function GetAndSaveStats()
	local _, ilvlEquipped = GetAverageItemLevel()
	if not PLAYER_KEY then return ilvlEquipped end

	local charTable = GetCharTable()

	charTable[PLAYER_KEY] = charTable[PLAYER_KEY] or {}
	charTable[PLAYER_KEY].stats = ilvlEquipped
	charTable[PLAYER_KEY].name = PLAYER_CLASS_COLOR .. PLAYER_NAME
	charTable[PLAYER_KEY].faction = PLAYER_FACTION

	return ilvlEquipped
end
local function Update(self)
	local ilvlEquipped = GetAndSaveStats(ID)

	playerilvl = ilvlEquipped or 0
	if ilvlEquipped and not startattribute then startattribute = playerilvl end

	TitanPanelButton_UpdateButton(self.registry.id)
end
-----------------------------------------------
local eventsTable = {
	PLAYER_AVG_ITEM_LEVEL_UPDATE = Update,
	PLAYER_ENTERING_WORLD = function(self, ...)
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		self.PLAYER_ENTERING_WORLD = nil

		PLAYER_NAME, PLAYER_REALM = UnitFullName("player")
		PLAYER_KEY = PLAYER_NAME .. "-" .. PLAYER_REALM
		PLAYER_FACTION = UnitFactionGroup("player")
		PLAYER_CLASS_COLOR = "|c" .. RAID_CLASS_COLORS[select(2, UnitClass("player"))].colorStr

		Update(self)
	end,
}
-----------------------------------------------
local function GetButtonText(self, id)

	local BarBalanceText = ""
	if playerilvl and TitanGetVar(ID, "ShowBarBalance") then
		if (playerilvl - startattribute) > 0 then
			BarBalanceText = " |cFF69FF69["..(string.format("%.1f", (playerilvl - startattribute))).."]"
		elseif (playerilvl - startattribute) < 0 then
			BarBalanceText = " |cFFFF2e2e["..(string.format("%.1f", (playerilvl - startattribute))).."]"
		end
	end

	local valor = "0"
	if playerilvl then
		valor = TitanUtils_GetHighlightText(string.format("%.1f", playerilvl))
	end

	return L["ilvl"]..": ", valor..BarBalanceText
end
-----------------------------------------------
local function GetTooltipText(self, id)

	local ColorValueAccount -- Cores da conta de valor
	if not playerilvl then
		ColorValueAccount = ""
	elseif (playerilvl - startattribute) == 0 then
		ColorValueAccount = TitanUtils_GetHighlightText("0")
	elseif (playerilvl - startattribute) > 0 then
		ColorValueAccount = "|cFF69FF69"..(string.format("%.1f", (playerilvl - startattribute)))
	elseif (playerilvl - startattribute) < 0 then
		ColorValueAccount = "|cFFFF2e2e"..(string.format("%.1f", (playerilvl - startattribute)))
	end

	local ilvlOverall, _ = GetAverageItemLevel()
	local overall = "0"
	if ilvlOverall then
		overall = TitanUtils_GetHighlightText(string.format("%.1f", ilvlOverall))
	end

	local equipped = "0"
	if playerilvl then
		equipped = TitanUtils_GetHighlightText(string.format("%.1f", playerilvl))
	end

	local StatsText = PLAYER_CLASS_COLOR .. UnitName("player") .."|r|cFFFFFFFF.|r\n \n"..L["overall"].."\t"..overall.."\n"..L["equipped"].."\t"..equipped.."\n"..L["session"].."\t"..ColorValueAccount

	local charTable = GetCharTable()
	-- the current char first!
	StatsText = StatsText .. "\n \n" .. L["AltChars"] .. "\n" .. charTable[PLAYER_KEY].name .. "\t" .. "|cFFFFFFFF" .. (string.format("%.1f", playerilvl)) .. "\n|r"

	for k, v in pairs(charTable) do
		if k ~= PLAYER_KEY and PLAYER_FACTION == v.faction and (v.stats or 0) > 0 then
			StatsText = StatsText .. v.name .. "\t" .. "|cFFFFFFFF" .. (string.format("%.1f", v.stats)) .. "\n|r"
		end
	end

	return L["moreinfo"]..StatsText
end
-----------------------------------------------
L.Elib({
	id = ID,
	name = "Titan|cFFf9251a "..L["ilvl"].."|r".." Multi",
	tooltip = L["ilvl"],
	icon = "Interface\\Icons\\INV_Helmet_02.blp",
	category = "Information",
	version = version,
	onClick = OnClick,
	getButtonText = GetButtonText,
	getTooltipText = GetTooltipText,
	eventsTable = eventsTable,
	prepareMenu = L.PrepareAttributesMenu,
	savedVariables = {
		ShowIcon = 1,
		DisplayOnRightSide = false,
		ShowBarBalance = false,
		ShowLabelText = false,
	}
})
