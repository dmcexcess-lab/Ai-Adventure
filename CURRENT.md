# Current

## Status

**Umbrella Quest Slice 15 — Production rebaseline + PC/#3 staging repair: COMPLETE**

Chapter One production is blocked.

The repository previously overstated the production status of the vertical slice. The user has corrected the acceptance state:

## What is actually production-complete

**Only the eight environment backgrounds.**

Accepted production backgrounds:

1. Exterior Entry / Awning
2. Community Center Lobby
3. Front Desk
4. Lost & Found Hall
5. Staff Office
6. Storage Room
7. Maintenance Corridor
8. Loading Bay / Service Exit

Runtime location:

`art/demo/production/`

These backgrounds are the visual quality bar for everything else.

## What is not production-complete

The following remain prototype / pre-production regardless of whether their mechanics are functional or automated tests pass:

- PC/#3 runtime art and presentation;
- Alex room sprite;
- Mina room sprite;
- combat opponent art;
- Alex portrait;
- Mina portrait;
- HUD and bottom bar;
- Notebook / evidence / hypothesis presentation;
- dialogue presentation;
- Character panel;
- combat presentation;
- main menu;
- Settings UI (currently absent);
- room-transition presentation;
- foreground/depth treatment;
- character animation quality;
- audio/music/ambience/SFX (currently absent);
- save/load UX;
- accessibility polish;
- case-closed ending presentation;
- final full-run QA.

Functional completeness is not production acceptance.

## Slice 15 — PC/#3 staging repair

The first production-completion repair addresses a concrete runtime defect in the current protagonist implementation.

The accepted source character sheet is 2172x724, but the prototype runtime atlas was reduced to 216x72. The room actor then displayed those roughly 70-pixel-tall poses inside a 42x82 visual rectangle, making the protagonist implausibly small beside the environment and 168-pixel NPC staging.

Slice 15 keeps the same accepted identity and the same room-aware pose/perspective mechanics, but changes the rendered presentation:

- gameplay actor footprint remains 42x82;
- visible character rectangle becomes 84x164;
- visible art is bottom-centered on the unchanged gameplay foot position;
- room-authored perspective scaling still affects only the visual;
- linear texture filtering is used when scaling the current atlas;
- movement angle selection remains unchanged;
- loading-bay combat pose behavior remains unchanged.

This is a staging/runtime repair. It does **not** by itself certify the current character artwork as production-complete. Final character-art acceptance belongs to Slice 16.

## Production rule

A subsystem is only called production-complete when:

1. it meets the accepted environment-background quality bar or its equivalent for that subsystem;
2. it is integrated into the real player path;
3. its Web build is verified;
4. automated regression protects its functional contract;
5. it has no knowingly prototype-facing presentation remaining.

## NEXT OPERATION

**Slice 16 — Character art production**

Execute without requesting design decisions:

1. Keep the eight environment backgrounds exactly as the accepted production benchmark.
2. Treat every current character-facing asset as replaceable/prototype unless it independently reaches that benchmark.
3. Produce and integrate production-quality:
   - PC/#3 room presentation;
   - Alex room sprite;
   - Mina room sprite;
   - loading-bay opponent;
   - Alex portrait;
   - Mina portrait.
4. Preserve the accepted #3 identity and costume language; do not redesign the protagonist.
5. Preserve room-aware PC angle selection, perspective scaling, unchanged foot position, and combat-pose behavior.
6. Make PC/NPC scale and perspective coherent within each accepted background.
7. Ensure room sprites and portraits clearly depict the same character identities.
8. Remove or retire placeholder/vector character assets from the live player path when production replacements exist.
9. Keep all gameplay, evidence, RPG, dialogue, room-graph, and combat rules unchanged.
10. Add regression coverage for character resource packaging, scale/staging, identity correspondence where mechanically testable, and Web export.
11. Keep the title-screen label as DEVELOPMENT BUILD.
12. Update ROADMAP.md, ARCHITECTURE.md, VISUAL_DIRECTION.md, and CURRENT.md.
13. Commit/push, follow CI and Web deployment to terminal success, and verify exact main head.

Do not begin Slice 17 or Chapter One in the same turn unless explicitly requested.
