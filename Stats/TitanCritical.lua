--[[
Description: This plugin is part of the "Titan Panel [Attributes] Multi" addon. It shows your Cricital Chance.
Site: https://www.curseforge.com/wow/addons/titan-panel-attributes-multi
Author: Canettieri
Special Thanks to Eliote.
--]]

local ADDON_NAME, L = ...;
local version = GetAddOnMetadata(ADDON_NAME, "Version")
local ID = "Titan_CTCM"
local critDmg = 0
local startattribute
local charname = "|c" .. RAID_CLASS_COLORS[select(2, UnitClass("player"))].colorStr .. UnitName("player").."|r"
-----------------------------------------------
local function OnClick(self, button)
	if (button == "LeftButton") then
		ToggleCharacter("PaperDollFrame");
	end
end
-----------------------------------------------
local function GetCrit()
	-- from Blizzards PaperDollFrame.lua
	local rating;
	local spellCrit, rangedCrit, meleeCrit;
	local critChance;
	-- Start at 2 to skip physical damage
	local holySchool = 2;
	local minCrit = GetSpellCritChance(holySchool);
	for i=(holySchool+1), MAX_SPELL_SCHOOLS do
		spellCrit = GetSpellCritChance(i);
		minCrit = min(minCrit, spellCrit);
	end
	spellCrit = minCrit
	rangedCrit = GetRangedCritChance();
	meleeCrit = GetCritChance();
	if (spellCrit >= rangedCrit and spellCrit >= meleeCrit) then
		critChance = spellCrit;
		rating = CR_CRIT_SPELL;
	elseif (rangedCrit >= meleeCrit) then
		critChance = rangedCrit;
		rating = CR_CRIT_RANGED;
	else
		critChance = meleeCrit;
		rating = CR_CRIT_MELEE;
	end

	return rating, critChance
end
-----------------------------------------------
local function OnUpdate(self, id)
	local rating, critChance = GetCrit()
	if critDmg == critChance then return end
	critDmg = critChance

	TitanPanelButton_UpdateButton(id)
	return true
end
-----------------------------------------------
local function GetButtonText(self, id)
	local BarBalanceText = ""
	if TitanGetVar(ID, "ShowBarBalance") then
		if (critDmg - startattribute) > 0 then
			BarBalanceText = " |cFF69FF69["..(string.format("%.2f", (critDmg - startattribute))).."%".."]"
		elseif (critDmg - startattribute) < 0 then
			BarBalanceText = " |cFFFF2e2e["..(string.format("%.2f", (critDmg - startattribute))).."%".."]"
		end
	end

	local CRtext = "|cFFFFFFFF"..string.format("%.2f", critDmg) .."%"

	return L["critical"]..": ", CRtext..BarBalanceText
end
-----------------------------------------------
local function GetTooltipText(self, id)
	local text = TitanUtils_GetHighlightText("0%")

	local dif = critDmg - startattribute -- Cores da conta de valor
	if dif > 0 then
		text = "|cFF69FF69"..(string.format("%.2f", (critDmg - startattribute))).."%"
	elseif dif < 0 then
		text = "|cFFFF2e2e"..(string.format("%.2f", (critDmg - startattribute))).."%"
	end

	return L["moreinfo"]..charname.."|cFFFFFFFF.|r\n \n"..L["critical"]..":\t|cFFFFFFFF"..string.format("%.2f", critDmg).."%".."|r\n"..L["session"].."\t"..text
end
-----------------------------------------------
local eventsTable = {
	PLAYER_ENTERING_WORLD = function(self)
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		self.PLAYER_ENTERING_WORLD = nil

		_, startattribute = GetCrit()
		critDmg = startattribute

		TitanPanelButton_UpdateButton(self.registry.id)
	end
}
-----------------------------------------------
L.Elib({
	id = ID,
	name = "Titan|cFFf9251a "..L["critical"].."|r".." Multi",
	tooltip = L["critical"],
	icon = "Interface\\Icons\\ability_rogue_combatexpertise.blp",
	category = "Information",
	version = version,
	onClick = OnClick,
	onUpdate = OnUpdate,
	getButtonText = GetButtonText,
	getTooltipText = GetTooltipText,
	prepareMenu = L.PrepareAttributesMenu,
	savedVariables = {
		ShowIcon = 1,
		DisplayOnRightSide = false,
		ShowBarBalance = false,
		ShowLabelText = false,
	},
	eventsTable = eventsTable
})
