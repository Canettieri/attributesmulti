--[[
Description: This plugin is part of the "Titan Panel [Attributes] Multi" addon. It shows your Leech tertiary stat.
Site: https://www.curseforge.com/wow/addons/titan-panel-attributes-multi
Author: Canettieri
--]]

local ADDON_NAME, L = ...;
local GetAddOnMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata
local version = GetAddOnMetadata(ADDON_NAME, "Version")
local ID = "TITAN_LEECH_TRT"
local LC = 0
local startattribute
local charname = "|c" .. RAID_CLASS_COLORS[select(2, UnitClass("player"))].colorStr .. UnitName("player").."|r"
-----------------------------------------------
local function OnClick(self, button)
	if (button == "LeftButton") then
		ToggleCharacter("PaperDollFrame");
	end
end
-----------------------------------------------
local function OnUpdate(self, id)
	local leech = GetLifesteal and GetLifesteal() or 0;

	if LC == leech then return end
	LC = leech

	TitanPanelButton_UpdateButton(id)
	return true
end
-----------------------------------------------
local function GetButtonText(self, id)
	local BarBalanceText = ""
	if TitanGetVar(ID, "ShowBarBalance") then
		if (LC - startattribute) > 0 then
			BarBalanceText = " |cFF69FF69["..(string.format("%.2f", (LC - startattribute))).."%".."]"
		elseif (LC - startattribute) < 0 then
			BarBalanceText = " |cFFFF2e2e["..(string.format("%.2f", (LC - startattribute))).."%".."]"
		end
	end

	local LCtext = "|cFFFFFFFF"..string.format("%.2f", LC) .."%"

	return L["leech"]..": ", LCtext..BarBalanceText
end
-----------------------------------------------
local function GetTooltipText(self, id)
	local text = TitanUtils_GetHighlightText("0%")

	local dif = LC - startattribute
	if dif > 0 then
		text = "|cFF69FF69"..(string.format("%.2f", (LC - startattribute))).."%"
	elseif dif < 0 then
		text = "|cFFFF2e2e"..(string.format("%.2f", (LC - startattribute))).."%"
	end

	return L["moreinfo"]..charname.."|cFFFFFFFF.|r\n \n"..L["leech"]..":\t|cFFFFFFFF"..string.format("%.2f", LC).."%".."|r\n"..L["session"].."\t"..text
end
-----------------------------------------------
local eventsTable = {
	PLAYER_ENTERING_WORLD = function(self)
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		self.PLAYER_ENTERING_WORLD = nil

		startattribute = GetLifesteal and GetLifesteal() or 0
		LC = startattribute

		TitanPanelButton_UpdateButton(self.registry.id)
	end
}
-----------------------------------------------
L.Elib({
	id = ID,
	name = "Titan|cFFf9251a "..L["leech"].."|r".." Multi",
	tooltip = L["leech"],
	icon = "Interface\\Icons\\spell_shadow_lifedrain02.blp",
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
