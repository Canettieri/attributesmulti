-- PvP win/loss statistics adapted from Broker_PvPinfo for Titan Panel.

local ADDON_NAME, L = ...
local GetAddOnMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata
local TITAN_L = LibStub("AceLocale-3.0"):GetLocale("Titan", true)
local ID = "TITAN_PVPINFOM"
-- WoW text uses || to display a literal |.
local SEPARATOR = " || "

-- Use the game's overall statistics for the total. Adding map totals misses
-- battlegrounds introduced after the original Broker_PvPinfo was written.
local TOTAL_BATTLEGROUNDS = { wins = 840, played = 839 }
local RATED_BATTLEGROUNDS = { wins = 5694, played = 5692 }

local battlegrounds = {
    { "pvpAlteracValley", 49, 53 },
    { "pvpArathiBasin", 51, 55 },
    { "pvpBattleForGilneas", 5237, 5236 },
    { "pvpDeephaulRavine", 40195, 40196 },
    { "pvpDeepwindGorge", 8373, 8374 },
    { "pvpEyeOfTheStorm", 50, 54 },
    { "pvpIsleOfConquest", 4097, 4096 },
    { "pvpSeethingShore", 12712, 12710 },
    { "pvpSilvershardMines", 7830, 7829 },
    { "pvpSlayersRise", 61495, 61494 },
    { "pvpTempleOfKotmogu", 7826, 7825 },
    { "pvpTwinPeaks", 5233, 5232 },
    { "pvpWarsongGulch", 105, 52 },
}

local arenas = {
    { "2v2", 366, 367 },
    { "3v3", 364, 365 },
    { "5v5", 362, 363, true },
}

local function GetCount(statisticID)
    if statisticID == nil then return nil end
    local value = GetStatistic(statisticID)
    if value ~= nil and issecretvalue and issecretvalue(value) then return nil end
    if type(value) == "number" then return value end
    if type(value) ~= "string" then return nil end
    if value == "--" then return 0 end

    -- GetStatistic returns a display string, including locale separators.
    local digits = value:gsub("[^%d]", "")
    if digits == "" then return nil end
    return tonumber(digits)
end

local function DisplayCount(count, color)
    if count == nil then return "|cffaaaaaa--|r" end
    return color .. count .. "|r"
end

local function MakeResult(wins, played)
    local losses = wins and played and math.max(played - wins, 0) or nil
    return DisplayCount(wins, "|cff71c671") .. SEPARATOR
        .. DisplayCount(losses, "|cffff6060") .. SEPARATOR
        .. DisplayCount(played, "|cffffffff")
end

local function AddResult(lines, label, winsID, playedID, retired)
    local wins = GetCount(winsID)
    local played = GetCount(playedID)
    if retired and (played or 0) == 0 and (wins or 0) == 0 then return end
    if wins == nil or played == nil then return end
    lines[#lines + 1] = label .. "\t" .. MakeResult(wins, played)
end

local function GetButtonText()
    local wins = GetCount(TOTAL_BATTLEGROUNDS.wins)
    local played = GetCount(TOTAL_BATTLEGROUNDS.played)
    return L["pvpinfo"] .. ": ", MakeResult(wins, played)
end

local function MakeHeader(label)
    return label .. "\t|cff71c671" .. L["pvpWins"] .. "|r" .. SEPARATOR
        .. "|cffff6060" .. L["pvpLosses"] .. "|r" .. SEPARATOR
        .. "|cffffffff" .. L["pvpTotal"] .. "|r"
end

local function GetTooltipText()
    local lines = {
        L["hintpvp"],
        " ",
        MakeHeader(L["pvpBattlegrounds"]),
    }

    AddResult(lines, L["pvpTotal"], TOTAL_BATTLEGROUNDS.wins, TOTAL_BATTLEGROUNDS.played)
    for _, battleground in ipairs(battlegrounds) do
        AddResult(lines, L[battleground[1]], battleground[2], battleground[3])
    end

    lines[#lines + 1] = " "
    AddResult(lines, L["pvpRatedBattlegrounds"], RATED_BATTLEGROUNDS.wins, RATED_BATTLEGROUNDS.played)
    AddResult(lines, L["pvpBattlegroundBlitz"], 40201, 40199)
    lines[#lines + 1] = " "
    lines[#lines + 1] = MakeHeader(L["pvpArena"])
    for _, arena in ipairs(arenas) do
        AddResult(lines, arena[1], arena[2], arena[3], arena[4])
    end

    return table.concat(lines, "\n")
end

local function OnClick(self, button)
    if button == "LeftButton" then TogglePVPUI() end
end

local function PrepareMenu(eddm, self, id)
    eddm.UIDropDownMenu_AddButton({
        text = TitanPlugins[id].menuText,
        isTitle = true,
        isUninteractable = true,
        notCheckable = true,
    })

    eddm.UIDropDownMenu_AddButton({
        text = TITAN_L["TITAN_PANEL_MENU_SHOW_ICON"],
        checked = TitanGetVar(id, "ShowIcon"),
        keepShownOnClick = true,
        func = function() TitanPanelRightClickMenu_ToggleVar({ id, "ShowIcon", nil }) end,
    })
    eddm.UIDropDownMenu_AddButton({
        text = TITAN_L["TITAN_PANEL_MENU_SHOW_LABEL_TEXT"],
        checked = TitanGetVar(id, "ShowLabelText"),
        keepShownOnClick = true,
        func = function() TitanPanelRightClickMenu_ToggleVar({ id, "ShowLabelText", nil }) end,
    })
    eddm.UIDropDownMenu_AddButton({
        text = TITAN_L["TITAN_CLOCK_MENU_DISPLAY_ON_RIGHT_SIDE"],
        checked = TitanGetVar(id, "DisplayOnRightSide"),
        keepShownOnClick = true,
        func = function()
            TitanToggleVar(id, "DisplayOnRightSide")
            TitanPanel_InitPanelButtons()
        end,
    })

    eddm.UIDropDownMenu_AddSeparator()
    eddm.UIDropDownMenu_AddButton({
        text = TITAN_L["TITAN_PANEL_MENU_HIDE"],
        notCheckable = true,
        func = function() TitanPanelRightClickMenu_Hide(id) end,
    })
    eddm.UIDropDownMenu_AddButton({ text = CLOSE, notCheckable = true, keepShownOnClick = false })
end

local function UpdateButton(self)
    if self.registry then TitanPanelButton_UpdateButton(ID) end
end

local eventsTable = {
    PLAYER_ENTERING_WORLD = UpdateButton,
    RECEIVED_ACHIEVEMENT_LIST = UpdateButton,
    CRITERIA_UPDATE = UpdateButton,
    PVP_MATCH_COMPLETE = UpdateButton,
}

L.Elib({
    id = ID,
    name = "Titan|cFFf9251a " .. L["pvpinfo"] .. "|r Multi",
    tooltip = L["pvpinfo"],
    icon = UnitFactionGroup("player") == "Alliance"
        and "Interface\\Icons\\achievement_pvp_a_a"
        or "Interface\\Icons\\achievement_pvp_h_h",
    category = "Information",
    version = GetAddOnMetadata(ADDON_NAME, "Version"),
    onClick = OnClick,
    getButtonText = GetButtonText,
    getTooltipText = GetTooltipText,
    prepareMenu = PrepareMenu,
    eventsTable = eventsTable,
    savedVariables = {
        ShowIcon = 1,
        ShowLabelText = false,
        DisplayOnRightSide = false,
    },
})
