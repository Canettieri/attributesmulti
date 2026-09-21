-- Specialization switching for Retail, adapted from Broker_Specializations.

local ADDON_NAME, L = ...
local ID = "TITAN_SPECIALIZATIONSM"
local TITAN_L = LibStub("AceLocale-3.0"):GetLocale("Titan", true)
local GetAddOnMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata
local SPEC = C_SpecializationInfo
local TALENTS = C_ClassTalents
local EQUIPMENT = C_EquipmentSet
local SEPARATOR = " |cffffd200|||r " -- Titan's normal text color; WoW renders || as one pipe.
local UNKNOWN_ICON = "Interface\\Icons\\INV_Misc_QuestionMark"

local function White(text)
    return "|cffffffff" .. text .. "|r"
end

local function Yellow(text)
    return "|cffffd200" .. text .. "|r"
end

local function GetDB()
    if type(TitanSpecializationsMultiDB) ~= "table" then
        TitanSpecializationsMultiDB = {}
    end
    local db = TitanSpecializationsMultiDB
    if type(db.gearBySpec) ~= "table" then db.gearBySpec = {} end
    if type(db.lootBySpec) ~= "table" then db.lootBySpec = {} end
    return db
end

local function GetSpecCount()
    local classID = select(3, UnitClass("player"))
    if not classID then return 0 end
    return SPEC.GetNumSpecializationsForClassID(classID)
end

local function GetCurrentSpec()
    local index = SPEC.GetSpecialization()
    if not index or index < 1 or index > GetSpecCount() then return nil end
    local specID, name, _, icon = SPEC.GetSpecializationInfo(index)
    if not specID or specID == 0 or not name then return nil end
    return index, specID, name, icon
end

local function GetSpecName(specID)
    if specID == 0 then
        local _, _, name = GetCurrentSpec()
        return name and L["specCurrentLoot"] .. " (" .. name .. ")" or L["specCurrentLoot"]
    end
    for index = 1, GetSpecCount() do
        local id, name = SPEC.GetSpecializationInfo(index)
        if id == specID then return name end
    end
    return L["specUnavailable"]
end

local function GetLoadoutName(specID)
    if not specID then return nil end
    if TALENTS.GetStarterBuildActive() then return L["specStarterBuild"] end
    local configID = TALENTS.GetLastSelectedSavedConfigID(specID)
    if not configID then return nil end
    local config = C_Traits.GetConfigInfo(configID)
    return config and config.name or nil
end

local function GetEquippedSetName()
    for _, setID in ipairs(EQUIPMENT.GetEquipmentSetIDs() or {}) do
        local name, _, _, isEquipped = EQUIPMENT.GetEquipmentSetInfo(setID)
        if name and isEquipped then return name end
    end
    return L["specNoEquipment"]
end

local function PrintMessage(message)
    DEFAULT_CHAT_FRAME:AddMessage("|cff71c671" .. L["specSwitcher"] .. ":|r " .. message)
end

local lootRequest = 0
local function ReportLootFailure()
    PrintMessage(L["specLootFailed"])
    if UIErrorsFrame then
        UIErrorsFrame:AddMessage(L["specLootFailed"], 1, 0.2, 0.2)
    end
end

local function ChangeLootSpec(targetID)
    lootRequest = lootRequest + 1
    local currentID = GetLootSpecialization()
    if currentID == targetID then return end
    if not SetLootSpecialization then
        ReportLootFailure()
        return
    end

    local request = lootRequest
    SetLootSpecialization(targetID)
    C_Timer.After(2, function()
        if request ~= lootRequest then return end
        if GetLootSpecialization() ~= targetID then
            ReportLootFailure()
        end
    end)
end

local pendingSpecID
local function ApplyBindings(specID)
    if InCombatLockdown() then
        pendingSpecID = specID
        return
    end
    pendingSpecID = nil
    local db = GetDB()
    local setID = db.gearBySpec[specID]
    if setID and EQUIPMENT.GetEquipmentSetInfo(setID) then
        EQUIPMENT.UseEquipmentSet(setID)
    end
    local lootID = db.lootBySpec[specID]
    if lootID ~= nil and GetLootSpecialization() ~= lootID then
        ChangeLootSpec(lootID)
    end
end

local function SwitchSpec(index)
    if InCombatLockdown() then
        PrintMessage(L["specCombat"])
        return
    end
    if index == SPEC.GetSpecialization() then return end
    local specID, _, _, _, _, _, _, _, _, unlocked = SPEC.GetSpecializationInfo(index)
    if not specID or specID == 0 or unlocked == false then return end
    if not SPEC.SetSpecialization(index) then
        PrintMessage(L["specSwitchFailed"])
    end
end

local function SwitchLoadout(index)
    if InCombatLockdown() then
        PrintMessage(L["specCombat"])
        return
    end
    TALENTS.SwitchToLoadoutByIndex(index)
end

local function UseSet(setID)
    if InCombatLockdown() then
        PrintMessage(L["specCombat"])
        return
    end
    EQUIPMENT.UseEquipmentSet(setID)
end

local function GetButtonText()
    local _, specID, name = GetCurrentSpec()
    if not specID then return Yellow(L["specSwitcher"] .. ": "), White(L["specUnavailable"]) end
    local loadout = GetLoadoutName(specID)
    local lootID = GetLootSpecialization()
    local lootName = lootID == 0 and L["specCurrentLootShort"] or GetSpecName(lootID)
    return Yellow(L["specSwitcher"] .. ": "), White(name)
        .. (loadout and SEPARATOR .. White(loadout) or "")
        .. SEPARATOR .. White(L["specLootShort"] .. ": " .. lootName)
end

local function GetTooltipText()
    local _, specID, name = GetCurrentSpec()
    local db = GetDB()
    local lootID = GetLootSpecialization()
    local lines = {
        L["specHint"],
        " ",
        L["specCurrent"] .. "\t|cffffffff" .. (name or L["specUnavailable"]) .. "|r",
        L["specLoadout"] .. "\t|cffffffff" .. (GetLoadoutName(specID) or L["specNoLoadout"]) .. "|r",
        L["specEquipment"] .. "\t|cffffffff" .. GetEquippedSetName() .. "|r",
        L["specLoot"] .. "\t|cffffffff" .. GetSpecName(lootID) .. "|r",
    }
    if specID then
        local linkedSet = db.gearBySpec[specID]
        local linkedName = linkedSet and EQUIPMENT.GetEquipmentSetInfo(linkedSet)
        lines[#lines + 1] = " "
        lines[#lines + 1] = L["specLinkedEquipment"] .. "\t|cffffffff"
            .. (linkedName or L["specNoBinding"]) .. "|r"
        local linkedLoot = db.lootBySpec[specID]
        lines[#lines + 1] = L["specLinkedLoot"] .. "\t|cffffffff"
            .. (linkedLoot ~= nil and GetSpecName(linkedLoot) or L["specNoBinding"]) .. "|r"
    end
    return table.concat(lines, "\n")
end

local function OnClick(self, button)
    if button == "LeftButton" then
        if PlayerSpellsUtil and type(PlayerSpellsUtil.ToggleClassTalentOrSpecFrame) == "function" then
            PlayerSpellsUtil.ToggleClassTalentOrSpecFrame()
        elseif type(TogglePlayerSpellsFrame) == "function" then
            TogglePlayerSpellsFrame()
        else
            PrintMessage(L["specTalentsUnavailable"])
        end
        return true
    end
end

local function UpdateButton(self)
    if not self.registry then return end
    local _, _, _, icon = GetCurrentSpec()
    self.registry.icon = icon or UNKNOWN_ICON
    local label, value = GetButtonText()
    self.lastButtonText = label .. value
    TitanPanelButton_UpdateButton(ID)
end

local function OnUpdate(self)
    if not self.registry then return true end
    local label, value = GetButtonText()
    if self.lastButtonText ~= label .. value then
        UpdateButton(self)
        TitanPanelButton_UpdateTooltip(self)
    end
    return true
end

local function OnEnteringWorld(self)
    self.lastSpecID = select(2, GetCurrentSpec())
    GetDB()
    UpdateButton(self)
end

local bindingRequest = 0
local function OnSpecChanged(self, unit)
    if type(unit) == "string" and unit ~= "player" then return end
    local _, specID = GetCurrentSpec()
    if specID and self.lastSpecID and specID ~= self.lastSpecID then
        bindingRequest = bindingRequest + 1
        local request = bindingRequest
        C_Timer.After(0.5, function()
            if request == bindingRequest and select(2, GetCurrentSpec()) == specID then
                ApplyBindings(specID)
            end
        end)
    end
    self.lastSpecID = specID
    UpdateButton(self)
end

local function OnCombatEnded(self)
    if pendingSpecID and select(2, GetCurrentSpec()) == pendingSpecID then
        ApplyBindings(pendingSpecID)
    end
    UpdateButton(self)
end

local function OnLootSpecUpdated(self)
    UpdateButton(self)
    TitanPanelButton_UpdateTooltip(self)
end

local function AddChoice(menu, text, icon, checked, action, disabled)
    menu[#menu + 1] = function()
        local isChecked = checked
        if type(isChecked) == "function" then isChecked = isChecked() end
        local isDisabled = disabled
        if type(isDisabled) == "function" then isDisabled = isDisabled() end
        return {
            text = text,
            icon = icon,
            checked = isChecked,
            func = action,
            disabled = isDisabled,
            keepShownOnClick = false,
        }
    end
end

local function AddSubmenu(eddm, text, menu, disabled)
    eddm.UIDropDownMenu_AddButton({
        text = text,
        hasArrow = true,
        menuList = menu,
        notCheckable = true,
        disabled = disabled,
    })
end

local function PrepareMenu(eddm, self, id, level, menuList)
    if level and level > 1 then
        for _, entry in ipairs(menuList or {}) do
            if type(entry) == "function" then entry = entry() end
            eddm.UIDropDownMenu_AddButton(entry, level)
        end
        return
    end

    eddm.UIDropDownMenu_AddButton({
        text = TitanPlugins[id].menuText,
        isTitle = true,
        isUninteractable = true,
        notCheckable = true,
    })

    local currentIndex, currentID = GetCurrentSpec()
    local db = GetDB()
    eddm.UIDropDownMenu_AddButton({ text = L["specChoose"], isTitle = true, notCheckable = true })
    for index = 1, GetSpecCount() do
        local specID, name, _, icon, _, _, _, _, _, unlocked = SPEC.GetSpecializationInfo(index)
        if specID and specID > 0 and name then
            local targetIndex = index
            eddm.UIDropDownMenu_AddButton({
                text = name,
                icon = icon,
                checked = currentIndex == index,
                disabled = currentIndex == index or unlocked == false,
                func = function() SwitchSpec(targetIndex) end,
            })
        end
    end
    eddm.UIDropDownMenu_AddSeparator()

    local loadoutMenu = {}
    if currentID then
        local starterActive = TALENTS.GetStarterBuildActive()
        local selectedID = TALENTS.GetLastSelectedSavedConfigID(currentID)
        local configIDs = TALENTS.GetConfigIDsBySpecID(currentID) or {}
        for index, configID in ipairs(configIDs) do
            local config = C_Traits.GetConfigInfo(configID)
            if config and config.name then
                local targetIndex = index
                local selected = not starterActive and selectedID == configID
                AddChoice(loadoutMenu, config.name, nil, selected,
                    function() SwitchLoadout(targetIndex) end, selected)
            end
        end
        if TALENTS.GetHasStarterBuild() then
            local starterIndex = #configIDs + 1
            AddChoice(loadoutMenu, L["specStarterBuild"], nil, starterActive,
                function() SwitchLoadout(starterIndex) end, starterActive)
        end
    end
    AddSubmenu(eddm, L["specLoadouts"], loadoutMenu, #loadoutMenu == 0)

    local sets = EQUIPMENT.GetEquipmentSetIDs() or {}
    local useSetMenu = {}
    local bindSetMenu = {}
    AddChoice(bindSetMenu, L["specNoBinding"], nil,
        currentID and db.gearBySpec[currentID] == nil,
        function() if currentID then db.gearBySpec[currentID] = nil end end)
    for _, setID in ipairs(sets) do
        local name, icon, _, isEquipped = EQUIPMENT.GetEquipmentSetInfo(setID)
        if name then
            local targetSetID = setID
            AddChoice(useSetMenu, name, icon, isEquipped,
                function() UseSet(targetSetID) end, isEquipped)
            AddChoice(bindSetMenu, name, icon,
                currentID and db.gearBySpec[currentID] == setID,
                function()
                    if currentID then
                        db.gearBySpec[currentID] = targetSetID
                        UseSet(targetSetID)
                    end
                end)
        end
    end
    AddSubmenu(eddm, L["specUseEquipment"], useSetMenu, #useSetMenu == 0)
    AddSubmenu(eddm, L["specBindEquipment"], bindSetMenu, not currentID)

    local lootMenu = {}
    local bindLootMenu = {}
    AddChoice(bindLootMenu, L["specNoBinding"], nil,
        function() return currentID and db.lootBySpec[currentID] == nil end,
        function() if currentID then db.lootBySpec[currentID] = nil end end)
    AddChoice(lootMenu, L["specCurrentLoot"], nil,
        function() return GetLootSpecialization() == 0 end,
        function() ChangeLootSpec(0) end,
        function() return GetLootSpecialization() == 0 end)
    AddChoice(bindLootMenu, L["specCurrentLoot"], nil,
        function() return currentID and db.lootBySpec[currentID] == 0 end,
        function()
            if currentID then
                db.lootBySpec[currentID] = 0
                ChangeLootSpec(0)
            end
        end)
    for index = 1, GetSpecCount() do
        local specID, name, _, icon = SPEC.GetSpecializationInfo(index)
        if specID and specID > 0 and name then
            local targetID = specID
            AddChoice(lootMenu, name, icon,
                function() return GetLootSpecialization() == targetID end,
                function() ChangeLootSpec(targetID) end,
                function() return GetLootSpecialization() == targetID end)
            AddChoice(bindLootMenu, name, icon,
                function() return currentID and db.lootBySpec[currentID] == targetID end,
                function()
                    if currentID then
                        db.lootBySpec[currentID] = targetID
                        ChangeLootSpec(targetID)
                    end
                end)
        end
    end
    AddSubmenu(eddm, L["specLoot"], lootMenu)
    AddSubmenu(eddm, L["specBindLoot"], bindLootMenu, not currentID)

    eddm.UIDropDownMenu_AddSeparator()
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

local eventsTable = {
    PLAYER_ENTERING_WORLD = OnEnteringWorld,
    PLAYER_SPECIALIZATION_CHANGED = OnSpecChanged,
    ACTIVE_TALENT_GROUP_CHANGED = OnSpecChanged,
    PLAYER_REGEN_ENABLED = OnCombatEnded,
    PLAYER_TALENT_UPDATE = OnSpecChanged,
    PLAYER_LOOT_SPEC_UPDATED = OnLootSpecUpdated,
    EQUIPMENT_SETS_CHANGED = UpdateButton,
    EQUIPMENT_SWAP_FINISHED = UpdateButton,
    TRAIT_CONFIG_LIST_UPDATED = UpdateButton,
    ACTIVE_COMBAT_CONFIG_CHANGED = UpdateButton,
    SELECTED_LOADOUT_CHANGED = UpdateButton,
}

L.Elib({
    id = ID,
    name = "Titan|cFFf9251a " .. L["specSwitcher"] .. "|r Multi",
    tooltip = L["specSwitcher"],
    icon = UNKNOWN_ICON,
    category = "Information",
    version = GetAddOnMetadata(ADDON_NAME, "Version"),
    onClick = OnClick,
    onUpdate = OnUpdate,
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
