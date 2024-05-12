--[[
Description: This plugin is part of the "Titan Panel [Attributes] Multi" addon. It shows your Hit Change.
Site: https://www.curseforge.com/wow/addons/titan-panel-attributes-multi
Author: Canettieri
Special Thanks to Eliote.
--]]

local ADDON_NAME, L = ...;
local version = GetAddOnMetadata(ADDON_NAME, "Version")
local ID = "TITAN_HTCHM"
local hitChance = 0
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
	local HitRating  = GetCombatRatingBonus(CR_HIT_MELEE)
	if HitRating == nil then
		HitRating = 0
	end
	local hitModifier = HitRating + GetHitModifier();

	if hitChance == hitModifier then return end
	hitChance = hitModifier

	TitanPanelButton_UpdateButton(id)
	return true
end
-----------------------------------------------
local function GetButtonText(self, id)
	local BarBalanceText = ""
	if TitanGetVar(ID, "ShowBarBalance") then
		if (hitChance - startattribute) > 0 then
			BarBalanceText = " |cFF69FF69["..(string.format("%.2f", (hitChance - startattribute))).."%".."]"
		elseif (hitChance - startattribute) < 0 then
			BarBalanceText = " |cFFFF2e2e["..(hitChance - startattribute).."]"
		end
	end

	local hitChancetext = "|cFFFFFFFF"..(string.format("%.2f", hitChance)).."%"

	return L["hitCh"]..": ", hitChancetext..BarBalanceText
end
-----------------------------------------------
local function GetTooltipText(self, id)
	local text = TitanUtils_GetHighlightText("0")

	local dif = hitChance - startattribute
	if dif > 0 then
		text = "|cFF69FF69"..(string.format("%.2f", (hitChance - startattribute))).."%"
	elseif dif < 0 then
		text = "|cFFFF2e2e"..(string.format("%.2f", (hitChance - startattribute))).."%"
	end

	return L["moreinfo"]..charname.."|cFFFFFFFF.|r\n \n"..L["hitCh"]..":\t|cFFFFFFFF"..(string.format("%.2f", hitChance)).."%".."|r\n"..L["session"].."\t"..text
end
-----------------------------------------------
local eventsTable = {
	PLAYER_ENTERING_WORLD = function(self)
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		self.PLAYER_ENTERING_WORLD = nil

		startattribute = UnitStat("player", 1) or 0
		hitChance = startattribute

		TitanPanelButton_UpdateButton(self.registry.id)
	end
}
-----------------------------------------------
L.Elib({
	id = ID,
	name = "Titan|cFFf9251a "..L["hitCh"].."|r".." Multi",
	tooltip = L["hitCh"],
	icon = "Interface\\Icons\\inv_sword_23",
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
