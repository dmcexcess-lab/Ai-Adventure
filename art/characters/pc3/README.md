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

`pc3_reference_atlas.webp` is 360x120 and preserves alpha.

Pose regions:

| Pose ID | Region |
| --- | --- |
| `front` | `Rect2(5, 2, 47, 116)` |
| `walk_left_3q` | `Rect2(63, 5, 50, 114)` |
| `idle_right_3q` | `Rect2(127, 4, 42, 115)` |
| `side_right` | `Rect2(179, 6, 65, 112)` |
| `rear_right_3q` | `Rect2(245, 5, 46, 114)` |
| `combat` | `Rect2(293, 15, 66, 103)` |

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
