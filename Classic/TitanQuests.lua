--[[
Description: This plugin is part of the "Titan Panel [Attributes] Multi" addon. It shows your Quests.
Site: https://www.curseforge.com/wow/addons/titan-panel-attributes-multi
Author: Canettieri
Special Thanks to Eliote.
--]]

local ADDON_NAME, L = ...;
local GetAddOnMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata
local version = GetAddOnMetadata(ADDON_NAME, "Version")
local ID = "TITAN_QUESSM"
local quests = 0
local count = 0
local maximum = 25
-----------------------------------------------
local function OnClick(self, button)
	if (button == "LeftButton") then
		ToggleFrame(WorldMapFrame);
	end
end
-----------------------------------------------
local function UpdateAll(self)
	local numEntries, numQuests = GetNumQuestLogEntries();
	local currentMaximum = C_QuestLog and C_QuestLog.GetMaxNumQuestsCanAccept and C_QuestLog.GetMaxNumQuestsCanAccept()
	if currentMaximum and currentMaximum > 0 then
		maximum = currentMaximum
	end

	quests = numQuests
	count = 0

	for questIndex = 1, numEntries do
	    local title, level, suggestedGroup, isHeader, isCollapsed, isComplete = GetQuestLogTitle(questIndex)
	    if isComplete == 1 then count = count + 1 end
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

	local completedtext = TitanUtils_GetHighlightText(quests)
	if maximum > 0 then
		local questLimitRatio = quests / maximum
		if questLimitRatio >= 1 then
			completedtext = "|cFFFF2e2e"..quests
		elseif questLimitRatio >= 0.8 then
			completedtext = "|cFFf69112"..quests
		elseif questLimitRatio >= 0.6 then
			completedtext = "|cFFf6ed12"..quests
		end
	end

	return L["quests"]..": ", "|cFFFFFFFF[|r|cFF69FF69"..count.."|r|cFFFFFFFF]|r "..completedtext.."|r|||cFFFF2e2e"..maximum
end
-----------------------------------------------
local function GetTooltipText(self, id)

	return L["hintquest"].."\r\r"..L["compquest"]..count.."|r\r"..L["numquests"]..quests.."|r\r"..L["maxquests"]..maximum
end
-----------------------------------------------
L.Elib({
	id = ID,
	name = "Titan|cFFf9251a "..L["quests"].."|r".." Multi",
	tooltip = L["quests"],
	icon = "Interface\\Icons\\inv_misc_book_03",
	category = "Information",
	version = version,
	eventsTable = eventsTable,
	onClick = OnClick,
	getButtonText = GetButtonText,
	getTooltipText = GetTooltipText,
	prepareMenu = L.PrepareAttributesMenu,
	savedVariables = {
		ShowIcon = 1,
		DisplayOnRightSide = false,
		ShowBarBalance = false,
		ShowLabelText = false,
	},
})
