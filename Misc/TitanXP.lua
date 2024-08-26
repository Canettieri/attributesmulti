--[[
Description: This plugin is part of the "Titan Panel [Attributes] Multi" addon. It shows your XP.
Site: https://www.curseforge.com/wow/addons/titan-panel-attributes-multi
Author: Canettieri
Special Thanks to Eliote.
--]]

local ADDON_NAME, L = ...;
local ACE = LibStub("AceLocale-3.0"):GetLocale("Titan", true)
local GetAddOnMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata
local version = GetAddOnMetadata(ADDON_NAME, "Version")
local ID = "TITAN_XPRCTM"
local AXP
local MXP
local PERC
local LVL
local EXXP
local CHARCOLOR = "|c" .. RAID_CLASS_COLORS[select(2, UnitClass("player"))].colorStr.."|r"
local charname = "|c" .. RAID_CLASS_COLORS[select(2, UnitClass("player"))].colorStr .. UnitName("player").."|r"

if UnitFactionGroup("Player") == "Alliance" then
ICON = "1498974"
else
ICON = "1498975"
end
-----------------------------------------------
local function OnClick(self, button)
	if (button == "LeftButton") then
		ToggleCharacter("PaperDollFrame");
	end
end
-----------------------------------------------
local function UpdateAll(self)

	--local restState = GetRestState();
	local pXP, pMaxXP = UnitXP("player"), UnitXPMax("player"); -- Quantidade atual e quantidade máxima do nível atual
	local rPos = (pXP / pMaxXP) * 100; -- Porcentagem do nível atual
	local level = UnitLevel("player") -- Nível do personagem
	local exhaustionXP = GetXPExhaustion() -- Rest XP

	AXP = pXP
	MXP = pMaxXP
	PERC = rPos
	LVL = level
	EXXP = exhaustionXP or 0

	TitanPanelButton_UpdateButton(self.registry.id)
end
-----------------------------------------------
local eventsTable = {
	PLAYER_XP_UPDATE = UpdateAll,
	PLAYER_ENTERING_WORLD = UpdateAll, -- Jogador entra no Mundo
	PLAYER_UPDATE_RESTING = UpdateAll,
	PLAYER_LEVEL_UP = UpdateAll,
	UPDATE_EXHAUSTION = UpdateAll, -- Atualiza rest XP em tempo real
}
-----------------------------------------------
local function GetButtonText(self, id)

	if LVL < 80 then
		local toUp = MXP - AXP
		local restperc = (EXXP / ((MXP / 100) * 1.5))

		local XPrest = "   |TInterface\\Icons\\spell_nature_sleep:0|t |cFFFFFFFF[|r|cffe6cc80" .. (string.format("%.1f", restperc)) .. "%|r|cFFFFFFFF] " .. (formatNumber(EXXP, '.'))
		if TitanGetVar(id, "HideRest") or EXXP == 0 then
			XPrest = ""
		end

		local XPtext = "|cFFFFFFFF[|r" .. CHARCOLOR .. LVL .. "|cFFFFFFFF]|r|cFF69FF69 " .. (formatNumber(AXP, '.')) .. "|r|||cFFFFFFFF" .. (formatNumber(MXP, '.')) .. " |cFFFF2e2e(" .. (formatNumber(toUp, '.')) .. ")|r |cFFFFFFFF[|cFF69FF69" .. (string.format("%.1f", PERC)) .. "%|r|cFFFFFFFF]"

		local Btext = XPtext .. XPrest
		if TitanGetVar(id, "SimpleText") then
			Btext = "|cFF69FF69 " .. (formatNumber(AXP, '.')) .. "|r|||cFFFFFFFF" .. (formatNumber(MXP, '.')) .. " |cFFFFFFFF[|cFF69FF69" .. (string.format("%.1f", PERC)) .. "%|r|cFFFFFFFF] "
		end

		return L["xp"] .. ": ", Btext

	else
		return L["xp"] .. ": ", "|cFFFFFFFF[|r" .. CHARCOLOR .. LVL .. "|cFFFFFFFF]|cFF69FF69 " .. L["maxlvl"]
	end
end
-----------------------------------------------
local function GetTooltipText(self, id)
	if LVL < 80 then
		local toUp = MXP - AXP
		local restperc = (EXXP / ((MXP / 100) * 1.5))

		local AXPttp = L["actualXP"] .. "\t|cFFFFFFFF" .. (formatNumber(AXP, '.')) .. "|r\n"
		local MXPttp = L["needXP"] .. "\t|cFFFFFFFF" .. (formatNumber(MXP, '.')) .. "|r\n"
		local toUpttp = L["XPtoUp"] .. "\t|cFFFFFFFF" .. (formatNumber(toUp, '.')) .. "|r\n"
		local PERCttp = L["percentage"] .. "\t|cFFFFFFFF" .. (string.format("%.1f", PERC)) .. "%|r"
		local EXXPttp = L["restxp"] .. "\t|cFFFFFFFF" .. (formatNumber(EXXP, '.')) .. "|r\n"
		local PERCRttp = L["restprogr"] .. "\t|cFFFFFFFF" .. (string.format("%.1f", restperc)) .. "%"

		local restInttp = "\n \n" .. L["restttp"] .. "\n" .. EXXPttp .. PERCRttp
		if EXXP == 0 then
			restInttp = ""
		end

		local ttpText = L["moreinfo"] .. charname .. "|cFFFFFFFF.|r\n \n" .. AXPttp .. MXPttp .. toUpttp .. PERCttp .. restInttp

		return ttpText

	else
		return L["maxttp"]
	end
end
-----------------------------------------------
function PrepareMenu(eddm, self, id)
	eddm.UIDropDownMenu_AddButton({
		text = TitanPlugins[id].menuText,
		hasArrow = false,
		isTitle = true,
		isUninteractable = true,
		notCheckable = true
	})

	local info = {};
	info.text = L["simpleText"];
	info.func = function() TitanToggleVar(id, "SimpleText"); TitanPanelButton_UpdateButton(id); end
	info.checked = TitanGetVar(id, "SimpleText");
	info.keepShownOnClick = true
	eddm.UIDropDownMenu_AddButton(info);

	local info = {};
	info.text = L["hiderest"];
	info.func = function() TitanToggleVar(id, "HideRest"); TitanPanelButton_UpdateButton(id); end
	info.checked = TitanGetVar(id, "HideRest");
	info.keepShownOnClick = true
	eddm.UIDropDownMenu_AddButton(info);

	local info = {};
	info.text = ACE["TITAN_CLOCK_MENU_DISPLAY_ON_RIGHT_SIDE"];
	info.func = function() TitanToggleVar(id, "DisplayOnRightSide"); TitanPanel_InitPanelButtons(id); end
	info.checked = TitanGetVar(id, "DisplayOnRightSide");
	info.keepShownOnClick = true
	eddm.UIDropDownMenu_AddButton(info);

	eddm.UIDropDownMenu_AddSpace();

	eddm.UIDropDownMenu_AddButton({
		notCheckable = true,
		text = ACE["TITAN_PANEL_MENU_HIDE"],
		func = function() TitanPanelRightClickMenu_Hide(id) end
	})

	eddm.UIDropDownMenu_AddSeparator();

	info = {};
	info.text = CLOSE;
	info.notCheckable = true
	info.keepShownOnClick = false
	eddm.UIDropDownMenu_AddButton(info);
end
-----------------------------------------------
L.Elib({
	id = ID,
	name = "Titan|cFFf9251a " .. L["xp"] .. " Multi",
	tooltip = L["xp"],
	icon = ICON,
	category = "Information",
	version = version,
	onClick = OnClick,
	getButtonText = GetButtonText,
	getTooltipText = GetTooltipText,
	eventsTable = eventsTable,
	prepareMenu = PrepareMenu,
	savedVariables = {
		ShowIcon = 1,
		DisplayOnRightSide = false,
		SimpleText = false,
		HideRest = false,
		ShowLabelText = false,
	},
})
