--[[
Description: This plugin is part of the "Titan Panel [Attributes] Multi" addon. It shows your Honorable Kills.
Site: https://www.curseforge.com/wow/addons/titan-panel-attributes-multi
Author: Canettieri
Special Thanks to Eliote.
--]]

local ADDON_NAME, L = ...;
local version = GetAddOnMetadata(ADDON_NAME, "Version")
local ID = "TITAN_HONKLM"
local hkill = 0
local startattribute = 0
local ICON

if UnitFactionGroup("Player") == "Alliance" then
ICON ="Interface\\Icons\\achievement_pvp_a_a"
else
ICON = "Interface\\Icons\\achievement_pvp_h_h"
end
-----------------------------------------------
local function OnClick(self, button)
	if (button == "LeftButton") then
		TogglePVPUI();
	end
end
-----------------------------------------------
local function OnUpdate(self, id)
	local hk, highestRank = GetPVPLifetimeStats() or 0;

	if hkill == hk then return end
	hkill = hk

	TitanPanelButton_UpdateButton(id)
	return true
end
-----------------------------------------------
local function GetButtonText(self, id)
	local BarBalanceText = ""
	if TitanGetVar(ID, "ShowBarBalance") then
		if (hkill - startattribute) > 0 then
			BarBalanceText = " |cFF69FF69["..(hkill - startattribute).."]"
		elseif (hkill - startattribute) < 0 then
			BarBalanceText = " |cFFFF2e2e["..(hkill - startattribute).."]"
		end
	end

	local hkilltext = "|cFFFFFFFF"..hkill

	return L["hk"]..": ", hkilltext..BarBalanceText
end
-----------------------------------------------
local function GetTooltipText(self, id)
	local text = TitanUtils_GetHighlightText("0")

	local dif = hkill - startattribute
	if dif > 0 then
		text = "|cFF69FF69"..(hkill - startattribute)
	elseif dif < 0 then
		text = "|cFFFF2e2e"..(hkill - startattribute)
	end

	return L["hintpvp"].."\n \n"..L["hk"]..":\t|cFFFFFFFF"..hkill.."|r\n"..L["session"].."\t"..text
end
-----------------------------------------------
local eventsTable = {
	PLAYER_ENTERING_WORLD = function(self)
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		self.PLAYER_ENTERING_WORLD = nil

		startattribute = GetPVPLifetimeStats() or 0
		hkill = startattribute

		TitanPanelButton_UpdateButton(self.registry.id)
	end
}
-----------------------------------------------
L.Elib({
	id = ID,
	name = "Titan|cFFf9251a "..L["hk"].."|r".." Multi",
	tooltip = L["hk"],
	icon = ICON,
	category = "Information",
	version = version,
	onUpdate = OnUpdate,
	onClick = OnClick,
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
