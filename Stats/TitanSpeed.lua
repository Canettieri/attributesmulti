--[[
Description: This plugin is part of the "Titan Panel [Attributes] Multi" addon. It shows your Speed tertiary stat.
Site: https://www.curseforge.com/wow/addons/titan-panel-attributes-multi
Author: Canettieri
--]]

local ADDON_NAME, L = ...;
local GetAddOnMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata
local version = GetAddOnMetadata(ADDON_NAME, "Version")
local ID = "TITAN_SPEED_TRT"
local SP = 0
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
	local speed = GetSpeed and GetSpeed() or 0;

	if SP == speed then return end
	SP = speed

	TitanPanelButton_UpdateButton(id)
	return true
end
-----------------------------------------------
local function GetButtonText(self, id)
	local BarBalanceText = ""
	if TitanGetVar(ID, "ShowBarBalance") then
		if (SP - startattribute) > 0 then
			BarBalanceText = " |cFF69FF69["..(string.format("%.2f", (SP - startattribute))).."%".."]"
		elseif (SP - startattribute) < 0 then
			BarBalanceText = " |cFFFF2e2e["..(string.format("%.2f", (SP - startattribute))).."%".."]"
		end
	end

	local SPtext = "|cFFFFFFFF"..string.format("%.2f", SP) .."%"

	return L["speed"]..": ", SPtext..BarBalanceText
end
-----------------------------------------------
local function GetTooltipText(self, id)
	local text = TitanUtils_GetHighlightText("0%")

	local dif = SP - startattribute
	if dif > 0 then
		text = "|cFF69FF69"..(string.format("%.2f", (SP - startattribute))).."%"
	elseif dif < 0 then
		text = "|cFFFF2e2e"..(string.format("%.2f", (SP - startattribute))).."%"
	end

	return L["moreinfo"]..charname.."|cFFFFFFFF.|r\n \n"..L["speed"]..":\t|cFFFFFFFF"..string.format("%.2f", SP).."%".."|r\n"..L["session"].."\t"..text
end
-----------------------------------------------
local eventsTable = {
	PLAYER_ENTERING_WORLD = function(self)
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		self.PLAYER_ENTERING_WORLD = nil

		startattribute = GetSpeed and GetSpeed() or 0
		SP = startattribute

		TitanPanelButton_UpdateButton(self.registry.id)
	end
}
-----------------------------------------------
L.Elib({
	id = ID,
	name = "Titan|cFFf9251a "..L["speed"].."|r".." Multi",
	tooltip = L["speed"],
	icon = "Interface\\Icons\\ability_rogue_sprint.blp",
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
