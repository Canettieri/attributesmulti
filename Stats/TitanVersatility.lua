--[[
Description: This plugin is part of the "Titan Panel [Attributes] Multi" addon. It shows your Versatility.
Site: https://www.curseforge.com/wow/addons/titan-panel-attributes-multi
Author: Canettieri
Special Thanks to Eliote.
--]]

local ADDON_NAME, L = ...;
local GetAddOnMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata
local version = GetAddOnMetadata(ADDON_NAME, "Version")
local ID = "TITAN_VERTM"
local VD, VT = 0, 0
local startattributeDone, startattributeTaken = 0, 0
local charname = "|c" .. RAID_CLASS_COLORS[select(2, UnitClass("player"))].colorStr .. UnitName("player").."|r"
-----------------------------------------------
local function OnClick(self, button)
	if (button == "LeftButton") then
		ToggleCharacter("PaperDollFrame");
	end
end
-----------------------------------------------
local function OnUpdate(self, id)
	local versaDone = GetCombatRatingBonus(29) or 0;
	local versaTaken = GetCombatRatingBonus(31) or 0;

	if VD == versaDone and VT == versaTaken then return end
	VD = versaDone
	VT = versaTaken

	TitanPanelButton_UpdateButton(id)
	return true
end
-----------------------------------------------
local function GetButtonText(self, id)
	local BarBalanceText = ""
	if TitanGetVar(ID, "ShowBarBalance") then
		local difDone = VD - startattributeDone
		local difTaking = VT - startattributeTaken

		if difDone > 0 then
			BarBalanceText = " |cFF69FF69["..(string.format("%.2f", difDone)).."% | "..(string.format("%.2f", difTaking)).."%".."]"
		elseif difDone < 0 then
			BarBalanceText = " |cFFFF2e2e["..(string.format("%.2f", difDone)).."% | "..(string.format("%.2f", difTaking)).."%".."]"
		end
	end

	local VDtext = "|cFFFFFFFF"..string.format("%.2f", VD) .."%".."|cFF69FF69||"
	local VTtext = "|cFFFFFFFF"..string.format("%.2f", VT) .."%"
	local bar = VDtext..VTtext

	return L["versatility"]..": ", bar..BarBalanceText
end
-----------------------------------------------
local function GetTooltipText(self, id)
	local text = TitanUtils_GetHighlightText("0% | 0%")

	local dif = VD - startattributeDone
	if dif > 0 then
		text = "|cFF69FF69"..(string.format("%.2f", (VD - startattributeDone))).."% | "..(string.format("%.2f", (VT - startattributeTaken))).."%"
	elseif dif < 0 then
		text = "|cFFFF2e2e"..(string.format("%.2f", (VD - startattributeDone))).."% | "..(string.format("%.2f", (VT - startattributeTaken))).."%"
	end

	return L["moreinfo"]..charname.."|cFFFFFFFF.|r\n \n"..L["versatDamHeal"]..":\t|cFFFFFFFF"..string.format("%.2f", VD).."%".."\n"..L["versatRec"]..":\t|cFFFFFFFF-"..string.format("%.2f", VT).."%".."|r\n"..L["session"].."\t"..text
end
-----------------------------------------------
local eventsTable = {
	PLAYER_ENTERING_WORLD = function(self)
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		self.PLAYER_ENTERING_WORLD = nil

		startattributeDone = GetCombatRatingBonus(29) or 0
		VD = startattributeDone
		startattributeTaken = GetCombatRatingBonus(31) or 0
		VT = startattributeTaken

		TitanPanelButton_UpdateButton(self.registry.id)
	end
}
-----------------------------------------------
L.Elib({
	id = ID,
	name = "Titan|cFFf9251a "..L["versatility"].."|r".." Multi",
	tooltip = L["versatility"],
	icon = "Interface\\Icons\\spell_deathknight_subversion.blp",
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
