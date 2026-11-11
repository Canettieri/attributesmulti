--[[
Description: This plugin is part of the "Titan Panel [Attributes] Multi" addon.
Site: https://www.curseforge.com/wow/addons/titan-panel-attributes-multi
Author: Canettieri
Special Thanks to Eliote.
--]]

local ADDON_NAME, L = ...;
local ACE = LibStub("AceLocale-3.0"):GetLocale("Titan", true)
local RegisterPlugin = LibStub("Elib-4.0").Register

local characterClickWatcher
local characterClickFrames = {}
local function SyncCharacterClick(plugin, overlay)
	local left, bottom, width, height = plugin:GetRect()
	local visible = plugin:IsVisible() and left ~= nil and bottom ~= nil and width ~= nil and height ~= nil
	if overlay:IsShown() ~= visible then overlay:SetShown(visible) end
	if not visible then return end
	-- Anchor only to UIParent. Anchoring to or securely wrapping the Titan
	-- plugin can protect its layout and block Titan's SetScale during combat.
	local scale = plugin:GetEffectiveScale() / UIParent:GetEffectiveScale()
	left, bottom, width, height = left * scale, bottom * scale, width * scale, height * scale
	if overlay.titanLeft ~= left or overlay.titanBottom ~= bottom then
		overlay:ClearAllPoints()
		overlay:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", left, bottom)
		overlay.titanLeft, overlay.titanBottom = left, bottom
	end
	if overlay.titanWidth ~= width or overlay.titanHeight ~= height then
		overlay:SetSize(width, height)
		overlay.titanWidth, overlay.titanHeight = width, height
	end
	local strata, level = plugin:GetFrameStrata(), plugin:GetFrameLevel() + 1
	if overlay:GetFrameStrata() ~= strata then overlay:SetFrameStrata(strata) end
	if overlay:GetFrameLevel() ~= level then overlay:SetFrameLevel(level) end
end

local function WatchCharacterClick(frame, click)
	characterClickFrames[frame] = click
	if characterClickWatcher then return end
	characterClickWatcher = CreateFrame("Frame")
	local elapsed = 0
	characterClickWatcher:SetScript("OnUpdate", function(_, delta)
		elapsed = elapsed + delta
		if elapsed < 0.1 or InCombatLockdown() then return end
		elapsed = 0
		-- Titan reparents and shows plugins after registration. The initial
		-- visibility and frame level are therefore not their final values.
		for plugin, overlay in pairs(characterClickFrames) do
			SyncCharacterClick(plugin, overlay)
		end
	end)
end

local function InstallCharacterClick(frame)
	-- The secure button has no parent, anchor or script link to Titan frames.
	local pending = CreateFrame("Frame")
	local function Setup()
		if InCombatLockdown() or not CharacterMicroButton then return end
		local click = CreateFrame("Button", frame:GetName() .. "CharacterClick", UIParent,
			"SecureActionButtonTemplate,SecureHandlerStateTemplate")
		click:SetFrameStrata(frame:GetFrameStrata())
		click:SetFrameLevel(frame:GetFrameLevel() + 1)
		click:RegisterForClicks("LeftButtonUp")
		click:SetPassThroughButtons("RightButton", "MiddleButton")
		click:SetAttribute("useOnKeyDown", false)
		click:SetAttribute("*clickbutton1", CharacterMicroButton)
		click:SetAttribute("*type1", "click")
		SyncCharacterClick(frame, click)
		for _, script in ipairs({ "OnEnter", "OnLeave" }) do
			local handler = frame:GetScript(script)
			if handler then click:SetScript(script, function() handler(frame) end) end
		end
		frame.characterClick = click
		WatchCharacterClick(frame, click)
		pending:UnregisterAllEvents()
	end
	pending:SetScript("OnEvent", Setup)
	pending:RegisterEvent("PLAYER_LOGIN")
	pending:RegisterEvent("PLAYER_ENTERING_WORLD")
	pending:RegisterEvent("PLAYER_REGEN_ENABLED")
	Setup()
end

function L.Elib(config)
	if config.characterClick and not issecretvalue then
		config.onClick = function(_, button)
			if button == "LeftButton" then ToggleCharacter("PaperDollFrame") end
		end
	end
	local frame = RegisterPlugin(config)
	if config.characterClick and issecretvalue then InstallCharacterClick(frame) end
	return frame
end
-----------------------------------------------
function formatNumber(amount, sep)
	local formatted = amount
	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1' .. sep .. '%2')
		if (k==0) then
			break
		end
	end
	return formatted
end
-----------------------------------------------
function L.SimplifyNumber(number, decimal)
	if not decimal then decimal = 1 end

	if number > 1000000 then
		return string.format("%."..decimal.."fM", number / 1000000)
	end
	if number > 1000 then
		return string.format("%."..decimal.."fk", number / 1000)
	end

	return math.floor(number)
end
-----------------------------------------------
local function ToggleRightSideDisplay(self, id) -- Right side display
	TitanUtils_SwapButtonSide(id)
end

local function ToggleShowBarBalance(self, id) -- Show Balance in Titan Bar
	TitanToggleVar(id, "ShowBarBalance");
	TitanPanelButton_UpdateButton(id)
end

function L.CreateMenuTitle(text)
	return {
		text = text,
		hasArrow = false,
		notClickable = true,
		isTitle = true,
		isUninteractable = true,
		notCheckable = true,
	}
end

function L.AddBarPositionMenu(eddm, id)
	eddm.UIDropDownMenu_AddSpace()
	eddm.UIDropDownMenu_AddButton(L.CreateMenuTitle(L["barPosition"]))

	eddm.UIDropDownMenu_AddButton({
		text = L["moveRight"],
		func = function() TitanUtils_ShiftButtonOnBarRight(id) end,
		keepShownOnClick = true,
		notCheckable = true,
	})

	eddm.UIDropDownMenu_AddButton({
		text = L["moveLeft"],
		func = function() TitanUtils_ShiftButtonOnBarLeft(id) end,
		keepShownOnClick = true,
		notCheckable = true,
	})

	eddm.UIDropDownMenu_AddSeparator()
end

function L.PrepareAttributesMenu(eddm, self, id)
	eddm.UIDropDownMenu_AddButton(L.CreateMenuTitle(TitanPlugins[id].menuText))
	eddm.UIDropDownMenu_AddButton(L.CreateMenuTitle(L["buttonText"]))

	info = {};
	info.text = L["showbb"];
	info.func = ToggleShowBarBalance;
	info.arg1 = id
	info.checked = TitanGetVar(id, "ShowBarBalance");
	info.keepShownOnClick = true
	eddm.UIDropDownMenu_AddButton(info);

	info = {};
	info.text = ACE["TITAN_CLOCK_MENU_DISPLAY_ON_RIGHT_SIDE"];
	info.func = ToggleRightSideDisplay;
	info.arg1 = id
	info.checked = TitanGetVar(id, "DisplayOnRightSide");
	info.keepShownOnClick = true
	eddm.UIDropDownMenu_AddButton(info);

	if not TitanPlugins[id].hideLabelOption then
		local info = {}
		info.text = ACE["TITAN_PANEL_MENU_SHOW_LABEL_TEXT"]
		info.notCheckable = false
		info.func = function()
			TitanPanelRightClickMenu_ToggleVar({ id, "ShowLabelText", nil })
		end
		info.checked = TitanGetVar(id, "ShowLabelText")
		info.keepShownOnClick = true
		eddm.UIDropDownMenu_AddButton(info)
	end

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
----------------------------------------------
