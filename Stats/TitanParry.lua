--[[
Description: This plugin is part of the "Titan Panel [Attributes] Multi" addon. It shows your Parry Chance.
Site: https://www.curseforge.com/wow/addons/titan-panel-attributes-multi
Author: Canettieri
Special Thanks to Eliote.
--]]

local ADDON_NAME, L = ...;
local GetAddOnMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata
local version = GetAddOnMetadata(ADDON_NAME, "Version")
local ID = "TITAN_PRRM"
local PR = 0
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
	local parry = GetParryChance() or 0;

	if PR == parry then return end
	PR = parry

	TitanPanelButton_UpdateButton(id)
	return true
end
-----------------------------------------------
local function GetButtonText(self, id)
	local BarBalanceText = ""
	if TitanGetVar(ID, "ShowBarBalance") then
		if (PR - startattribute) > 0 then
			BarBalanceText = " |cFF69FF69["..(string.format("%.2f", (PR - startattribute))).."%".."]"
		elseif (PR - startattribute) < 0 then
			BarBalanceText = " |cFFFF2e2e["..(string.format("%.2f", (PR - startattribute))).."%".."]"
		end
	end

	local PRtext = "|cFFFFFFFF"..string.format("%.2f", PR) .."%"

	return L["parry"]..": ", PRtext..BarBalanceText
end
-----------------------------------------------
local function GetTooltipText(self, id)
	local text = TitanUtils_GetHighlightText("0%")

	local dif = PR - startattribute -- Cores da conta de valor
	if dif > 0 then
		text = "|cFF69FF69"..(string.format("%.2f", (PR - startattribute))).."%"
	elseif dif < 0 then
		text = "|cFFFF2e2e"..(string.format("%.2f", (PR - startattribute))).."%"
	end

	return L["moreinfo"]..charname.."|cFFFFFFFF.|r\n \n"..L["parry"]..":\t|cFFFFFFFF"..string.format("%.2f", PR).."%".."|r\n"..L["session"].."\t"..text
end
-----------------------------------------------
local eventsTable = {
	PLAYER_ENTERING_WORLD = function(self)
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		self.PLAYER_ENTERING_WORLD = nil

		startattribute = GetParryChance() or 0
		PR = startattribute

		TitanPanelButton_UpdateButton(self.registry.id)
	end
}
-----------------------------------------------
L.Elib({
	id = ID,
	name = "Titan|cFFf9251a "..L["parry"].."|r".." Multi",
	tooltip = L["parryt"],
	icon = "Interface\\Icons\\ability_parry.blp",
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
