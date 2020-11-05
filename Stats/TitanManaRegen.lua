--[[
Description: This plugin is part of the "Titan Panel [Attributes] Multi" addon. It shows your Mana Regeneration.
Site: http://www.curse.com/addons/wow/titan-panel-attributes-multi
Author: Canettieri
Special Thanks to Eliote.
--]]

local ADDON_NAME, L = ...;
local version = GetAddOnMetadata(ADDON_NAME, "Version")
local ID = "TITAN_MARGM"
local manaReg = 0
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
	local base, casting = GetManaRegen();

	if manaReg == base then return end
	manaReg = base

	TitanPanelButton_UpdateButton(id)
	return true
end
-----------------------------------------------
local function GetButtonText(self, id)
	local BarBalanceText = ""
	if TitanGetVar(ID, "ShowBarBalance") then
		local difBase = manaReg - startattribute
--		local difCasting = MC - startattributeWhile

		if difBase > 0 then
			BarBalanceText = " |cFF69FF69["..L.SimplifyNumber(difBase).."]"
		elseif difBase < 0 then
			BarBalanceText = " |cFFFF2e2e["..L.SimplifyNumber(difBase).."]"
		end
	end

	local manaRegtext = "|cFFFFFFFF"..L.SimplifyNumber(manaReg)
--	local MCtext = "|cFFFFFFFF"..L.SimplifyNumber(MC)
	local bar = manaRegtext

	return L["manareg"]..": ", bar..BarBalanceText
end
-----------------------------------------------
local function GetTooltipText(self, id)
	local text = TitanUtils_GetHighlightText("0")

	local dif = manaReg - startattribute
	if dif > 0 then
		text = "|cFF69FF69"..L.SimplifyNumber(manaReg - startattribute)
	elseif dif < 0 then
		text = "|cFFFF2e2e"..L.SimplifyNumber(manaReg - startattribute)
	end

	return L["moreinfo"]..charname.."|cFFFFFFFF.|r\n \n"..L["manareg"]..":\t|cFFFFFFFF"..string.format("%.2f", manaReg).."|r\n"..L["session"].."\t"..text
end
-----------------------------------------------
local eventsTable = {
	PLAYER_ENTERING_WORLD = function(self)
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		self.PLAYER_ENTERING_WORLD = nil

		manaReg = GetManaRegen();
		startattribute = manaReg

		TitanPanelButton_UpdateButton(self.registry.id)
	end
}
-----------------------------------------------
L.Elib({
	id = ID,
	name = "Titan|cFFf9251a "..L["manareg"].."|r".." Multi",
	tooltip = L["manareg"],
	icon = "Interface\\Icons\\spell_arcane_manatap.blp",
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
