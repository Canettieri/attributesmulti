--[[
Description: This plugin is part of the "Titan Panel [Attributes] Multi" addon. It shows your Avoidance tertiary stat.
Site: https://www.curseforge.com/wow/addons/titan-panel-attributes-multi
Author: Canettieri
--]]

local ADDON_NAME, L = ...;
local GetAddOnMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata
local version = GetAddOnMetadata(ADDON_NAME, "Version")
local ID = "TITAN_AVOID_TRT"
local AV = 0
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
	local avoidance = GetAvoidance and GetAvoidance() or 0;

	if AV == avoidance then return end
	AV = avoidance

	TitanPanelButton_UpdateButton(id)
	return true
end
-----------------------------------------------
local function GetButtonText(self, id)
	local BarBalanceText = ""
	if TitanGetVar(ID, "ShowBarBalance") then
		if (AV - startattribute) > 0 then
			BarBalanceText = " |cFF69FF69["..(string.format("%.2f", (AV - startattribute))).."%".."]"
		elseif (AV - startattribute) < 0 then
			BarBalanceText = " |cFFFF2e2e["..(string.format("%.2f", (AV - startattribute))).."%".."]"
		end
	end

	local AVtext = "|cFFFFFFFF"..string.format("%.2f", AV) .."%"

	return L["avoidance"]..": ", AVtext..BarBalanceText
end
-----------------------------------------------
local function GetTooltipText(self, id)
	local text = TitanUtils_GetHighlightText("0%")

	local dif = AV - startattribute
	if dif > 0 then
		text = "|cFF69FF69"..(string.format("%.2f", (AV - startattribute))).."%"
	elseif dif < 0 then
		text = "|cFFFF2e2e"..(string.format("%.2f", (AV - startattribute))).."%"
	end

	return L["moreinfo"]..charname.."|cFFFFFFFF.|r\n \n"..L["avoidance"]..":\t|cFFFFFFFF"..string.format("%.2f", AV).."%".."|r\n"..L["session"].."\t"..text
end
-----------------------------------------------
local eventsTable = {
	PLAYER_ENTERING_WORLD = function(self)
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		self.PLAYER_ENTERING_WORLD = nil

		startattribute = GetAvoidance and GetAvoidance() or 0
		AV = startattribute

		TitanPanelButton_UpdateButton(self.registry.id)
	end
}
-----------------------------------------------
L.Elib({
	id = ID,
	name = "Titan|cFFf9251a "..L["avoidance"].."|r".." Multi",
	tooltip = L["avoidance"],
	icon = "Interface\\Icons\\rogue_burstofspeed",
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
