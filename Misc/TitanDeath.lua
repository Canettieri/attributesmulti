--[[
Description: This plugin is part of the "Titan Panel [Attributes] Multi" addon. It shows your Player Deaths.
Site: https://www.curseforge.com/wow/addons/titan-panel-attributes-multi
Author: Canettieri
Special Thanks to Eliote.
--]]

local ADDON_NAME, L = ...;
local GetAddOnMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata
local version = GetAddOnMetadata(ADDON_NAME, "Version")
local ID = "TITAN_PYDTHM"
local dth = 0
local startattribute = 0
local ICON

if UnitFactionGroup("Player") == "Alliance" then
ICON ="Interface\\Icons\\inv_misc_head_human_01"
else
ICON = "Interface\\Icons\\inv_misc_head_orc_01"
end
-----------------------------------------------
local function OnUpdate(self, id)
	local death = GetStatistic(60);
	death = tonumber(death) or 0

	if dth == death then return end
	dth = death

	TitanPanelButton_UpdateButton(id)
	return true
end
-----------------------------------------------
local function GetButtonText(self, id)
	local BarBalanceText = ""
	if TitanGetVar(ID, "ShowBarBalance") then
		if (dth - startattribute) > 0 then
			BarBalanceText = " |cFF69FF69["..(dth - startattribute).."]"
		elseif (dth - startattribute) < 0 then
			BarBalanceText = " |cFFFF2e2e["..(dth - startattribute).."]"
		end
	end

	local dthtext = "|cFFFFFFFF"..dth

	return L["death"]..": ", dthtext..BarBalanceText
end
-----------------------------------------------
local function GetTooltipText(self, id)
	local text = TitanUtils_GetHighlightText("0")

	local dif = dth - startattribute
	if dif > 0 then
		text = "|cFF69FF69"..(dth - startattribute)
	elseif dif < 0 then
		text = "|cFFFF2e2e"..(dth - startattribute)
	end

	return L["deathinfo"].."\n \n"..L["death"]..":\t|cFFFFFFFF"..dth.."|r\n"..L["session"].."\t"..text
end
-----------------------------------------------
local eventsTable = {
	PLAYER_ENTERING_WORLD = function(self)
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		self.PLAYER_ENTERING_WORLD = nil

		startattribute = GetStatistic(60)
		startattribute = tonumber(startattribute) or 0
		dth = startattribute

		TitanPanelButton_UpdateButton(self.registry.id)
	end
}
-----------------------------------------------
L.Elib({
	id = ID,
	name = "Titan|cFFf9251a "..L["death"].."|r".." Multi",
	tooltip = L["death"],
	icon = ICON,
	category = "Information",
	version = version,
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
