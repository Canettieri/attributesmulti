--[[
Description: This plugin is part of the "Titan Panel [Attributes] Multi" addon. It shows your Armor.
Site: https://www.curseforge.com/wow/addons/titan-panel-attributes-multi
Author: Canettieri
Special Thanks to Eliote.
--]]

local ADDON_NAME, L = ...;
local version = GetAddOnMetadata(ADDON_NAME, "Version")
local ID = "TITAN_ARMRM"
local amr = 0
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
	local base, effectiveArmor, armor, posBuff, negBuff = UnitArmor("player", 0)

	if amr == armor then return end
	amr = armor

	TitanPanelButton_UpdateButton(id)
	return true
end
-----------------------------------------------
local function GetButtonText(self, id)
	local BarBalanceText = ""
	if TitanGetVar(ID, "ShowBarBalance") then
		if (amr - startattribute) > 0 then
			BarBalanceText = " |cFF69FF69["..(amr - startattribute).."]"
		elseif (amr - startattribute) < 0 then
			BarBalanceText = " |cFFFF2e2e["..(amr - startattribute).."]"
		end
	end

	local armortext = "|cFFFFFFFF"..amr

	return L["armor"]..": ", armortext..BarBalanceText
end
-----------------------------------------------
local function GetTooltipText(self, id)
	local text = TitanUtils_GetHighlightText("0")

	local dif = amr - startattribute
	if dif > 0 then
		text = "|cFF69FF69"..(amr - startattribute)
	elseif dif < 0 then
		text = "|cFFFF2e2e"..(amr - startattribute)
	end

	return L["moreinfo"]..charname.."|cFFFFFFFF.|r\n \n"..L["armor"]..":\t|cFFFFFFFF"..amr.."|r\n"..L["session"].."\t"..text
end
-----------------------------------------------
local eventsTable = {
	PLAYER_ENTERING_WORLD = function(self)
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		self.PLAYER_ENTERING_WORLD = nil

		startattribute = UnitArmor("player") or 0
		amr = startattribute

		TitanPanelButton_UpdateButton(self.registry.id)
	end
}
-----------------------------------------------
L.Elib({
	id = ID,
	name = "Titan|cFFf9251a "..L["armor"].."|r".." Multi",
	tooltip = L["armor"],
	icon = "Interface\\Icons\\inv_chest_plate05",
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
