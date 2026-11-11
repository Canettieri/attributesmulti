-- Native passive regeneration; this is not a healing or damage meter.
local ADDON_NAME, L = ...
if type(GetHealthRegen) ~= "function" then return end
local GetAddOnMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata
local ID = "TITAN_HEALTH_REGEN"
local normal, combat, current = "—", "—", "—"
local barValue = "—"
local inCombat = false
local showCombatText = false
local normalStart, combatStart
local session = "—"
local barBalance = ""
local charname = "|c" .. RAID_CLASS_COLORS[select(2, UnitClass("player"))].colorStr .. UnitName("player") .. "|r"

local function FormatRate(value)
	if issecretvalue and issecretvalue(value) then return "—" end
	if type(value) ~= "number" or value ~= value or value < 0 or value == math.huge then return "—" end
	return string.format("%.1f", value) .. " " .. L.healthRegenUnit, value
end

local function ReadRates()
	local base, fighting = GetHealthRegen()
	local baseText, baseValue = FormatRate(base)
	local combatText, combatValue = FormatRate(fighting)
	return baseText, combatText, baseValue, combatValue
end

local function Refresh()
	local ok, base, fighting, baseValue, combatValue = pcall(ReadRates)
	if not ok then base, fighting = "—", "—" end
	if normalStart == nil and baseValue ~= nil then normalStart = baseValue end
	if combatStart == nil and combatValue ~= nil then combatStart = combatValue end
	local value, start = baseValue, normalStart
	if inCombat then value, start = combatValue, combatStart end
	barValue = value ~= nil and string.format("%.1f", value) or "—"
	session = "—"
	local previousBalance = barBalance
	barBalance = ""
	if value ~= nil and start ~= nil then
		local difference = value - start
		local color = difference > 0 and "|cFF69FF69" or difference < 0 and "|cFFFF2e2e" or "|cFFFFFFFF"
		session = color .. string.format("%.1f", difference) .. " " .. L.healthRegenUnit .. "|r"
		if difference ~= 0 then barBalance = " " .. color .. "[" .. string.format("%.1f", difference) .. "]|r" end
	end
	local active = inCombat and fighting or base
	local nextCombatText = inCombat and combatValue == 0
	if normal == base and combat == fighting and current == active and showCombatText == nextCombatText and previousBalance == barBalance then return true end
	normal, combat, current = base, fighting, active
	showCombatText = nextCombatText
	TitanPanelButton_UpdateButton(ID)
	return true
end

local function EnterCombat()
	inCombat = true
	Refresh()
end

local function LeaveCombat()
	inCombat = false
	Refresh()
end

local function EnterWorld()
	inCombat = not not UnitAffectingCombat("player")
	Refresh()
end

local function GetTooltipText()
	return L.moreinfo .. charname .. "|cFFFFFFFF.|r\n \n"
		.. L.healthRegenNormal .. ":\t|cFFFFFFFF" .. normal .. "|r\n"
		.. L.healthRegenCombat .. ":\t|cFFFFFFFF" .. combat .. "|r\n"
		.. L.session .. "\t" .. session
end

L.Elib({
	id = ID,
	name = "Titan|cFFf9251a " .. L.healthRegen .. "|r Multi",
	tooltip = L.healthRegen,
	icon = "Interface\\Icons\\spell_nature_rejuvenation",
	category = "Information",
	version = GetAddOnMetadata(ADDON_NAME, "Version"),
	characterClick = true,
	hideIconOption = true,
	attributeMenuOrder = true,
	onUpdate = Refresh,
	getButtonText = function()
		local text = showCombatText and L.healthRegenCombatText or barValue
		local color = showCombatText and "|cFFFF2e2e" or "|cFFFFFFFF"
		local balance = ""
		if TitanGetVar(ID, "ShowBarBalance") and not showCombatText then balance = barBalance end
		return L.healthRegen .. ": ", color .. text .. "|r" .. balance
	end,
	getTooltipText = GetTooltipText,
	menus = {
		{ type = "rightSideToggle" },
		{ type = "toggle", text = L.showbb, var = "ShowBarBalance", def = false, keepShown = true, barOption = true },
	},
	savedVariables = { ShowIcon = 1, ShowLabelText = false, DisplayOnRightSide = false, ShowBarBalance = false },
	eventsTable = {
		PLAYER_ENTERING_WORLD = EnterWorld,
		PLAYER_REGEN_DISABLED = EnterCombat,
		PLAYER_REGEN_ENABLED = LeaveCombat,
	},
})
