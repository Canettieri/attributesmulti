local ADDON_NAME, L = ...
if type(GetSpellBonusHealing) ~= "function" then return end
local A, ID = L.LegacyAttributes, "TITAN_HEALING_POWER"
local current, start

local function Refresh()
	local ok, value = pcall(GetSpellBonusHealing)
	local nextValue = ok and A.Number(value) or nil
	if start == nil and nextValue ~= nil then start = nextValue end
	if current ~= nextValue then
		current = nextValue
		TitanPanelButton_UpdateButton(ID)
	end
	return true
end

A.Register(ADDON_NAME, ID, L.healingPower, "Interface\\Icons\\spell_holy_flashheal", Refresh,
	function()
		local balance = ""
		if TitanGetVar(ID, "ShowBarBalance") and current ~= nil and start ~= nil and current ~= start then
			balance = " [" .. A.Balance(current, start) .. "]"
		end
		return L.healingPower .. ": ", "|cFFFFFFFF" .. A.Format(current) .. "|r" .. balance
	end,
	function()
		return A.Hint() .. A.Row(L.healingPower, A.Format(current))
			.. "\n" .. L.session .. "\t" .. A.Balance(current, start)
	end, nil, { ShowBarBalance = false }, L.PrepareAttributesMenu)
