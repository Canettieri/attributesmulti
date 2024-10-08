--[[
Description: This plugin is part of the "Titan Panel [Attributes] Multi" addon. It shows your Strength.
Site: https://www.curseforge.com/wow/addons/titan-panel-attributes-multi
Author: Canettieri
Special Thanks to Eliote.
--]]

local ADDON_NAME, L = ...;
local GetAddOnMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata
local version = GetAddOnMetadata(ADDON_NAME, "Version")
local ID = "TITAN_STGTHM"
local strn = 0
local startattribute = 0
local charname = "|c" .. RAID_CLASS_COLORS[select(2, UnitClass("player"))].colorStr .. UnitName("player").."|r"
-----------------------------------------------
local function OnClick(self, button)
	if (button == "LeftButton") then
		ToggleCharacter("PaperDollFrame");
	end
end
-----------------------------------------------
local function OnUpdate(self, id)
	local base, stat, posBuff, negBuff = UnitStat("player", 1) or 0;

	if strn == base then return end
	strn = base

	TitanPanelButton_UpdateButton(id)
	return true
end
-----------------------------------------------
local function GetButtonText(self, id)
	local BarBalanceText = ""
	if TitanGetVar(ID, "ShowBarBalance") then
		if (strn - startattribute) > 0 then
			BarBalanceText = " |cFF69FF69["..(strn - startattribute).."]"
		elseif (strn - startattribute) < 0 then
			BarBalanceText = " |cFFFF2e2e["..(strn - startattribute).."]"
		end
	end

	local strntext = "|cFFFFFFFF"..strn

	return L["strength"]..": ", strntext..BarBalanceText
end
-----------------------------------------------
local function GetTooltipText(self, id)
	local text = TitanUtils_GetHighlightText("0")

	local dif = strn - startattribute
	if dif > 0 then
		text = "|cFF69FF69"..(strn - startattribute)
	elseif dif < 0 then
		text = "|cFFFF2e2e"..(strn - startattribute)
	end

	return L["moreinfo"]..charname.."|cFFFFFFFF.|r\n \n"..L["strength"]..":\t|cFFFFFFFF"..strn.."|r\n"..L["session"].."\t"..text
end
-----------------------------------------------
local eventsTable = {
	PLAYER_ENTERING_WORLD = function(self)
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		self.PLAYER_ENTERING_WORLD = nil

		startattribute = UnitStat("player", 1) or 0
		strn = startattribute

		TitanPanelButton_UpdateButton(self.registry.id)
	end
}
-----------------------------------------------
L.Elib({
	id = ID,
	name = "Titan|cFFf9251a "..L["strength"].."|r".." Multi",
	tooltip = L["strength"],
	icon = "Interface\\Icons\\ability_rogue_kidneyshot",
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
