# PC / #3 master visual reference

This directory contains the accepted player-character identity reference for Umbrella Quest and future #3 production.

## Master reference

The accepted OpenAI image-generation reference is:

- source filename: `gritty_noir_hero_character_sheet.png`
- generation ID: `0420ca57-95db-41ee-b265-c54e2fd401a7`
- original generated dimensions: **2172x724**
- transparent background
- six consistent full-body key poses

No new character design was generated for Slice 16.

## Production runtime atlas

The live player now uses:

`pc3_reference_atlas_hd.webp`

Runtime dimensions:

**864x288**

This asset is a higher-resolution derivative of the exact accepted 2172x724 sheet.

The former `pc3_reference_atlas.webp` is only **216x72** and is retained as historical/prototype source material. It is no longer the authoritative runtime character because scaling roughly 70-pixel-tall pose crops to ~164 display pixels visibly degraded the art.

### Pose regions

| Pose ID | HD region |
| --- | --- |
| `front` | `Rect2(12, 4, 112, 280)` |
| `walk_left_3q` | `Rect2(152, 12, 120, 272)` |
| `idle_right_3q` | `Rect2(304, 8, 100, 276)` |
| `side_right` | `Rect2(428, 16, 156, 268)` |
| `rear_right_3q` | `Rect2(588, 12, 112, 272)` |
| `combat` | `Rect2(704, 36, 160, 248)` |

The regions preserve the same pose layout as the earlier atlas at 4x linear resolution.

## Locked identity

#3 uses:

- messy dark hair;
- light stubble;
- dark charcoal field jacket;
- muted dark-green sweater over a collared shirt;
- dark trousers;
- sturdy dark boots;
- worn brown cross-body messenger bag;
- grounded adult proportions;
- graphic-novel ink rendering;
- cool teal shadow/rim accents;
- restrained amber edge light.

Future #3 production art must extend this identity rather than redesigning the protagonist independently for each room.

## Runtime staging contract

Room scenes do **not** embed separate player textures.

`AdventurePlayerActor` owns the shared HD atlas and applies:

- room-authored default resting pose;
- direction-aware movement pose;
- horizontal mirroring;
- room-authored far/near perspective scale;
- bottom-center visual pivot;
- combat pose override.

The gameplay actor footprint and foot position remain independent from rendered character size.

This keeps:
- click-to-walk;
- approach points;
- transitions;
- saves;
- combat coordinates

stable while the visible character scales to the room.

## Acceptance note

Slice 16 removes the largest known fidelity defect in the PC path: destructive runtime downsampling.

Automated tests can prove that the HD source is actually used and staged correctly. They **cannot** by themselves certify artistic acceptance. Until the deployed character is visually accepted by the user, the repository must not claim that #3 is user-accepted production-complete.
