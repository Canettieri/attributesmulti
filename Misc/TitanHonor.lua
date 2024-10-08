--[[
Description: This plugin is part of the "Titan Panel [Attributes] Multi" addon. It shows your Honor Level.
Site: https://www.curseforge.com/wow/addons/titan-panel-attributes-multi
Author: Canettieri
Special Thanks to Eliote.
--]]

local ADDON_NAME, L = ...;
local ACE = LibStub("AceLocale-3.0"):GetLocale("Titan", true)
local GetAddOnMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata
local version = GetAddOnMetadata(ADDON_NAME, "Version")
local ID = "TITAN_HNRLLM"
local honor = 0
local honormax = 0
local honorlevel = 0
local CHARCOLOR = "|c" .. RAID_CLASS_COLORS[select(2, UnitClass("player"))].colorStr
-----------------------------------------------
local function OnClick(self, button)
	if (button == "LeftButton") then
		TogglePVPUI();
	end
end
-----------------------------------------------
local function OnUpdate(self, id)
	local hnr = UnitHonor("player");
	local hnrmax = UnitHonorMax("player");
	local hnrlvl = UnitHonorLevel("player");

	if honor == hnr and honormax == hnrmax and honorlevel == hnrlvl then return end
	honor = hnr
	honormax = hnrmax
	honorlevel = hnrlvl

	TitanPanelButton_UpdateButton(id)
	return true
end
-----------------------------------------------
local function GetButtonText(self, id)

	local diff = honormax - honor
	local porcentagem = (honor * 100 / honormax)
	local fulltext = "|cFFFFFFFF[|r"..CHARCOLOR..honorlevel.."|r|cFFFFFFFF]|r|cFF69FF69 "..honor.."|r|||cFFFFFFFF"..honormax.." |cFFFF2e2e("..diff..")|r |cFFFFFFFF[|cFF69FF69"..(string.format("%.1f", porcentagem)).."%|r|cFFFFFFFF]"
	local compacttext = "|cFFFFFFFF[|r"..CHARCOLOR..honorlevel.."|r|cFFFFFFFF]|r|cFF69FF69 "..honor.."|r|||cFFFFFFFF"..honormax

	local text = fulltext
	if TitanGetVar(ID, "SimpleText") then
		text = compacttext -- Texto simples
	end

	return L["hxp"]..": ", text
end
-----------------------------------------------
local function GetTooltipText(self, id)

	local diff = honormax - honor
	return L["hintpvp"].."\n \n"..L["hlvl"].."\t|cFFFFFFFF"..honorlevel.."|r\n"..L["hcurrent"].."\t|cFFFFFFFF"..honor.."|r\n"..L["hmax"].."\t|cFFFFFFFF"..honormax.."|r\n"..L["htoup"].."\t|cFFFFFFFF"..diff
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
	name = "Titan|cFFf9251a "..L["hxp"].."|r".." Multi",
	tooltip = L["hxp"],
	icon = "Interface\\Icons\\spell_warrior_gladiatorstance",
	category = "Information",
	version = version,
	onUpdate = OnUpdate,
	onClick = OnClick,
	getButtonText = GetButtonText,
	getTooltipText = GetTooltipText,
	prepareMenu = PrepareMenu,
	savedVariables = {
		ShowIcon = 1,
		DisplayOnRightSide = false,
		SimpleText = false,
		ShowBarBalance = false,
		ShowLabelText = false,
	},
})
