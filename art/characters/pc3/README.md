# PC / #3 master visual reference

This directory contains the accepted player-character visual identity for Umbrella Quest and the future #3 production character.

## Master reference

The accepted OpenAI image-generation reference is:

- source filename: `gritty_noir_hero_character_sheet.png`
- generation ID: `0420ca57-95db-41ee-b265-c54e2fd401a7`
- original generated dimensions: 2172x724
- transparent background
- six consistent full-body poses

The runtime atlas is a Web-sized derivative of that exact accepted sheet, not a redesign.

## Runtime atlas

`pc3_reference_atlas.webp` is 216x72 and preserves alpha. It is intentionally Web-sized for the 42x82 room actor footprint.

Pose regions:

| Pose ID | Region |
| --- | --- |
| `front` | `Rect2(3, 1, 28, 70)` |
| `walk_left_3q` | `Rect2(38, 3, 30, 68)` |
| `idle_right_3q` | `Rect2(76, 2, 25, 69)` |
| `side_right` | `Rect2(107, 4, 39, 67)` |
| `rear_right_3q` | `Rect2(147, 3, 28, 68)` |
| `combat` | `Rect2(176, 9, 40, 62)` |

Do not replace this character with a generic room sprite. Room scenes select an authored default pose and perspective profile; movement selects direction-appropriate poses at runtime.

## Locked design language

The accepted PC/#3 identity uses:

- messy dark hair;
- light stubble;
- dark charcoal field jacket;
- muted dark-green sweater over a collared shirt;
- dark trousers;
- sturdy dark boots;
- worn brown cross-body messenger bag;
- grounded adult proportions;
- graphic-novel ink rendering;
- cool teal shadow/rim accents plus restrained amber edge light.

Future #3 art should use this atlas/reference as the visual identity anchor so Chapter One does not require a new protagonist design pass.
