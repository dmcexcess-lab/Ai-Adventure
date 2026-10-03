# Current

## Status

**Umbrella Quest graphics-completion pass: IMPLEMENTED AND RENDER-VERIFIED**

The work lost from the “Finish Umbrella Adventure Graphics” task has been reconstructed from its rendered work log and original generated assets. The eight previously accepted environment paintings remain unchanged.

Automated success and local render review do not constitute user artistic acceptance. Chapter One remains blocked until the full Umbrella Quest production gate is accepted.

## Completed graphics work

- Restored all seven production runtime atlases from the exact recovered PNG bytes.
- PC/#3 has side, front, and rear four-frame walk cycles at 12 frames per second.
- Nine named clips cover conversation, reading, inspection, pickup, strike, guard, maneuver, hurt, and disengage.
- Room perspective now interpolates from 0.64 at the back plane to 1.16 at the front.
- The visible character scales around the foot pivot; the 42×82 actor, foot coordinate, approach points, transitions, and save positions remain unchanged.
- Alex and Mina each use one atlas for three room poses and three matching dialogue portraits.
- The loading-bay opponent has staged actions, reactions, and a matching portrait.
- Every evidence entry resolves to illustrated art from the twelve-object evidence atlas.
- The recovered umbrella appears in the loading bay and case-closed presentation.
- Alex is correctly occluded by a crop of the accepted front-desk painting.
- Room actors sort by foot position, and modal UI now stays above world actors.
- Combat uses staged player/opponent art above compact controls and locks repeat input during committed feedback.
- The main menu uses the accepted exterior painting and shared noir theme while retaining DEVELOPMENT BUILD labeling.

## Validation

- All existing smoke suites pass under Godot 4.7.2.
- `tests/graphics_completion_smoke.gd` protects atlas transparency/dimensions, clue coverage, foot/pivot invariance, strong depth scaling, walk advancement, nine actions, NPC/portrait correspondence, and combat repeat-input rejection.
- `tests/graphics_capture.gd` rendered and reviewed all eight rooms plus far/near depth, walking, both witnesses, notebook, character profile, combat, action feedback, and ending at 640×480.
- Render review repaired world-over-modal layering, character-profile overflow, combat/HUD overlap, duplicate room/combat staging, and case-closed overlay cleanup.

## Authoritative references

- `art/demo/GRAPHICS_MANIFEST.md` — recovered asset provenance and runtime role.
- `art/demo/visual_catalog.gd` — runtime atlas and clue/identity correspondence.
- `art/demo/atlas_regions.gd` — non-destructive atlas crops.
- `art/recovered/finish_umbrella_graphics/` — raw recovered chat outputs, including rejected variants.

## Next operation

After user graphics review, proceed with **Slice 20 — Audio + settings production**. Correct any reported visual defects first. Do not describe the graphics as user-accepted until they are actually accepted.
