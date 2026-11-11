-- Shared formatting for the optional Classic attributes. Never keep secret values.
local _, L = ...
local A = {}
L.LegacyAttributes = A

function A.Number(value)
	if issecretvalue and issecretvalue(value) then return nil end
	if type(value) ~= "number" or value ~= value or value == math.huge or value == -math.huge then return nil end
	return value
end

function A.Text(value)
	if issecretvalue and issecretvalue(value) then return nil end
	if type(value) == "string" then return value end
end

function A.Format(value)
	return value ~= nil and string.format("%.0f", value) or "—"
end

function A.Balance(value, start)
	if value == nil or start == nil then return "—" end
	local delta = value - start
	local color = delta > 0 and "|cFF69FF69" or delta < 0 and "|cFFFF2e2e" or "|cFFFFFFFF"
	return color .. A.Format(delta) .. "|r"
end

function A.Hint()
	local color = RAID_CLASS_COLORS[select(2, UnitClass("player"))].colorStr
	return L.moreinfo .. "|c" .. color .. UnitName("player") .. "|r|cFFFFFFFF.|r\n \n"
end

function A.Row(label, value)
	return label .. ":\t|cFFFFFFFF" .. value .. "|r"
end

function A.Register(addon, id, name, icon, refresh, text, tooltip, menus, saved, prepareMenu, events)
	local metadata = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata
	saved = saved or {}
	saved.ShowIcon, saved.ShowLabelText, saved.DisplayOnRightSide = 1, false, false
	L.Elib({ id = id, name = "Titan|cFFf9251a " .. name .. "|r Multi", tooltip = name,
		icon = icon, category = "Information", version = metadata(addon, "Version"),
		characterClick = true, onUpdate = refresh, getButtonText = text, getTooltipText = tooltip,
		prepareMenu = prepareMenu,
		attributeMenuOrder = true,
		hideIconOption = not (menus and menus.showIconOption), hideLabelOption = not not (menus and menus.hideLabelOption),
		menus = menus or { { type = "rightSideToggle" } }, savedVariables = saved,
		eventsTable = events or { PLAYER_ENTERING_WORLD = refresh },
	})
end
