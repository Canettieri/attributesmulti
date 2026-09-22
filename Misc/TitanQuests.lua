--[[
Description: This plugin is part of the "Titan Panel [Attributes] Multi" addon. It shows your Quests.
Site: https://www.curseforge.com/wow/addons/titan-panel-attributes-multi
Author: Canettieri
Special Thanks to Eliote.
--]]

local ADDON_NAME, L = ...;
local ACE = LibStub("AceLocale-3.0"):GetLocale("Titan", true)
local GetAddOnMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata
local version = GetAddOnMetadata(ADDON_NAME, "Version")
local ID = "TITAN_QUESSM"
local activeQuests = 0 -- Questas ativas
local completedQuests = 0 -- Quests completas
local maxNumQuests = 0
-----------------------------------------------
local function OnClick(self, button)
	if (button == "LeftButton") then
		ToggleFrame(WorldMapFrame);
	end
end
-----------------------------------------------
local function UpdateAll(self)
	local numShownEntries, numQuests = C_QuestLog.GetNumQuestLogEntries();
	local currentMaxNumQuests = C_QuestLog.GetMaxNumQuestsCanAccept()
	if currentMaxNumQuests and currentMaxNumQuests > 0 then
		maxNumQuests = currentMaxNumQuests
	end

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

	local activedText = TitanUtils_GetHighlightText(activeQuests)
	if maxNumQuests > 0 then
		local questLimitRatio = activeQuests / maxNumQuests
		if questLimitRatio >= 1 then
			activedText = "|cFFFF2e2e"..activeQuests
		elseif questLimitRatio >= 0.8 then
			activedText = "|cFFf69112"..activeQuests
		elseif questLimitRatio >= 0.6 then
			activedText = "|cFFf6ed12"..activeQuests
		end
	end

	return L["quests"]..": ", "|cFFFFFFFF[|r|cFF69FF69"..completedQuests.."|r|cFFFFFFFF]|r "..activedText.."|r|||cFFFF2e2e"..maxNumQuests
end
-----------------------------------------------
local function GetTooltipText(self, id)

	return L["hintquest"].."\n \n"..L["compquest"].."\t|cFFFFFFFF"..completedQuests.."|r\n"..L["numquests"].."\t|cFFFFFFFF"..activeQuests.."|r\n"..L["maxquests"].."\t|cFFFFFFFF"..maxNumQuests
end
-----------------------------------------------
function PrepareMenu(eddm, self, id)
	eddm.UIDropDownMenu_AddButton(L.CreateMenuTitle(TitanPlugins[id].menuText))
	eddm.UIDropDownMenu_AddButton(L.CreateMenuTitle(L["buttonText"]))

	local info = {};
	info = {};
	info.text = ACE["TITAN_CLOCK_MENU_DISPLAY_ON_RIGHT_SIDE"];
	info.func = function()
		TitanToggleVar(id, "DisplayOnRightSide")
		TitanPanel_InitPanelButtons()
	end
	info.arg1 = id
	info.checked = TitanGetVar(id, "DisplayOnRightSide");
	info.keepShownOnClick = true
	eddm.UIDropDownMenu_AddButton(info);

	L.AddBarPositionMenu(eddm, id)

	eddm.UIDropDownMenu_AddButton({
		notCheckable = true,
		text = ACE["TITAN_PANEL_MENU_HIDE"],
		func = function() TitanPanelRightClickMenu_Hide(id) end
	})

	info = {};
	info.text = CLOSE;
	info.notCheckable = true
	info.keepShownOnClick = false
	eddm.UIDropDownMenu_AddButton(info);
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
