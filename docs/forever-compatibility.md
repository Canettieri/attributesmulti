# Forever compatibility

Reviewed 2026-11-01. Forever uses a modern UI/API family with Classic content;
it must not be selected using Retail expansion constants alone.

`TitanAttributesMulti_Camelot.toc` declares interface 16001 and loads 19 plugins:
Agility, Armor, Block, Critical Strike, Dodge, Haste, Hit Chance, Intellect,
Mana Regeneration, Melee Power, Parry, Ranged Power, Spell Power, Spirit,
Stamina, Strength, Quests, Experience, and Specializations.

`Core/Forever.lua` sets an addon-local client flag. It selects the level-60 XP
cap and Classic Strength, Intellect, and faction XP icons. Existing manifests
do not load this file. The quest plugin uses `C_QuestLog`; the Classic quest
module's legacy globals are not used on Forever. Hit Chance continues to report
the melee hit bonus, not a target-dependent absolute hit probability.

Spirit and Hit Chance now initialize the session baseline from their own first
readable values, retry on later polling if a value is unavailable, and retain
their last value when a reading is inaccessible. Both retain their plugin IDs
and saved options. Other stat modules and Titan libraries are shared unchanged.

## Talent profiles

`Forever/TitanSpecializations.lua` is independent of `Misc/TitanSpecializations.lua`.
It uses `GetNumSpecGroups`, `C_SpecializationInfo.GetActiveSpecGroup`,
`GetCombatConfigIDForSpecGroup`, and `SetActiveSpecGroup` to manage primary and
secondary profiles. It never treats class spec IDs as selectable talent trees.
`C_Traits` group display/currency data supplies tree names, icons, and spent points.
Missing talent data is displayed as unavailable, and locked profiles cannot be selected.

The source Camelot frame hides the Retail loadout system. Accordingly, this
module offers no Retail loadout, starter-build, or loot-specialization menus.
Equipment bindings use `TitanForeverSpecializationsMultiDB.gearByGroup` and are
applied only after a confirmed profile change, deferred if necessary until combat
ends. Login does not trigger a gear change. Polling also detects profile changes
when an event is missed. The module works without equipment APIs, omitting their
menus, and handles talent data not being available yet.

## Source checks

- [Camelot character sheet](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_UIPanels_Game/Camelot/PaperDollFrame.lua): Spirit and ranged stats; combat-rating constants.
- [Camelot stat calculations](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_UIPanels_Game/Camelot/PaperDollFrameStats.lua): melee hit uses combat-rating bonus plus hit modifier.
- [Forever quest API](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated/QuestLogDocumentation.lua): quest entries, quest information, completion status and standard quest limit.
- [Camelot talent frame](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_PlayerSpells/Camelot/ClassTalents/Blizzard_ClassTalentsFrame.lua): primary/secondary profiles, unlock check, group activation, tree display/currency data, and hidden Retail loadout controls.
- [Specialization API](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated/SpecializationInfoDocumentation.lua): group getter/config lookup/setter. The group setter returns no success flag.

## Validation

Run `lua tests/forever.lua` from the addon root with Lua 5.1. The mocked checks
load all 19 Forever plugins, invoke initialization and updates, render bar text
and tooltips, check session deltas and unreadable stats, and exercise quests
and XP at level cap with a zero XP requirement. Existing client XP paths and
module-local icon variables are checked separately. Tests are excluded from
release packages. `lua tests/forever-specializations.lua` separately checks tree
order, point distributions, locked profiles, asynchronous group confirmation,
combat guards and deferred equipment, bindings, Retail database isolation, and
missing talent/equipment APIs without relying on Retail spec/loadout/loot APIs.

These checks do not emulate the game's native secret-value system or Titan's
actual layout. In-game validation, including combat restrictions, is pending.
Use a Titan Panel build compatible with Forever.
