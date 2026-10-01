# Current

## Status

**Umbrella Quest Slice 16 — PC/#3 production implementation: COMPLETE**

Chapter One production is blocked.

## User-accepted production status

**Still accepted as production-complete: the eight environment backgrounds only.**

Slice 16 is technically complete and deployed-candidate ready, but #3 remains pending user visual acceptance. CI success is not treated as artistic approval.

## What Slice 16 fixed

The accepted #3 source sheet is **2172x724**.

The previous live runtime atlas was only:

**216x72**

Its individual pose crops retained roughly 62-70 pixels of vertical detail and were then enlarged to a much larger on-screen figure.

The live player now uses:

`art/characters/pc3/pc3_reference_atlas_hd.webp`

Runtime dimensions:

**864x288**

The six live pose crops now retain roughly **248-280 pixels** of source height before the engine downsamples them into the room.

This removes the biggest known fidelity defect in the PC pipeline without redesigning #3.

## Preserved runtime contract

The following remain unchanged:

- accepted #3 identity and clothing;
- six key poses;
- room-authored idle angle;
- direction-aware movement pose;
- horizontal mirroring;
- room-authored far/near perspective scaling;
- bottom-center visual pivot;
- fixed 42x82 gameplay actor footprint;
- foot coordinate;
- approach points;
- transition positions;
- save positions;
- loading-bay combat pose override;
- all investigation/RPG/combat rules.

The character-art change is therefore presentation-only.

## Protected source-fidelity contract

The production-visual regression now fails if:

- the live PC stops using the HD atlas;
- the atlas drops below roughly 800x280;
- the active pose source crop falls below 240 pixels high;
- the visible PC returns to prototype-small staging;
- the gameplay footprint grows with the visual;
- room-authored default angles drift;
- near perspective stops being larger than far perspective;
- the Web export omits the HD atlas.

The Pages packaging gate now explicitly requires:

`pc3_reference_atlas_hd.webp`

## Production acceptance note

Automated tests prove that the accepted source is being used at sufficient runtime fidelity and that the actor is staged correctly.

They do **not** prove that the result has been artistically accepted.

Until the user approves #3 in the deployed build, repository language must continue to distinguish:

- **Slice 16 implementation complete**
from
- **#3 user-accepted production-complete**

## NEXT OPERATION

**Slice 17 — NPC + portrait art production**

Execute without requesting design decisions:

1. Keep the eight accepted environment backgrounds unchanged.
2. Keep the Slice 16 #3 runtime unchanged unless a concrete integration defect is discovered.
3. Treat these current live assets as prototype until replaced/accepted:
   - Alex room sprite;
   - Mina room sprite;
   - loading-bay opponent;
   - Alex dialogue portrait;
   - Mina dialogue portrait.
4. Bring the NPC room art to the accepted environment quality bar:
   - strong comic silhouette;
   - believable anatomy;
   - scene-coherent lighting;
   - proper room scale/perspective;
   - no flat placeholder/vector look.
5. Make each portrait unmistakably depict the same identity as its room sprite.
6. Preserve Alex/Mina witness logic, trust, evidence presentation, and all dialogue content.
7. Preserve combat rules and only replace the opponent presentation.
8. Remove prototype character resources from the live player path when production replacements exist.
9. Keep the title screen visibly marked **DEVELOPMENT BUILD**.
10. Add regression coverage for:
    - live NPC resource paths;
    - room staging;
    - portrait correspondence metadata where mechanically representable;
    - Web PCK packaging.
11. Do not claim user visual acceptance merely because CI passes.
12. Update `ROADMAP.md`, `ARCHITECTURE.md`, `VISUAL_DIRECTION.md`, and `CURRENT.md`.
13. Commit/push, follow CI and Web deployment to terminal success, and verify exact `main` head.

Do not begin Slice 18 or Chapter One in the same turn unless explicitly requested.
