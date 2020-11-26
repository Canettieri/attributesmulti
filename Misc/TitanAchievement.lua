--[[
Description: This plugin is part of the "Titan Panel [Attributes] Multi" addon. It shows your Achievement.
Site: https://www.curseforge.com/wow/addons/titan-panel-attributes-multi
Author: Canettieri
Special Thanks to Eliote.
--]]

local ADDON_NAME, L = ...;
local version = GetAddOnMetadata(ADDON_NAME, "Version")
local ID = "TITAN_ACHEVM"
local achiev = 0
local startattribute = 0
-----------------------------------------------
local function OnClick(self, button)
	if (button == "LeftButton") then
		ToggleAchievementFrame();
	end
end
-----------------------------------------------
local function OnUpdate(self, id)
	local achievementpts = GetTotalAchievementPoints()

	if achiev == achievementpts then return end
	achiev = achievementpts

	TitanPanelButton_UpdateButton(id)
	return true
end
-----------------------------------------------
local function GetButtonText(self, id)
	local BarBalanceText = ""
	if TitanGetVar(ID, "ShowBarBalance") then
		if (achiev - startattribute) > 0 then
			BarBalanceText = " |cFF69FF69["..(achiev - startattribute).."]"
		elseif (achiev - startattribute) < 0 then
			BarBalanceText = " |cFFFF2e2e["..(achiev - startattribute).."]"
		end
	end

	local armortext = "|cFFFFFFFF"..achiev

	return L["achieve"]..": ", armortext..BarBalanceText
end
-----------------------------------------------
local function GetTooltipText(self, id)
	local text = TitanUtils_GetHighlightText("0")

	local dif = achiev - startattribute
	if dif > 0 then
		text = "|cFF69FF69"..(achiev - startattribute)
	elseif dif < 0 then
		text = "|cFFFF2e2e"..(achiev - startattribute)
	end

	return L["hintachiev"].."\n \n"..L["achievepts"]..":\t|cFFFFFFFF"..achiev.."|r\n"..L["session"].."\t"..text
end
-----------------------------------------------
local eventsTable = {
	PLAYER_ENTERING_WORLD = function(self)
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		self.PLAYER_ENTERING_WORLD = nil

		startattribute = GetTotalAchievementPoints() or 0
		achiev = startattribute

		TitanPanelButton_UpdateButton(self.registry.id)
	end
}
-----------------------------------------------
L.Elib({
	id = ID,
	name = "Titan|cFFf9251a "..L["achieve"].."|r".." Multi",
	tooltip = L["achieve"],
	icon = "Interface\\Icons\\achievement_bg_killflagcarriers_grabflag_capit",
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
