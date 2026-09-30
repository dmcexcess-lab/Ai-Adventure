# Current

## Status

**Slice 4 — Canonical state and persistence: COMPLETE**

The project now has authoritative serializable game state and a versioned persistence path suitable for the Godot Web build.

## Implemented

### Canonical GameState

`GameState` is now an autoload and owns:

- current room path;
- current room ID;
- player foot position;
- discovered clue state;
- deduction state;
- selected hypotheses;
- witness trust;
- chapter flags;
- four skill values;
- literal inventory;
- visited locations;
- playtime.

New games reset this state in one place. Rooms no longer need to become the sole owner of future investigation state.

### Scene-state synchronization

`SceneRouter` now synchronizes the active room and player position into GameState.

Room entry records canonical state only after the room exists and the player has been positioned.

Saved player positions are restored through the room contract and clamped to that room's authored walk bounds, so stale or invalid coordinates cannot strand the player outside the playable area.

Player arrival also refreshes canonical position state.

### SaveService

`SaveService` is now an autoload with:

- schema version **1**;
- content version **ch01-slice4**;
- JSON serialization;
- `user://saves` storage;
- manual slots `manual_1`, `manual_2`, `manual_3`;
- `autosave`;
- malformed-save rejection;
- future-schema rejection;
- migration hook;
- schema-0 to schema-1 migration coverage.

The format stores schema/content metadata separately from the canonical GameState payload.

### Save / Load UI

The lower game shell now exposes simple:

- **SAVE** — writes manual slot 1;
- **LOAD** — restores manual slot 1.

The Load control stays disabled until a valid slot file exists.

This is intentionally the minimum usable save UI; richer slot presentation can be layered later without changing the persistence service.

### Auto-save

Successful room entry writes the auto-save slot after canonical room/player state is synchronized.

Loading a save restores the saved room and safe player position without immediately overwriting the loaded state with a new auto-save.

### Web persistence path

Persistence uses Godot `user://`, which is the engine-supported storage path for desktop and Web exports.

Fresh-browser Firefox persistence is still explicitly reserved for full release QA in Slice 16/17.

## Validation

Godot 4.7.2 CI now passes:

1. project/autoload/resource validation;
2. protected hotspot and movement regression suite;
3. canonical GameState serialization round-trip;
4. JSON save-document round-trip;
5. real file write/read round-trip;
6. malformed JSON rejection;
7. future-schema rejection;
8. schema migration;
9. room-transition canonical state synchronization;
10. saved-room restoration;
11. safe player-position clamping;
12. real main-scene startup.

## Scope discipline

Slice 4 does not implement clue definitions or notebook presentation. The canonical fields required by those systems now exist, but evidence behavior remains owned by Slice 5.

## NEXT OPERATION

**Slice 5 — Evidence notebook**

Execute without requesting design decisions:

1. Implement authored clue definitions with:
   - stable clue ID;
   - title;
   - source;
   - reliability;
   - tags;
   - contradiction tags;
   - optional detail levels;
   - optional temporal provenance.
2. Implement an `EvidenceService` that:
   - acquires clues idempotently;
   - persists clue discovery in GameState;
   - upgrades clue detail without duplicating clues;
   - emits evidence-added / evidence-upgraded events;
   - returns evidence relevant to filters/context.
3. Implement Chapter One seed clue data needed to exercise the framework, without beginning full Act I content.
4. Implement the Notebook/Evidence UI with:
   - discovered evidence list;
   - selected clue detail;
   - source/reliability display;
   - basic tag/filter support;
   - keyboard access via N / E;
   - close/back behavior that returns cleanly to room play.
5. Make notebook/evidence state survive save/load through the existing GameState persistence path.
6. Add evidence acquisition and upgrade hooks that hotspots/content can call later without hardcoding notebook logic into rooms.
7. Add tests for:
   - idempotent acquisition;
   - detail upgrades;
   - serialization persistence;
   - filtering;
   - unknown clue rejection.
8. Protect all Slice 3 interaction and Slice 4 persistence regressions.
9. Run Godot validation and main-scene startup regression.
10. Update `ROADMAP.md`, `ARCHITECTURE.md`, and `CURRENT.md`.
11. Commit/push, follow CI and Web deployment to terminal status, and verify exact `main` head.

Do not start Slice 6 in the same turn unless the user explicitly asks for multiple slices.
