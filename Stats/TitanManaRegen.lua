-- Native mana regeneration: the normal and casting rates are distinct.
local ADDON_NAME, L = ...
if type(GetManaRegen) ~= "function" then return end
local metadata = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata
local ID = "TITAN_MARGM"
local baseText, castingText, balanceText, barText = "—", "—", "—", "—"
local start, barBalance
local inCombat = false
local charname = "|c" .. RAID_CLASS_COLORS[select(2, UnitClass("player"))].colorStr .. UnitName("player") .. "|r"

local function PublicNumber(value)
	if issecretvalue and issecretvalue(value) then return nil end
	if type(value) ~= "number" or value ~= value or value == math.huge or value == -math.huge then return nil end
	return value
end

local function Format(value)
	if value == nil then return "—" end
	if value == 0 then return "0" end
	-- Do not display a small positive rate (or session change) as zero.
	if value > 0 and value < 0.1 then return "<0.1" end
	if value < 0 and value > -0.1 then return ">-0.1" end
	return string.format("%.1f", value)
end

local function Refresh()
	local ok, base, casting = pcall(function()
		local normal, active = GetManaRegen()
		return PublicNumber(normal), PublicNumber(active)
	end)
	if not ok then base, casting = nil, nil end
	if start == nil and base ~= nil then start = base end
	local nextBase, nextCasting = Format(base), Format(casting)
	local nextBar = "|cFFFFFFFF" .. nextBase .. "|r"
	if base == nil and inCombat then nextBar = "|cFFFF2e2e" .. L.healthRegenCombatText .. "|r" end
	local nextBalance, nextBarBalance = "—", ""
	if base ~= nil and start ~= nil then
		local delta = base - start
		local color = delta > 0 and "|cFF69FF69" or delta < 0 and "|cFFFF2e2e" or "|cFFFFFFFF"
		nextBalance = color .. Format(delta) .. "|r"
		if delta ~= 0 then nextBarBalance = " " .. color .. "[" .. Format(delta) .. "]|r" end
	end
	if baseText == nextBase and castingText == nextCasting and barText == nextBar
		and balanceText == nextBalance and barBalance == nextBarBalance then return true end
	baseText, castingText, barText = nextBase, nextCasting, nextBar
	balanceText, barBalance = nextBalance, nextBarBalance
	TitanPanelButton_UpdateButton(ID)
	return true
end

local function EnterWorld()
	inCombat = not not UnitAffectingCombat("player")
	Refresh()
end

local function GetButtonText()
	local balance = ""
	if TitanGetVar(ID, "ShowBarBalance") then balance = barBalance or "" end
	return L.manareg .. ": ", barText .. balance
end

local function GetTooltipText()
	return L.moreinfo .. charname .. "|cFFFFFFFF.|r\n \n"
		.. L.manareg .. ":\t|cFFFFFFFF" .. baseText .. " " .. L.manaRegenUnit .. "|r\n"
		.. L.manaRegenCasting .. ":\t|cFFFFFFFF" .. castingText .. " " .. L.manaRegenUnit .. "|r\n"
		.. L.session .. "\t" .. balanceText
end

local expansionLevel = GetExpansionLevel()
L.Elib({
	id = ID,
	name = "Titan|cFFf9251a " .. L.manareg .. "|r Multi",
	tooltip = L.manareg,
	icon = expansionLevel >= 9 and "Interface\\Icons\\spell_arcane_manatap.blp" or "Interface\\Icons\\spell_frost_manarecharge",
	category = "Information",
	version = metadata(ADDON_NAME, "Version"),
	characterClick = true,
	onUpdate = Refresh,
	getButtonText = GetButtonText,
	getTooltipText = GetTooltipText,
	prepareMenu = L.PrepareAttributesMenu,
	savedVariables = { ShowIcon = 1, DisplayOnRightSide = false, ShowBarBalance = false, ShowLabelText = false },
	eventsTable = {
		PLAYER_ENTERING_WORLD = EnterWorld,
		PLAYER_REGEN_DISABLED = function() inCombat = true; Refresh() end,
		PLAYER_REGEN_ENABLED = function() inCombat = false; Refresh() end,
	},
})
