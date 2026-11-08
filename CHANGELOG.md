# Changelog

All notable changes to this project will be documented in this file.

## [9.2.0] - 2026-11-08

### Fixed

- Open the character window through a secure Blizzard button click on clients with secret values, avoiding character-window status bar errors in Forever (Camelot).
- Keep secure click buttons independent of Titan's layout to avoid blocked scale updates during combat.
- Synchronize click button visibility, position, size, and scale after Titan initializes or moves plugins, while preserving character-window access during combat where allowed by the game.

## [9.1.0] - 2026-11-02

### Added

- Added the Item Level plugin to Mists of Pandaria Classic.

## [9.0.0] - 2026-11-01

### Added

- Added a dedicated Forever (Camelot, interface 16001) manifest with 19 plugins, including Spirit, Hit Chance, modern quests, and level-60 experience tracking.
- Added a separate Forever Specializations module for primary/secondary talent profiles, per-tree point distribution, unlocked-profile switching, and equipment bindings saved independently of Retail.
- Added translations for the Forever talent-profile controls in all six supported languages.
- Added `README.md` with installation, usage, and project information.
- Added **Move Right** and **Move Left** actions to plugin menus for changing their position on the Titan bar.

### Changed

- Updated the Retail interface version to 120105 for WoW 12.1.5.
- Kept Forever XP and primary-stat icons independent of Retail expansion constants.
- Reorganized plugin menus into **Bar Text** and **Bar Position** sections, with visual spacing between the sections.
- Reorganized the Specializations menu: specialization choices are followed by an **Options** section for loadouts, equipment, and loot settings, using visual spacing instead of separators.

### Fixed

- Initialized Spirit and Hit Chance session balances from their own values instead of Strength, and skipped unavailable or secret readings.
- Prevented division by zero when the client reports no XP requirement at level cap.
- Kept primary-stat and XP icon variables local to their modules.

## [8.0.0] - 2026-09-21

### Added

- Added a Specializations module that displays the current specialization, talent loadout, loot specialization, and equipment set.
- Added a PvP Information module for Honor and PvP-related details.
- Added right-click menu options to manage talent loadouts, loot specialization, and equipment sets.

### Changed

- Standardized plugin menus with a consistent layout: content, separator, Hide, and Close.
- Improved the visual styling and update behavior of the Specializations module.
- Updated the Retail quest counter to use the current quest limit reported by the game, with color thresholds at 60%, 80%, and 100%.
- Kept the compact quest counter format as `active|max`.
- Updated the Classic quest counter to use dynamic limits and the same color thresholds where supported.

### Fixed

- Corrected session balance baselines for Avoidance, Leech, and Speed.
- Corrected the Armor session balance baseline by using the current armor value on login.
- Corrected the Mana Regeneration session balance baseline by using the current mana regeneration value on login.
- Corrected completed quest detection for failed quests in Classic.
- Fixed the loot specialization submenu state when the menu is reopened.
- Updated talent window access to use the compatible Retail API.
- Added expansion-aware Mana Regeneration icons so the shared module uses icons available in both Retail and Classic.

### Removed

- Removed the duplicate Mana Regeneration load in Classic Era.
- Removed `Classic/TitanManaRegen-ClassicEra.lua` and use the shared Mana Regeneration module instead.
- Removed the duplicate Classic Critical Strike and Stamina modules.
- Updated Classic Era and Mists to use the shared Critical Strike and Stamina modules.
- Kept Quest, Hit Chance, Spirit, and Mastery modules separate where their game API requirements differ.

[9.0.0]: https://github.com/Canettieri/attributesmulti/releases/tag/v9.0.0
[8.0.0]: https://github.com/Canettieri/attributesmulti/releases/tag/v8.0.0
