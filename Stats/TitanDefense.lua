local ADDON_NAME, L = ...
if type(UnitDefenseSkill) ~= "function" then return end
local A, ID = L.LegacyAttributes, "TITAN_DEFENSE"
local base, bonus, total, maximum, start
local inCombat, showCombatText = false, false
local function Refresh()
	local ok, nextBase, nextBonus = pcall(function()
		local value, modifier = UnitDefenseSkill("player")
		return A.Number(value), A.Number(modifier)
	end)
	if not ok then nextBase, nextBonus = nil, nil end
	local levelOK, nextMaximum = pcall(function()
		local level = A.Number(UnitLevel("player"))
		if level and level > 0 then return level * 5 end
	end)
	if not levelOK then nextMaximum = nil end
	local nextTotal
	if nextBase ~= nil and nextBonus ~= nil then nextTotal = nextBase + nextBonus end
	if start == nil and nextTotal ~= nil then start = nextTotal end
	local nextCombatText = inCombat and nextTotal == nil
	local changed = base ~= nextBase or bonus ~= nextBonus or total ~= nextTotal or maximum ~= nextMaximum or showCombatText ~= nextCombatText
	base, bonus, total = nextBase, nextBonus, nextTotal
	maximum = nextMaximum
	showCombatText = nextCombatText
	if changed then TitanPanelButton_UpdateButton(ID) end
	return true
end
A.Register(ADDON_NAME, ID, L.defense, "Interface\\Icons\\ability_defend", Refresh,
	function()
		if showCombatText then return L.defense .. ": ", "|cFFFF2e2e" .. L.healthRegenCombatText .. "|r" end
		local balance = ""
		if TitanGetVar(ID, "ShowBarBalance") and total ~= nil and start ~= nil then
			local delta = total - start
			if delta ~= 0 then
				local color = delta > 0 and "|cFF69FF69" or "|cFFFF2e2e"
				balance = " " .. color .. "[" .. A.Format(delta) .. "]|r"
			end
		end
		return L.defense .. ": ", "|cFFFFFFFF" .. A.Format(total) .. "|r/|cFFFF2e2e" .. A.Format(maximum) .. "|r" .. balance
	end,
	function()
		local lines = {
			A.Row(L.defense, A.Format(total)),
			A.Row(L.defenseMaximum, A.Format(maximum)),
		}
		if bonus ~= nil and bonus ~= 0 then
			lines[#lines + 1] = A.Row(L.attributeBonus, A.Format(bonus))
		end
		lines[#lines + 1] = L.session .. "\t" .. A.Balance(total, start)
		return A.Hint() .. table.concat(lines, "\n")
	end, nil, { ShowBarBalance = false }, L.PrepareAttributesMenu, {
		PLAYER_ENTERING_WORLD = function()
			inCombat = not not UnitAffectingCombat("player")
			Refresh()
		end,
		PLAYER_REGEN_DISABLED = function() inCombat = true; Refresh() end,
		PLAYER_REGEN_ENABLED = function() inCombat = false; Refresh() end,
	})
