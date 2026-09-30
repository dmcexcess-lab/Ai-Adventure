# Current

## Status

**Umbrella Quest Slice 10 — Multi-room world skeleton: COMPLETE**

Chapter One production remains paused.

Umbrella Quest is now a traversable eight-room compact world using the Slice 9 comic-noir visual language and the production point-and-click interaction primitives.

## Demo world

The complete Slice 10 map is now playable:

1. **Exterior Entry / Awning**
   - rainy front entrance;
   - community-center doors;
   - service-alley route.
2. **Community Center Lobby**
   - Slice 9 reference artwork preserved;
   - umbrella rack;
   - claim board;
   - vending machine;
   - routes to exterior, front desk, and Lost & Found.
3. **Front Desk**
   - dedicated reception composition;
   - Alex staged as the representative NPC;
   - closing-log placeholder;
   - staff-office route.
4. **Lost & Found Hall**
   - claim cabinets;
   - lobby return;
   - storage and maintenance branches.
5. **Staff Office**
   - shift/corkboard focal area;
   - reception return;
   - maintenance access.
6. **Storage Room**
   - lost-property overflow shelving;
   - hall return;
   - service connection to maintenance.
7. **Maintenance Corridor**
   - electrical-panel focal area;
   - links to Lost & Found, office, storage, and loading bay.
8. **Loading Bay / Service Exit**
   - roll-up loading door;
   - rear service staging;
   - maintenance return;
   - exterior loop.

The map is intentionally interconnected rather than a one-way sequence.

## Room presentation

Seven new authored SVG environment backgrounds join the Slice 9 lobby reference art.

Every room is composed from the start around:

- a dominant focal area;
- foreground / midground / background separation;
- readable floor staging;
- heavy comic shadow/outline language;
- charcoal, slate, dirty teal, amber, and restrained warning accents;
- obvious doorway silhouettes;
- room-scale player readability.

This is the world-skeleton art pass, not the Slice 14 finished graphics pass.

## Demo room architecture

The Umbrella shell now contains a persistent `RoomHost`.

Each room is a separate scene using the shared:

- player actor;
- hotspot contract;
- approach-before-action behavior;
- inspect behavior;
- held hotspot reveal;
- named spawn-marker convention.

A new demo-local room controller handles transitions without using canonical `SceneRouter` or `GameState`.

This is deliberate: Umbrella Quest remains mechanically representative while staying isolated from ANAMNESIS story state.

## Navigation and save behavior

Transitions preserve authored entry positions through named destination spawn markers.

The persistent shell keeps:

- notebook state;
- demo evidence;
- hypothesis UI;
- dialogue state;
- trust;
- character UI.

The in-memory demo save now records:

- current demo room;
- player foot position;
- collected demo evidence;
- Alex trust.

Demo load can therefore restore a position in any of the eight rooms without writing to Chapter One save slots.

## Representative interaction staging

Slice 10 keeps story content intentionally light.

Representative interaction points now include:

- existing umbrella-rack and claim-board evidence examples;
- Alex at the front desk;
- closing log;
- claim cabinets;
- shift board;
- overflow shelves;
- electrical panel;
- loading-bay focal props;
- exterior environmental details.

Full authored clue progression belongs to Slice 11.

## Validation

Godot 4.7.2 CI now protects:

1. all eight demo room scenes load;
2. all seven new environment SVGs import;
3. every room has background art;
4. every room has the shared player visual contract;
5. every room exposes representative hotspots;
6. every transition target is a valid demo room;
7. every transition names a real destination spawn;
8. no room is an outgoing-route orphan;
9. the entire demo graph is reachable from the lobby;
10. persistent Umbrella shell UI still opens correctly;
11. hotspot reveal still works after the multi-room conversion;
12. existing lobby evidence interactions still work;
13. demo-local room/position save-load works;
14. canonical ANAMNESIS state remains untouched;
15. all interaction/evidence/deduction/dialogue/RPG/persistence regressions remain green;
16. real main-scene startup remains green.

The Pages export also checks that all eight room-background art resources, the shared player art, and Alex portrait are actually packaged into the Web PCK.

## NEXT OPERATION

**Umbrella Quest Slice 11 — Umbrella investigation loop**

Execute without requesting design decisions:

1. Turn the eight-room world into a complete non-canon missing-umbrella investigation with a clear beginning, middle, and resolution.
2. Define the compact case spine:
   - establish exactly which umbrella is missing;
   - determine when/where it moved;
   - identify the credible movement chain through the building;
   - determine who moved it and why;
   - resolve the case.
3. Add authored demo evidence distributed across the existing rooms. Use clue/evidence grammar rather than inventory-key puzzles.
4. Give critical findings at least two acquisition routes where practical so the mini-case cannot softlock.
5. Expand Alex and add the minimum additional witnesses needed to exercise topic dialogue and evidence presentation across multiple rooms.
6. Make the notebook genuinely drive progression:
   - acquired evidence;
   - visible support;
   - contradictions;
   - player-selected hypotheses;
   - established deductions.
7. Add a compact authored deduction chain that gates later investigation topics/areas logically without exposing undiscovered clue identities.
8. Preserve the existing four-skill UI, but do **not** make the full RPG route matrix yet; Slice 12 owns meaningful skill-specific alternate paths.
9. Keep combat out of this slice; Slice 13 owns combat.
10. Add a quest-resolution state and ending beat proving the umbrella case can be completed start-to-finish.
11. Keep all Umbrella state isolated from canonical Chapter One state and save slots.
12. Add protected tests for:
    - fresh-case start;
    - required evidence availability;
    - deduction progression;
    - witness/evidence interaction;
    - at least one alternate evidence route;
    - complete case resolution;
    - no room/navigation regressions;
    - canon-state isolation.
13. Run all existing regressions and main-scene startup.
14. Update `ROADMAP.md`, `ARCHITECTURE.md`, and `CURRENT.md`.
15. Commit/push, follow CI and Web deployment to terminal status, and verify exact `main` head.

Do not start Slice 12 in the same turn unless the user explicitly asks for multiple slices.
