-- Camelot talent profiles (primary/secondary), independent of Retail specs.
local ADDON_NAME, L = ...
local ID = "TITAN_SPECIALIZATIONSM"
local ACE = LibStub("AceLocale-3.0"):GetLocale("Titan", true)
local UNKNOWN_ICON = "Interface\\Icons\\INV_Misc_QuestionMark"
local pendingGroup

local function Read(func, ...)
    if type(func) ~= "function" then return nil end
    local ok, value = pcall(func, ...)
    if ok then return value end
end

local function InCombat()
    return InCombatLockdown and InCombatLockdown()
end

local function GetDB()
    if type(TitanForeverSpecializationsMultiDB) ~= "table" then TitanForeverSpecializationsMultiDB = {} end
    local db = TitanForeverSpecializationsMultiDB
    if type(db.gearByGroup) ~= "table" then db.gearByGroup = {} end
    return db
end

local function GetGroupCount()
    local count = Read(GetNumSpecGroups)
    return type(count) == "number" and math.min(2, math.max(0, count)) or 0
end

local function GetActiveGroup()
    local group = Read(C_SpecializationInfo and C_SpecializationInfo.GetActiveSpecGroup)
    if group == 1 or group == 2 then return group end
end

local function GroupName(group)
    if group == 1 then return DUAL_SPEC_PRIMARY or L["foreverPrimary"] end
    if group == 2 then return DUAL_SPEC_SECONDARY or L["foreverSecondary"] end
    return L["specUnavailable"]
end

local function GetProfile(group)
    local profile = { name = GroupName(group), points = {}, trees = {}, icon = UNKNOWN_ICON }
    if not group or group > GetGroupCount() then return profile end
    local configID = Read(C_SpecializationInfo and C_SpecializationInfo.GetCombatConfigIDForSpecGroup, group)
    local config = configID and Read(C_Traits and C_Traits.GetConfigInfo, configID)
    local treeID = config and config.treeIDs and config.treeIDs[1]
    local displays = treeID and Read(C_Traits and C_Traits.GetGroupDisplayInfoByTreeID, treeID)
    if not displays then return profile end
    local groupIDs = {}
    for _, display in ipairs(displays) do groupIDs[#groupIDs + 1] = display.groupID end
    local currencies = Read(C_Traits.GetGroupCurrencyInfo, configID, groupIDs) or {}
    local byGroup = {}
    for _, info in ipairs(currencies) do byGroup[info.traitNodeGroupID] = info end
    local highest = -1
    for _, display in ipairs(displays) do
        local info = byGroup[display.groupID]
        local currency = info and info.currencyInfos and info.currencyInfos[1]
        local spent = currency and currency.spent
        if type(spent) == "number" and not (issecretvalue and issecretvalue(spent)) then
            profile.points[#profile.points + 1] = tostring(spent)
            profile.trees[#profile.trees + 1] = (display.displayName or "?") .. ": " .. spent
            if spent > highest then highest, profile.icon = spent, display.icon or UNKNOWN_ICON end
        else
            -- Preserve tree order without inventing a zero when data is not ready.
            profile.points[#profile.points + 1] = "?"
            profile.trees[#profile.trees + 1] = (display.displayName or "?") .. ": ?"
        end
    end
    return profile
end

local function EquipmentAvailable()
    return C_EquipmentSet and type(C_EquipmentSet.GetEquipmentSetIDs) == "function"
        and type(C_EquipmentSet.GetEquipmentSetInfo) == "function"
        and type(C_EquipmentSet.UseEquipmentSet) == "function"
end

local function PrintMessage(text)
    if DEFAULT_CHAT_FRAME then DEFAULT_CHAT_FRAME:AddMessage(L["specSwitcher"] .. ": " .. text) end
end

local function UseSet(setID)
    if InCombat() then PrintMessage(L["specCombat"]); return end
    if EquipmentAvailable() and C_EquipmentSet.GetEquipmentSetInfo(setID) then
        C_EquipmentSet.UseEquipmentSet(setID)
    end
end

local function ApplyBinding(group)
    pendingGroup = nil
    local setID = GetDB().gearByGroup[group]
    if not setID then return end
    if InCombat() then pendingGroup = group; return end
    UseSet(setID)
end

local function SwitchGroup(group)
    if InCombat() then PrintMessage(L["specCombat"]); return end
    if group > GetGroupCount() or group == GetActiveGroup() then return end
    local setter = C_SpecializationInfo and C_SpecializationInfo.SetActiveSpecGroup
    if type(setter) ~= "function" then PrintMessage(L["specSwitchFailed"]); return end
    -- This API returns no success flag. Bindings wait for the confirmed group change.
    local ok = pcall(setter, group)
    if not ok then PrintMessage(L["specSwitchFailed"]) end
end

local function GetButtonText()
    local profile = GetProfile(GetActiveGroup())
    local points = TitanGetVar(ID, "ShowTalentPoints") and #profile.points > 0
        and " (" .. table.concat(profile.points, "/") .. ")" or ""
    return L["specSwitcher"] .. ": ", "|cffffffff" .. profile.name .. points .. "|r"
end

local function GetTooltipText()
    local active = GetActiveGroup()
    local db = GetDB()
    local lines = { L["foreverSpecHint"], " ", L["specCurrent"] .. "\t" .. GroupName(active) }
    for group = 1, 2 do
        local profile = GetProfile(group)
        lines[#lines + 1] = " "
        lines[#lines + 1] = profile.name .. (group == active and " |cFF69FF69*|r" or "")
        if group > GetGroupCount() then
            lines[#lines + 1] = TALENT_SPEC_LOCKED or L["foreverSpecLocked"]
        else
            lines[#lines + 1] = #profile.trees > 0 and table.concat(profile.trees, " / ") or L["specUnavailable"]
            local setID = db.gearByGroup[group]
            local name = EquipmentAvailable() and setID and C_EquipmentSet.GetEquipmentSetInfo(setID)
            lines[#lines + 1] = L["foreverLinkedEquipment"] .. "\t" .. (name or L["specNoBinding"])
        end
    end
    return table.concat(lines, "\n")
end

local function Refresh(self)
    if not self.registry then return true end
    local group = GetActiveGroup()
    if group then
        if self.lastGroup and self.lastGroup ~= group then ApplyBinding(group) end
        self.lastGroup = group
    end
    local label, text = GetButtonText()
    local tooltip = GetTooltipText()
    local icon = GetProfile(group).icon
    if self.lastText ~= label .. text or self.lastTooltip ~= tooltip or self.registry.icon ~= icon then
        self.lastText, self.lastTooltip, self.registry.icon = label .. text, tooltip, icon
        TitanPanelButton_UpdateButton(ID)
        if TitanPanelButton_UpdateTooltip then TitanPanelButton_UpdateTooltip(self) end
    end
    return true
end

local function OnCombatEnded(self)
    local group = pendingGroup
    pendingGroup = nil
    if group and group == GetActiveGroup() then ApplyBinding(group) end
    Refresh(self)
end

local function OnClick(_, button)
    if button ~= "LeftButton" then return end
    if InCombat() then PrintMessage(L["specCombat"]); return true end
    if PlayerSpellsUtil and type(PlayerSpellsUtil.ToggleClassTalentOrSpecFrame) == "function" then
        PlayerSpellsUtil.ToggleClassTalentOrSpecFrame()
    else
        PrintMessage(L["specTalentsUnavailable"])
    end
    return true
end

local function PrepareMenu(eddm, self, id, level, menuList)
    if level and level > 1 then
        for _, entry in ipairs(menuList or {}) do eddm.UIDropDownMenu_AddButton(entry, level) end
        return
    end
    eddm.UIDropDownMenu_AddButton(L.CreateMenuTitle(TitanPlugins[id].menuText))
    eddm.UIDropDownMenu_AddButton(L.CreateMenuTitle(L["foreverSpecChoose"]))
    local active, count = GetActiveGroup(), GetGroupCount()
    for group = 1, 2 do
        local target = group
        eddm.UIDropDownMenu_AddButton({
            text = GroupName(group), checked = group == active,
            disabled = group > count or group == active or InCombat()
                or not (C_SpecializationInfo and C_SpecializationInfo.SetActiveSpecGroup),
            func = function() SwitchGroup(target) end,
        })
    end
    if EquipmentAvailable() then
        eddm.UIDropDownMenu_AddSpace()
        eddm.UIDropDownMenu_AddButton(L.CreateMenuTitle(L["specEquipment"]))
        local useMenu, bindMenu = {}, {}
        local db = GetDB()
        bindMenu[#bindMenu + 1] = {
            text = L["specNoBinding"], checked = active and db.gearByGroup[active] == nil,
            func = function() if active then db.gearByGroup[active] = nil end end,
        }
        for _, setID in ipairs(C_EquipmentSet.GetEquipmentSetIDs() or {}) do
            local name, icon, _, equipped = C_EquipmentSet.GetEquipmentSetInfo(setID)
            if name then
                local targetSet = setID
                useMenu[#useMenu + 1] = {
                    text = name, icon = icon, checked = equipped, disabled = InCombat() or equipped,
                    func = function() UseSet(targetSet) end,
                }
                bindMenu[#bindMenu + 1] = {
                    text = name, icon = icon, checked = active and db.gearByGroup[active] == setID,
                    func = function() if active then db.gearByGroup[active] = targetSet end end,
                }
            end
        end
        eddm.UIDropDownMenu_AddButton({ text = L["specUseEquipment"], hasArrow = true,
            menuList = useMenu, notCheckable = true, disabled = #useMenu == 0 })
        eddm.UIDropDownMenu_AddButton({ text = L["foreverBindEquipment"], hasArrow = true,
            menuList = bindMenu, notCheckable = true, disabled = not active })
    end
    eddm.UIDropDownMenu_AddSpace()
    eddm.UIDropDownMenu_AddButton(L.CreateMenuTitle(L["buttonText"]))
    for _, option in ipairs({
        { "ShowIcon", ACE["TITAN_PANEL_MENU_SHOW_ICON"] },
        { "ShowLabelText", ACE["TITAN_PANEL_MENU_SHOW_LABEL_TEXT"] },
        { "ShowTalentPoints", L["foreverTalentPoints"] },
        { "DisplayOnRightSide", ACE["TITAN_CLOCK_MENU_DISPLAY_ON_RIGHT_SIDE"] },
    }) do
        local key = option[1]
        eddm.UIDropDownMenu_AddButton({ text = option[2], checked = TitanGetVar(id, key), keepShownOnClick = true,
            func = function()
                TitanToggleVar(id, key)
                if key == "DisplayOnRightSide" then TitanPanel_InitPanelButtons() end
                Refresh(self)
            end,
        })
    end
    L.AddBarPositionMenu(eddm, id)
    eddm.UIDropDownMenu_AddButton({ text = ACE["TITAN_PANEL_MENU_HIDE"], notCheckable = true,
        func = function() TitanPanelRightClickMenu_Hide(id) end })
    eddm.UIDropDownMenu_AddButton({ text = CLOSE, notCheckable = true, keepShownOnClick = false })
end

L.Elib({
    id = ID, name = "Titan|cFFf9251a " .. L["specSwitcher"] .. "|r Multi",
    tooltip = L["specSwitcher"], icon = UNKNOWN_ICON, category = "Information",
    version = (C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata)(ADDON_NAME, "Version"),
    onClick = OnClick, onUpdate = Refresh, getButtonText = GetButtonText,
    getTooltipText = GetTooltipText, prepareMenu = PrepareMenu,
    eventsTable = {
        PLAYER_ENTERING_WORLD = Refresh, ACTIVE_TALENT_GROUP_CHANGED = Refresh,
        PLAYER_TALENT_UPDATE = Refresh, TRAIT_CONFIG_UPDATED = Refresh,
        EQUIPMENT_SETS_CHANGED = Refresh, EQUIPMENT_SWAP_FINISHED = Refresh,
        PLAYER_REGEN_ENABLED = OnCombatEnded,
    },
    savedVariables = { ShowIcon = 1, ShowLabelText = false, DisplayOnRightSide = false, ShowTalentPoints = true },
})
