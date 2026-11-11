# Titan Attributes Multi

Titan Attributes Multi is a collection of Titan Panel plugins for tracking character attributes, combat ratings, progression, and other character information across multiple versions of World of Warcraft.

Titan Panel is required.

![Titan Attributes Multi menu](https://i.imgur.com/SMGR1f4.jpg)

![Attribute plugins on the Titan bar](https://i.imgur.com/ZUZ9g24.jpg)

## Features

- Individual Titan plugins, so you can place only the attributes and information you want on the bar.
- Primary and combat statistics, including attributes, armor, critical strike, haste, mastery, versatility, speed, avoidance, leech, and more when supported by the game client.
- Session gains and losses for supported attribute plugins, optionally displayed directly on the Titan bar.
- Character information plugins for experience, quests, achievement points, deaths, honor, honorable kills, item level, PvP results, and specializations where available.
- Detailed tooltips with current values, session changes, rested experience, character item levels, and PvP win/loss totals as applicable.
- Left-click shortcuts to the relevant WoW window, such as the Character, Achievements, Quest Log, PvP, or Talents window.
- Retail specialization switching, talent-loadout selection, loot-specialization selection, and optional equipment-set and loot-specialization bindings per specialization.
- Expansion-aware loading, so each game client loads only the plugins it supports.

## Supported game versions

| Game client | Included plugins | Additional coverage |
| --- | ---: | --- |
| Retail / Midnight | 28 | Full combat-stat set, item level, achievements, honor, honorable kills, PvP results, quests, experience, deaths, and specializations |
| Mists of Pandaria Classic | 21 | Combat stats, Hit Chance, Mastery, Spirit, quests, achievements, and experience |
| The Burning Crusade Classic | 21 | Combat stats, Hit Chance, Spirit, quests, and experience |
| Classic Era | 18 | Combat stats, Spirit, quests, and experience |
| WoW: Forever / Camelot | 23 | Classic combat stats, Hit Chance, Haste, Ranged Power, Spirit, modern quests, experience, and talent profiles |

Each game client loads only the plugins listed in its corresponding `.toc` file.

Forever uses `TitanAttributesMulti_Camelot.toc` (interface 16001) with shared stat modules and the modern quest API. Its XP plugin uses the level-60 cap independently of the client's expansion constants. Install a Forever-compatible Titan Panel. Forever loads its own Specializations module; the Retail module and PvP Results are not loaded. In-game validation on Forever is still pending.

## Attribute plugins

The addon provides individual plugins for the following character statistics when they are available in your game client: Agility, Armor, Avoidance, Block, Critical Strike, Dodge, Haste, Intellect, Leech, Mana Regeneration, Mastery, Melee Power, Parry, Ranged Power, Speed, Spell Power, Stamina, Strength, and Versatility.

Hit Chance and Spirit are also available on supported Classic clients.

Most attribute plugins show the current value and can optionally show the change made during the current session. Left-click an attribute plugin to open the Character window.

## Character information plugins

Retail also includes plugins for Achievement Points, player deaths, Honor, Honorable Kills, Item Level, PvP Results, Quests, Experience, and Specializations. Some of these are also available on the supported Classic clients.

- **Experience** displays level progress, the remaining experience needed, and rested experience. Its menu can simplify the bar text or hide rested experience.
- **Item Level** displays equipped and overall item level, the current-session change, and saved equipped item levels for characters from the same faction.
- **PvP Results** displays wins, losses, and total matches for battlegrounds, rated battlegrounds, Battleground Blitz, and arenas.
- **Quests** shows active, completed, and maximum quest counts.
- **Mana Regeneration** is loaded on every supported client. The bar shows the normal rate with decimals and no unit; the tooltip also shows the rate while casting in mana per second. The normal rate is not automatically the active rate during combat. Protected readings show Combat in red during combat, or an em dash outside combat, and recover automatically when readable. Session changes retain decimals.
- **Magic Resistances** displays Fire, Nature, Frost, Shadow, and Arcane side by side on the bar and in the tooltip. It loads on Classic Era, TBC, Mists, and Forever when the API exists.
- **Defense** shows the effective defense skill and level-based maximum, with nonzero bonuses and session change in the tooltip, on Classic Era, TBC, and Forever.
- **Weapon Skills** shows a learned weapon skill and its maximum rank, including temporary and equipment bonuses. The tooltip lists learned weapons; right-click to choose which skill appears on the bar. It loads on Classic Era, TBC, and Forever. Classic clients using the legacy skill list require the weapon-skills category to be expanded for those rows to be available.
- **Health Regeneration** is available on Forever (Camelot), using the native `GetHealthRegen` API. The bar selects the normal or combat rate automatically, without units, and shows a red Combat label when the combat rate is zero. The tooltip shows both passive rates in HP/s and the session balance. It does not measure healing spells or leech. Clients without this API do not register the plugin. Combat readings still need in-game validation.
- **Honor** and **Honorable Kills** track your current PvP progression and session changes.

## Specializations (Retail)

The **Specializations** plugin shows your active specialization, talent loadout, equipped set, and loot specialization. Left-click it to open the Talents window.

Right-click the plugin to switch specializations, choose a saved talent loadout, use an equipment set, or change your loot specialization. You can also bind an equipment set and loot specialization to each specialization; the addon applies those bindings when you switch specializations. Changes that cannot be made in combat are applied after combat ends when possible.

## Talent profiles (Forever)

Forever has a separate **Specializations** module in `Forever/TitanSpecializations.lua`. It shows the active primary or secondary talent profile, with an optional compact distribution such as `31/15/5`. The tooltip names each talent tree and shows its spent points for each unlocked profile.

Left-click opens the Talents window. Right-click switches between unlocked talent profiles, equips a saved equipment set, or links a set to the current profile. Linked equipment is applied after the client confirms a profile change; equipment changes caused by an external profile change during combat wait until combat ends. The plugin does not equip a linked set merely because you log in. Changing a binding saves the association; **Equip set now** equips it immediately.

The module follows Forever's dual-spec model, so it does not show Retail loadout or loot-specialization menus. Profile bindings use their own per-character saved variable, separate from Retail settings.

## How to use

1. Right-click the Titan Panel.
2. Open the **Information** category. Its name may differ depending on your game language.
3. Enable the attribute or character-information plugins you want to display.
4. Right-click an enabled plugin to configure its icon, label, bar position, session balance, and other options available for that plugin.

## Languages

The addon currently includes translations for:

- English
- Brazilian Portuguese
- German
- Spanish (Spain)
- Korean
- Russian

Unsupported locales fall back to English.

## Support

Please report problems through the [GitHub issue tracker](https://github.com/Canettieri/attributesmulti/issues). When reporting an issue, include the WoW game version, character locale, and any error message shown by the client.

## Donations

If you would like to support continued development, you can [donate through PayPal](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=7AEAZ7XG7WVDS&lc=US&item_name=Titan%20Multi%20Addons&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donate_SM%2egif%3aNonHosted).

Many thanks to the people who have helped maintain this project:

- Colleen Harper
- Patricia Rich
- Adrian Collins
- Jessica Allen
- Randol Ford
- Sebastian Edelmann
- Edwin Sutton Jr.
- Dean Grable
- Peter Cebull
- Max Toedtemeier
