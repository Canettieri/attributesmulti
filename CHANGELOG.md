# Changelog

## Added

- Added a Specializations module that displays the current specialization, talent loadout, loot specialization, and equipment set.
- Added a PvP Information module for Honor and PvP-related details.
- Added right-click menu options to manage talent loadouts, loot specialization, and equipment sets.

## Changed

- Standardized plugin menus with a consistent layout: content, separator, Hide, and Close.
- Improved the visual styling and update behavior of the Specializations module.
- Updated the Retail quest counter to use the current quest limit reported by the game, with color thresholds at 60%, 80%, and 100%.
- Kept the compact quest counter format as `active|max`.
- Updated the Classic quest counter to use dynamic limits and the same color thresholds where supported.

## Fixed

- Corrected session balance baselines for Avoidance, Leech, and Speed.
- Corrected the Armor session balance baseline by using the current armor value on login.
- Corrected the Mana Regeneration session balance baseline by using the current mana regeneration value on login.
- Corrected completed quest detection for failed quests in Classic.
- Fixed the loot specialization submenu state when the menu is reopened.
- Updated talent window access to use the compatible Retail API.
- Added expansion-aware Mana Regeneration icons so the shared module uses icons available in both Retail and Classic.

## Removed and Consolidated

- Removed the duplicate Mana Regeneration load in Classic Era.
- Removed `Classic/TitanManaRegen-ClassicEra.lua` and use the shared Mana Regeneration module instead.
- Removed the duplicate Classic Critical Strike and Stamina modules.
- Updated Classic Era and Mists to use the shared Critical Strike and Stamina modules.
- Kept Quest, Hit Chance, Spirit, and Mastery modules separate where their game API requirements differ.
