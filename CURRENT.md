# Current

## Status

**Umbrella Quest Slice 14 — Full graphics production pass: COMPLETE**

Chapter One production remains paused.

Umbrella Quest now has the finished visual language required for the vertical-slice proof: production room backgrounds, coherent character art, portraits, ambient weather/light motion, player movement presence, and integrated combat feedback.

## Production room backgrounds

All eight Umbrella Quest locations now use packaged production PNG backgrounds:

1. Exterior Entry / Awning
2. Community Center Lobby
3. Front Desk
4. Lost & Found Hall
5. Staff Office
6. Storage Room
7. Maintenance Corridor
8. Loading Bay / Service Exit

The live runtime paths are under:

`art/demo/production/`

These replace the earlier reference/world-skeleton SVG backgrounds at runtime.

The existing gameplay map was deliberately preserved:

- hotspot rectangles;
- approach points;
- walk bounds;
- room transitions;
- spawn markers;
- evidence hooks;
- witness positions;
- combat trigger location.

The graphics pass does not rewrite the case or navigation.

## Finished visual language

The production room set follows `VISUAL_DIRECTION.md`:

- polished comic-book / graphic-novel treatment;
- dark worn municipal/city spaces;
- strong ink/silhouette separation;
- layered foreground, midground, and background depth;
- charcoal / slate / dirty teal base palette;
- amber practical-light contrast;
- wet/rainy exterior texture;
- focal separation around interaction zones;
- no greybox presentation.

## Character pass

The player sprite is now a more detailed production comic silhouette.

Alex now has:

- standalone front-desk room sprite;
- upgraded dialogue portrait.

Mina now has:

- upgraded standalone staff-office sprite;
- upgraded dialogue portrait.

The loading-bay opponent now shares the same production character language rather than reading as a prototype icon.

Room sprites remain intentionally simpler than portraits so they stay readable at 640x480.

## Ambient motion

Every Umbrella room now contains a lightweight `AmbientFX` layer.

Depending on the room, it supplies:

- rain streaks over exterior/window regions;
- restrained amber practical-light pulse.

The effect is drawn through lightweight Godot CanvasItem calls and remains compatible with the Web/Compatibility target.

No dynamic 3D, runtime-generated texture, heavy particle, or post-processing system was introduced.

## Player animation

The shared player actor now adds presentation motion without changing its movement contract:

- walk bob;
- slight walk lean/rotation;
- subtle idle presence.

Click-to-walk destinations, speed, approach behavior, arrival signals, saves, and room bounds remain unchanged.

## Combat presentation

Slice 13 combat rules are unchanged.

Slice 14 adds restrained visual response only:

- Strike recoil/flash;
- Guard panel pulse;
- Maneuver silhouette sway;
- Disengage fade pulse.

The loading-bay world remains visible behind combat, preserving the authored room rather than switching to a disconnected battle screen.

## Production asset packaging

The Pages workflow now fails if the exported PCK does not contain:

- all eight production room PNGs;
- player sprite;
- Alex sprite;
- Alex portrait;
- Mina sprite;
- Mina portrait;
- combat opponent art.

Critical production art remains directly referenced as Godot resources.

## Validation

Godot 4.7.2 CI passes:

1. clean production PNG import;
2. all production visual resources;
3. all eight room scenes;
4. production background path contract;
5. AmbientFX presence in every room;
6. active player walk/idle animation process;
7. standalone Alex staging;
8. standalone Mina staging;
9. dialogue portrait resources;
10. combat visual resources;
11. interaction regression;
12. evidence regression;
13. deduction regression;
14. dialogue regression;
15. RPG regression;
16. UI demo regression;
17. eight-room graph regression;
18. complete Umbrella investigation regression;
19. Umbrella RPG regression;
20. Umbrella combat regression;
21. persistence regression;
22. real main-scene startup.

No Slice 9-13 gameplay contract was intentionally changed.

## NEXT OPERATION

**Umbrella Quest Slice 15 — Polish and usability closure**

Execute without requesting design decisions:

1. Treat the current Umbrella Quest as the complete vertical slice and run a start-to-finish usability/production review rather than adding new feature systems.
2. Exercise the real player path from title screen through:
   - background selection;
   - exploration/navigation;
   - evidence acquisition;
   - notebook hypotheses/deductions;
   - Alex dialogue;
   - Mina dialogue;
   - skill routes and failures;
   - loading-bay combat;
   - post-combat investigation;
   - final umbrella recovery;
   - case-closed state.
3. Correct player-facing friction found by that review:
   - unclear objectives;
   - confusing button labels;
   - modal overlap;
   - weak feedback;
   - unreadable text;
   - poor hotspot discoverability;
   - transition ambiguity;
   - save/load messaging;
   - combat readability;
   - case-resolution clarity.
4. Preserve the locked case solution, skill rules, combat math, room graph, and final visual direction unless a concrete usability bug requires a narrow change.
5. Check all eight rooms for visual/hotspot alignment after the production-art swap and adjust hotspot rectangles/approach points only where the new art demonstrably requires it.
6. Verify 640x480 layout safety:
   - no clipped modal text;
   - no overlapping buttons;
   - dialogue choices remain visible;
   - Character/Notebook/Combat panels fit;
   - resolution panel fits.
7. Verify keyboard and mouse parity where currently supported:
   - 1-9 dialogue/background choices;
   - 1-4 combat;
   - notebook/evidence/character shortcuts;
   - Escape/back behavior;
   - held hotspot reveal.
8. Run local save/load through multiple rooms and after completed combat; confirm active-combat save/load remains safely blocked.
9. Run the full vertical-slice automated regression suite and real main-scene startup.
10. Strengthen tests for any usability bug corrected in this slice.
11. Perform final Web export/package validation and Firefox-oriented deployment checks available in CI.
12. Update `ROADMAP.md`, `ARCHITECTURE.md`, and `CURRENT.md` to mark Umbrella Quest vertical slice complete.
13. Commit/push, follow CI and Web deployment to terminal status, and verify exact `main` head.

Do not begin Chapter One Slice 16 in the same turn unless the user explicitly asks for multiple slices.
