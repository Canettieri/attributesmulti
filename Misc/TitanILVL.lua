--[[
Description: This plugin is part of the "Titan Panel [Attributes] Multi" addon. It shows your Item Level.
Site: https://www.curseforge.com/wow/addons/titan-panel-attributes-multi
Author: Eliote, Canettieri
--]]

local ADDON_NAME, L = ...;
local version = GetAddOnMetadata(ADDON_NAME, "Version")
local ID = "TITAN_ILEM"
local startattribute
local charname = "|c" .. RAID_CLASS_COLORS[select(2, UnitClass("player"))].colorStr .. UnitName("player")
-----------------------------------------------
local function OnClick(self, button)
	if (button == "LeftButton") then
		ToggleCharacter("PaperDollFrame");
	end
end
-----------------------------------------------
local function GetButtonText(self, id)
	local _, ilvlEquipped = GetAverageItemLevel()

	local BarBalanceText = ""
	if ilvlEquipped and TitanGetVar(ID, "ShowBarBalance") then
		if (ilvlEquipped - startattribute) > 0 then
			BarBalanceText = " |cFF69FF69["..(string.format("%.1f", (ilvlEquipped - startattribute))).."]"
		elseif (ilvlEquipped - startattribute) < 0 then
			BarBalanceText = " |cFFFF2e2e["..(string.format("%.1f", (ilvlEquipped - startattribute))).."]"
		end
	end

	local valor = "0"
	if ilvlEquipped then
		valor = TitanUtils_GetHighlightText(string.format("%.1f", ilvlEquipped))
	end

	return L["ilvl"]..": ", valor..BarBalanceText
end
-----------------------------------------------
local function GetTooltipText(self, id)
	local ilvlOverall, ilvlEquipped = GetAverageItemLevel()

	local ColorValueAccount -- Cores da conta de valor
	if not ilvlEquipped then
		ColorValueAccount = ""
	elseif (ilvlEquipped - startattribute) == 0 then
		ColorValueAccount = TitanUtils_GetHighlightText("0")
	elseif (ilvlEquipped - startattribute) > 0 then
		ColorValueAccount = "|cFF69FF69"..(string.format("%.1f", (ilvlEquipped - startattribute)))
	elseif (ilvlEquipped - startattribute) < 0 then
		ColorValueAccount = "|cFFFF2e2e"..(string.format("%.1f", (ilvlEquipped - startattribute)))
	end

	local overall = "0"
	if ilvlEquipped then
		overall = TitanUtils_GetHighlightText(string.format("%.1f", ilvlOverall))
	end

	local equipped = "0"
	if ilvlOverall then
		equipped = TitanUtils_GetHighlightText(string.format("%.1f", ilvlEquipped))
	end

	return L["moreinfo"]..charname.."|r|cFFFFFFFF.|r\n \n"..L["overall"].."\t"..overall.."\n"..L["equipped"].."\t"..equipped.."\n"..L["session"].."\t"..ColorValueAccount
end
-----------------------------------------------
local eventsTable = {
	["PLAYER_ENTERING_WORLD"] = function(self)
		local ilvlOverall, ilvlEquipped = GetAverageItemLevel()
		if not startattribute then startattribute = ilvlEquipped end

		TitanPanelButton_UpdateButton(self.registry.id)
	end,
	["PLAYER_AVG_ITEM_LEVEL_UPDATE"] = function(self)
		TitanPanelButton_UpdateButton(self.registry.id)
	end
}
-----------------------------------------------
L.Elib({
	id = ID,
	name = "Titan|cFFf9251a "..L["ilvl"].."|r".." Multi",
	tooltip = L["ilvl"],
	icon = "Interface\\Icons\\INV_Helmet_02.blp",
	category = "Information",
	version = version,
	onClick = OnClick,
	getButtonText = GetButtonText,
	getTooltipText = GetTooltipText,
	eventsTable = eventsTable,
	prepareMenu = L.PrepareAttributesMenu,
	savedVariables = {
		ShowIcon = 1,
		DisplayOnRightSide = false,
		ShowBarBalance = false,
		ShowLabelText = false,
	}
})
