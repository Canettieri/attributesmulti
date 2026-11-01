-- Run from the addon root: lua tests/forever-specializations.lua (Lua 5.1).
local active, unlocked, combat = 1, 1, false
local requests, equipped, messages, opened = {}, {}, {}, 0
local config, frame
local retailDB = { gearBySpec = { [62] = 999 } }
TitanSpecializationsMultiDB = retailDB
TitanForeverSpecializationsMultiDB = { gearByGroup = { [1] = 42, [2] = 43 } }
DUAL_SPEC_PRIMARY, DUAL_SPEC_SECONDARY, TALENT_SPEC_LOCKED = "Primary", "Secondary", "Locked"
GetLocale = function() return "enUS" end
GetNumSpecGroups = function() return unlocked end
InCombatLockdown = function() return combat end
C_SpecializationInfo = {
    GetActiveSpecGroup = function() return active end,
    GetCombatConfigIDForSpecGroup = function(group) return 100 + group end,
    SetActiveSpecGroup = function(group) requests[#requests + 1] = group end,
}
-- The test intentionally provides no Retail specialization, loadout or loot APIs.
C_ClassTalents, GetLootSpecialization, SetLootSpecialization = nil, nil, nil
C_Traits = {
    GetConfigInfo = function(id) return { treeIDs = { id + 1000 } } end,
    GetGroupDisplayInfoByTreeID = function()
        return {
            { groupID = 11, displayName = "Arcane", icon = 1 },
            { groupID = 12, displayName = "Fire", icon = 2 },
            { groupID = 13, displayName = "Frost", icon = 3 },
        }
    end,
    GetGroupCurrencyInfo = function(id, ids)
        assert(#ids == 3)
        return {
            { traitNodeGroupID = 13, currencyInfos = { { spent = id == 101 and 5 or 31 } } },
            { traitNodeGroupID = 11, currencyInfos = { { spent = id == 101 and 31 or 0 } } },
            { traitNodeGroupID = 12, currencyInfos = { { spent = 15 } } },
        }
    end,
}
local equipment = { [42] = "Arcane Gear", [43] = "Frost Gear" }
C_EquipmentSet = {
    GetEquipmentSetIDs = function() return { 42, 43 } end,
    GetEquipmentSetInfo = function(id) return equipment[id], 9, nil, false end,
    UseEquipmentSet = function(id) equipped[#equipped + 1] = id end,
}
C_AddOns = { GetAddOnMetadata = function() return "test" end }
DEFAULT_CHAT_FRAME = { AddMessage = function(_, text) messages[#messages + 1] = text end }
PlayerSpellsUtil = { ToggleClassTalentOrSpecFrame = function() opened = opened + 1 end }
TitanPlugins = {}
TitanPanelButton_UpdateButton = function() end
TitanPanelButton_UpdateTooltip = function() end
TitanPanel_InitPanelButtons = function() end
TitanPanelRightClickMenu_Hide = function() end
TitanGetVar = function(_, key) return config.savedVariables[key] end
TitanToggleVar = function(_, key) config.savedVariables[key] = not config.savedVariables[key] end
CLOSE = "Close"
LibStub = function()
    return { GetLocale = function()
        return { TITAN_PANEL_MENU_SHOW_ICON = "Icon", TITAN_PANEL_MENU_SHOW_LABEL_TEXT = "Label",
            TITAN_CLOCK_MENU_DISPLAY_ON_RIGHT_SIDE = "Right side", TITAN_PANEL_MENU_HIDE = "Hide" }
    end }
end
local L = {}
assert(loadfile("Core/languages/enUS-default.lua"))("TitanAttributesMulti", L)
L.CreateMenuTitle = function(text) return { text = text, isTitle = true } end
L.AddBarPositionMenu = function() end
L.Elib = function(value)
    config = value
    frame = { registry = { id = value.id, icon = value.icon } }
    TitanPlugins[value.id] = { menuText = value.name }
end
assert(loadfile("Forever/TitanSpecializations.lua"))("TitanAttributesMulti", L)
local id = config.id
local function bar() return select(2, config.getButtonText()) end
local function menu()
    local entries = {}
    config.prepareMenu({
        UIDropDownMenu_AddButton = function(entry) entries[#entries + 1] = entry end,
        UIDropDownMenu_AddSpace = function() end,
    }, frame, id)
    return entries
end
local function find(text)
    for _, entry in ipairs(menu()) do if entry.text == text then return entry end end
    error("Missing menu entry: " .. text)
end
config.eventsTable.PLAYER_ENTERING_WORLD(frame)
assert(#equipped == 0 and #requests == 0)
assert(bar():find("Primary (31/15/5)", 1, true))
assert(frame.registry.icon == 1)
assert(config.getTooltipText():find("Arcane: 31 / Fire: 15 / Frost: 5", 1, true))
assert(find("Secondary").disabled)
find("Secondary").func() -- Even direct calls must respect a locked secondary profile.
assert(#requests == 0)
unlocked = 2
assert(not find("Secondary").disabled)
find("Secondary").func()
assert(requests[1] == 2 and #equipped == 0 and active == 1)
assert(#messages == 0) -- SetActiveSpecGroup returns nil; that is not a failure.
active = 2
config.eventsTable.ACTIVE_TALENT_GROUP_CHANGED(frame)
assert(equipped[1] == 43 and frame.registry.icon == 3)
assert(bar():find("Secondary (0/15/31)", 1, true))
config.onUpdate(frame)
assert(#equipped == 1) -- Polling must not re-equip repeatedly.
combat = true
find("Primary").func()
assert(#requests == 1 and #messages == 1)
find(L.specUseEquipment).menuList[1].func()
assert(#equipped == 1)
-- An external group change during combat defers only the linked equipment.
active = 1
config.eventsTable.ACTIVE_TALENT_GROUP_CHANGED(frame)
assert(#equipped == 1)
combat = false
config.eventsTable.PLAYER_REGEN_ENABLED(frame)
assert(equipped[2] == 42)
config.eventsTable.PLAYER_REGEN_ENABLED(frame)
assert(#equipped == 2)
-- Binding targets a group index, never a Retail spec ID.
local bind = find(L.foreverBindEquipment).menuList
bind[3].func()
assert(TitanForeverSpecializationsMultiDB.gearByGroup[1] == 43)
bind[1].func()
assert(TitanForeverSpecializationsMultiDB.gearByGroup[1] == nil)
assert(TitanSpecializationsMultiDB == retailDB and retailDB.gearBySpec[62] == 999)
find(L.foreverTalentPoints).func()
assert(not bar():find("31/15/5", 1, true))
assert(config.onClick(frame, "LeftButton") == true and opened == 1)
assert(config.onClick(frame, "RightButton") == nil)
combat = true
config.onClick(frame, "LeftButton")
assert(opened == 1)
combat = false
C_Traits, C_EquipmentSet = nil, nil
assert(bar():find("Primary", 1, true))
assert(type(config.getTooltipText()) == "string")
menu()
C_SpecializationInfo, GetNumSpecGroups = nil, nil
assert(bar():find(L.specUnavailable, 1, true))
assert(type(config.getTooltipText()) == "string")
menu()
print("PASS: dual-spec locks, tree points, confirmed switching, equipment bindings, combat deferral, Retail DB isolation, missing APIs")
