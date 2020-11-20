--[[
Description: This plugin is part of the "Titan Panel [Attributes] Multi" addon. It shows your Quests.
Site: http://www.curse.com/addons/wow/titan-panel-attributes-multi
Author: Canettieri
Special Thanks to Eliote.
--]]

local ADDON_NAME, L = ...;
local ACE = LibStub("AceLocale-3.0"):GetLocale("Titan", true)
local version = GetAddOnMetadata(ADDON_NAME, "Version")
local ID = "TITAN_QUESSM"
local activeQuests = 0 -- Questas ativas
local completedQuests = 0 -- Quests completas
local maxNumQuests = C_QuestLog.GetMaxNumQuestsCanAccept() -- num máximo de quests
-----------------------------------------------
local function OnClick(self, button)
	if (button == "LeftButton") then
		ToggleFrame(WorldMapFrame);
	end
end
-----------------------------------------------
local function UpdateAll(self)
	local numShownEntries, numQuests = C_QuestLog.GetNumQuestLogEntries();

	activeQuests = 0
	completedQuests = 0

	for questIndex = 1, numShownEntries do
			local info = C_QuestLog.GetInfo(questIndex)
			if info then
				local questId, isHeader, isHidden = info.questID, info.isHeader, info.isHidden
				if questId and questId > 0 and not isHeader and not isHidden then
					activeQuests = activeQuests + 1
					local isComplete = C_QuestLog.IsComplete(questId)
					if isComplete then completedQuests = completedQuests + 1 end
				end
			end
		end

	TitanPanelButton_UpdateButton(self.registry.id)
end
-----------------------------------------------
local eventsTable = {
	UNIT_QUEST_LOG_CHANGED = UpdateAll;
	PLAYER_ENTERING_WORLD = UpdateAll; -- Jogador entra no Mundo
--	QUEST_COMPLETE = UpdateAll;
--	QUEST_ACCEPTED = UpdateAll;
--  QUEST_FINISHED = UpdateAll;
	QUEST_LOG_UPDATE = UpdateAll;
--	QUEST_LOG_UPDATE = function(self) self:UnregisterEvent("QUEST_LOG_UPDATE"); UpdateAll(self) end
}
-----------------------------------------------
local function GetButtonText(self, id)

	local activedText
	if activeQuests > 15 and activeQuests < 20 then
		activedText = "|cFFf6ed12"..activeQuests
	elseif activeQuests > 19 and activeQuests < 25 then
		activedText = "|cFFf69112"..activeQuests
	elseif activeQuests == 25 then
		activedText = "|cFFFF2e2e"..activeQuests
	else
		activedText = TitanUtils_GetHighlightText(activeQuests)
	end

	return L["quests"]..": ", "|cFFFFFFFF[|r|cFF69FF69"..completedQuests.."|r|cFFFFFFFF]|r "..activedText.."|r|||cFFFF2e2e"..maxNumQuests
end
-----------------------------------------------
local function GetTooltipText(self, id)

	return L["hintquest"].."\n \n"..L["compquest"].."\t|cFFFFFFFF"..completedQuests.."|r\n"..L["numquests"].."\t|cFFFFFFFF"..activeQuests.."|r\n"..L["maxquests"].."\t|cFFFFFFFF"..maxNumQuests
end
-----------------------------------------------
local function PrepareMenu(self, id)
	TitanPanelRightClickMenu_AddTitle(TitanPlugins[id].menuText)
	TitanPanelRightClickMenu_AddToggleIcon(id)
	TitanPanelRightClickMenu_AddToggleLabelText(id)

	local info = UIDropDownMenu_CreateInfo();
	info = {};
	info.text = ACE["TITAN_CLOCK_MENU_DISPLAY_ON_RIGHT_SIDE"];
	info.func = ToggleRightSideDisplay;
	info.arg1 = id
	info.checked = TitanGetVar(id, "DisplayOnRightSide");
	info.keepShownOnClick = true
	L_UIDropDownMenu_AddButton(info);

	TitanPanelRightClickMenu_AddSpacer();
	TitanPanelRightClickMenu_AddCommand(ACE["TITAN_PANEL_MENU_HIDE"], id, TITAN_PANEL_MENU_FUNC_HIDE);
	L_UIDropDownMenu_AddSeparator()

	info = {};
	info.text = CLOSE;
	info.notCheckable = true
	info.keepShownOnClick = false
	L_UIDropDownMenu_AddButton(info);
end
-----------------------------------------------
L.Elib({
	id = ID,
	name = "Titan|cFFf9251a "..L["quests"].."|r".." Multi",
	tooltip = L["quests"],
	icon = "Interface\\Icons\\inv_misc_map07",
	category = "Information",
	version = version,
	eventsTable = eventsTable,
	onClick = OnClick,
	getButtonText = GetButtonText,
	getTooltipText = GetTooltipText,
	prepareMenu = PrepareMenu,
	savedVariables = {
		ShowIcon = 1,
		DisplayOnRightSide = false,
		ShowBarBalance = false,
		ShowLabelText = false,
	},
})
