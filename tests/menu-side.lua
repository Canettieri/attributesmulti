-- Run from the addon root with Lua 5.1.
local library, entries, vars, swaps = {}, {}, {}, 0
local translations = setmetatable({ TITAN_CLOCK_MENU_DISPLAY_ON_RIGHT_SIDE = "RIGHT" }, { __index = function(_, key) return key end })
local locale = { GetLocale = function() return translations end }
local dropdown = {
	UIDropDownMenu_GetOrCreate = function() return {} end,
	UIDropDownMenu_AddButton = function(info) entries[#entries + 1] = info end,
	UIDropDownMenu_AddSpace = function() end,
	UIDropDownMenu_AddSeparator = function() entries[#entries + 1] = { separator = true } end,
	UIDropDownMenu_Initialize = function(_, initializer) entries = {}; initializer() end,
	ToggleDropDownMenu = function() end,
}
LibStub = setmetatable({ NewLibrary = function(_, name, minor)
	assert(name == "Elib-4.0" and minor == 7); return library
end }, { __call = function(_, name)
	if name == "Elib-4.0" then return library end
	if name == "ElioteDropDownMenu-1.0" then return dropdown end
	return locale
end })
CreateFrame = function()
	local frame = { scripts = {} }
	function frame:SetFrameStrata() end
	function frame:SetScript(name, handler) self.scripts[name] = handler end
	function frame:RegisterEvent() end
	function frame:UnregisterEvent() end
	return frame
end
TitanPlugins, UIParent = {}, {}
TitanGetVar = function(id, key) return vars[id] and vars[id][key] end
TitanUtils_SwapButtonSide = function(id)
	assert(id == "ATTRIBUTE" or id == "DEFAULT")
	vars[id].DisplayOnRightSide = not vars[id].DisplayOnRightSide
	swaps = swaps + 1
end
-- Both removed APIs must remain absent: the menu must use Titan's side swap.
TitanPanel_InitPanelButtons, TitanToggleVar = nil, nil
local namespace = {}
assert(loadfile("Core/Elib-4.0.lua"))("TitanAttributesMulti", namespace)
assert(loadfile("Core/AttributesCore.lua"))("TitanAttributesMulti", namespace)
namespace.showbb = "BALANCE"
for _, id in ipairs({ "ATTRIBUTE", "DEFAULT" }) do
	vars[id] = { DisplayOnRightSide = false }
	local frame = namespace.Elib({ id = id, name = id, savedVariables = vars[id],
		prepareMenu = id == "ATTRIBUTE" and namespace.PrepareAttributesMenu or nil,
		attributeMenuOrder = true,
		menus = { { type = "rightSideToggle" },
			{ type = "toggle", text = "BALANCE", var = "ShowBarBalance", barOption = true },
			{ type = "title", text = "WEAPONS" },
		},
	})
	frame:ADDON_LOADED()
	TitanPlugins[id] = frame.registry
	for _, expected in ipairs({ true, false }) do
		frame.scripts.OnClick(frame, "RightButton")
		local option
		for _, entry in ipairs(entries) do if entry.text == "RIGHT" then option = entry end end
		assert(option and option.checked == vars[id].DisplayOnRightSide)
		option.func({}, option.arg1)
		assert(vars[id].DisplayOnRightSide == expected)
		do
			local right, balance, label, separator, count
			count = 0
			for index, entry in ipairs(entries) do
				if entry.text == "RIGHT" then right = index end
				if entry.text == "BALANCE" then balance = index; count = count + 1 end
				if entry.text == "TITAN_PANEL_MENU_SHOW_LABEL_TEXT" then label = index end
				if entry.separator and not separator then separator = index end
			end
			assert(count == 1 and right == balance + 1 and label == right + 1)
			if id == "DEFAULT" then assert(separator == label + 1) end
		end
	end
end
assert(swaps == 4)
for _, scenario in ipairs({
	{ id = "NEW_DEFAULT", hideIcon = true, hideLabel = true, icon = false, label = false },
	{ id = "RESISTANCES", hideIcon = false, hideLabel = true, icon = true, label = false },
	{ id = "NEW_ATTRIBUTE", hideIcon = true, hideLabel = true, custom = true, icon = false, label = false },
	{ id = "OLD_DEFAULT", icon = true, label = true },
}) do
	vars[scenario.id] = {}
	local frame = namespace.Elib({ id = scenario.id, name = scenario.id, savedVariables = vars[scenario.id],
		hideIconOption = scenario.hideIcon, hideLabelOption = scenario.hideLabel,
		prepareMenu = scenario.custom and namespace.PrepareAttributesMenu or nil,
	})
	frame:ADDON_LOADED(); TitanPlugins[scenario.id] = frame.registry
	frame.scripts.OnClick(frame, "RightButton")
	local icon, label = false, false
	for _, entry in ipairs(entries) do
		if entry.text == "TITAN_PANEL_MENU_SHOW_ICON" then icon = true end
		if entry.text == "TITAN_PANEL_MENU_SHOW_LABEL_TEXT" then label = true end
	end
	assert(icon == scenario.icon and label == scenario.label, scenario.id)
end
print("PASS: attribute and default menus switch both sides without removed Titan APIs")
