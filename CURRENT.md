# Current

## Status

**Umbrella Quest production completion rebaseline: ACTIVE**

Chapter One production is blocked.

The user's authoritative production assessment is:

> **The eight environment backgrounds are the only production-complete part of Umbrella Quest so far.**

Previous repository language that described the character layer, portraits, UI, animation, combat presentation, or whole vertical slice as production-complete is superseded.

## Production-complete now

### Eight room backgrounds

The following live production PNGs are accepted as the finished visual-quality reference:

1. Exterior Entry / Awning
2. Community Center Lobby
3. Front Desk
4. Lost & Found Hall
5. Staff Office
6. Storage Room
7. Maintenance Corridor
8. Loading Bay / Service Exit

Runtime path family:

`art/demo/production/*_production.png`

These backgrounds establish the required finished-product bar:

- polished comic-book / graphic-novel illustration;
- dark gritty city/institutional environments;
- authored lighting;
- material wear/grime;
- clear comic-panel composition;
- interaction readability.

## Not production-complete yet

The following remain prototype or pre-production even where mechanics are already implemented:

- PC / #3 runtime character art and integration;
- Alex and Mina room characters;
- loading-bay opponent presentation;
- dialogue portraits;
- character animation;
- foreground/depth integration;
- UI skin and layout;
- title/menu/settings flow;
- notebook;
- dialogue presentation;
- combat HUD/presentation;
- room transitions;
- audio;
- case-ending presentation;
- complete usability/acceptance pass.

The investigation, RPG, combat, persistence, and room-graph mechanics remain valid systems work. Their existence does not make their presentation production-complete.

## Why the current PC is not production-complete

The accepted source #3 sheet is **2172×724**.

The current runtime atlas is only **216×72**, then enlarged into an approximately **84×164** display box before perspective scaling.

That conversion discarded most of the source detail and guarantees softness/distortion in-game. The scene-aware pose/perspective logic itself is useful and remains.

## NEXT OPERATION

**Slice 15 — PC / #3 production character pass**

Execute without requesting design decisions:

1. Reuse the already accepted full-resolution #3 source sheet. Do not call a new image generator for this slice.
2. Replace the 216×72 runtime atlas with a high-resolution Web-sized derivative appropriate for the maximum on-screen render size.
3. Re-author the six atlas pose regions from the full-resolution source rather than scaling the old low-res crop map.
4. Preserve:
   - one stable #3 identity;
   - per-room resting pose;
   - movement-direction pose switching;
   - left/right mirroring;
   - foot-Y perspective interpolation;
   - combat key pose;
   - invariant gameplay foot position.
5. Verify all eight room perspective profiles against the production backgrounds.
6. Add protected regression for:
   - production atlas minimum dimensions;
   - six valid pose regions inside the atlas;
   - at least three authored default room angles;
   - horizontal/depth movement pose switching;
   - near scale > far scale;
   - bottom-center scale pivot;
   - combat pose entry/restoration;
   - unchanged player foot coordinate while visual scale changes.
7. Update the PC reference README with the actual production derivative dimensions and crop regions.
8. Keep NPCs, UI, audio, and ending out of this slice.
9. Run all existing regressions and real main-scene startup.
10. Commit/push, follow CI and Web deployment to terminal success, and verify exact `main` head.

Do not begin Slice 16 in the same turn unless the user explicitly asks for multiple slices.
