--[[
	Do you want help us translating to your language?
	Send me your translation in: https://www.curseforge.com/wow/addons/titan-panel-attributes-multi
	Author: Canettieri
  Korean translator: next96
--]]

local _, L = ...;
if GetLocale() == "koKR" then
L.manaRegenCasting = "시전 중"
L.manaRegenUnit = "마나/초"
L.resistances = "마법 저항"
L.defense = "방어 숙련"
L.defenseMaximum = "현재 레벨의 기본 한도"
L.weaponSkills = "무기 숙련"
L.weaponSkillSelect = "바에 표시할 무기 숙련"
L.weaponSkillAutomatic = "자동 (주 장비)"
L.attributeBase = "기본"
L.attributeBonus = "보너스"
L.healthRegen = "생명력 재생"
L.healthRegenNormal = "비전투 중"
L.healthRegenCombat = "전투 중"
L.healthRegenCombatText = "전투"
L.healthRegenUnit = "생명력/초"
L.healthRegenInfo = "게임에서 제공하는 지속 생명력 재생입니다. 치유 주문과 생기흡수는 제외됩니다."
L.healthRegenUnavailable = "— = 사용할 수 없거나 게임에서 보호하는 값입니다."
-- Block
L["block"] = "막기"
L["blockt"] = "방패 막기"
-- Critical
L["critical"] = "치명타 및 극대화"
-- Dodge
L["dodge"] = "회피"
L["dodget"] = "회피율"
-- Haste
L["haste"] = "가속"
-- Item Level
L["ilvl"] = "아이템 레벨"
L["overall"] = "전체: "
L["equipped"] = "착용: "
-- Mana Regeneration
L["manareg"] = "마나 회복량"
-- Mastery
L["mastery"] = "특화"
-- Melee Power
L["meleepower"] = "근접 전투력"
-- Parry
L["parry"] = "막기"
L["parryt"] = "무기 막기"
-- Ranged Power
L["rangedpower"] = "원거리"
-- Spell Power
L["spellpower"] = "주문력"
-- Versatility
L["versatility"] = "유연성"
--- Shared
L["session"] = "손익 계산: "
L["moreinfo"] = "|cFFB4EEB4도움말:|r |cFFFFFFFF마우스 클릭으로 의 캐릭터 창을 엽니다. " -- In this case, player name is always the last word. I change it and I think it's wrong now. (sorry)
L["showbb"] = "바에 수입과 지출을 표시합니다."
L["buttonText"] = "바 텍스트"
L["barPosition"] = "바 위치"
L["moveRight"] = "오른쪽으로 이동"
L["moveLeft"] = "왼쪽으로 이동"
L["foreverPrimary"] = "주 특성"
L["foreverSecondary"] = "보조 특성"
L["foreverSpecHint"] = "왼쪽 클릭: 특성\n오른쪽 클릭: 특성 구성 및 장비"
L["foreverSpecChoose"] = "특성 구성 전환"
L["foreverLinkedEquipment"] = "이 구성에 연결된 장비 세트"
L["foreverBindEquipment"] = "이 구성에 장비 연결"
L["foreverTalentPoints"] = "특성 포인트 분배 표시"
L["foreverSpecLocked"] = "특성 구성이 잠겨 있습니다"
end
