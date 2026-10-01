# PC / #3 master visual reference

This directory contains the accepted player-character visual identity for Umbrella Quest and the future #3 production character.

## Master reference

The accepted OpenAI image-generation reference is:

- source filename: `gritty_noir_hero_character_sheet.png`
- generation ID: `0420ca57-95db-41ee-b265-c54e2fd401a7`
- original generated dimensions: **2172×724**
- transparent background
- six consistent full-body poses

Slice 15 does **not** regenerate or redesign the character. It derives production runtime textures from that exact accepted source.

## Production runtime pose set

The earlier 216×72 runtime atlas discarded too much source detail and is retired from live use.

Production runtime now uses six independently cropped WebP textures under `poses/`, each **240 pixels tall** and preserving alpha:

| Runtime pose ID | File | Source crop in 2172×724 sheet | Runtime size |
| --- | --- | --- | --- |
| `front` | `poses/front.webp` | `(26, 13)–(330, 712)` | 104×240 |
| `walk_left_3q` | `poses/walk_3q.webp` | `(363, 19)–(684, 715)` | 111×240 |
| `idle_right_3q` | `poses/idle_3q.webp` | `(725, 15)–(1036, 724)` | 105×240 |
| `side_right` | `poses/side.webp` | `(1049, 17)–(1480, 711)` | 149×240 |
| `rear_right_3q` | `poses/rear_3q.webp` | `(1480, 30)–(1757, 724)` | 96×240 |
| `combat` | `poses/combat.webp` | `(1762, 17)–(2172, 715)` | 141×240 |

The runtime actor never needs to enlarge these textures to their source height. At the current 42×82 actor footprint and authored room perspective ranges, even the nearest visible figure remains well below 240 pixels tall, so the production asset is downsampled rather than upscaled.

The retired `pc3_reference_atlas.webp` may remain in the repository as historical prototype material but is no longer authoritative or referenced by runtime code.

## Scene-aware integration

Do not replace this character with a generic room sprite.

Each room authors:
- a default resting pose;
- far and near perspective scale;
- top/bottom Y references.

Movement selects:
- side profile for dominant horizontal travel;
- rear three-quarter when moving deeper into the room;
- walking three-quarter when moving toward the camera.

Left/right travel mirrors the appropriate pose.

Perspective scales only the child visual around a **bottom-center pivot**. The player's gameplay foot coordinate, approach position, transition position, and save position do not move when the visual scale changes.

The loading-bay combat encounter switches to the accepted combat key pose and restores the room-authored pose when combat ends.

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

Future #3 production art should extend this accepted identity rather than rediscovering the protagonist.
