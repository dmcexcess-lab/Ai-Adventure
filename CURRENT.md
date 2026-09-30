# Current

## Status

**Slice 3 — Interaction and room framework: COMPLETE**

The project now has a reusable adventure-room interaction layer and a playable two-room traversal scaffold.

## Implemented

### Point-and-click movement

- Reusable visual player actor.
- Left-click floor movement.
- Per-room authored walk bounds.
- Destination clamping prevents walking outside the playable floor.
- Movement is lightweight and Web-friendly.
- A new click cancels any pending approach/action.

### Hotspots

Reusable hotspot contract now supports:

- stable hotspot ID;
- hover label;
- left-click primary action;
- right-click inspect;
- enabled/disabled state;
- authored approach point;
- optional room transition target;
- optional destination spawn marker;
- held reveal visualization.

Primary hotspot actions can require the actor to approach first. A later player command cancels the pending action rather than allowing stale actions to fire after movement changes.

### Room contract

Reusable room controller now owns:

- walk input;
- hotspot registration;
- approach/action sequencing;
- inspect dispatch;
- hotspot reveal propagation;
- room-status events;
- hover/context events;
- transition handoff to SceneRouter.

### Scene routing

SceneRouter now:

- exposes the current room;
- supports destination spawn markers;
- cleanly replaces the active room;
- emits the new room instance with room-change events.

### HUD

The lower interface now has separate:

- current context / hovered hotspot;
- interaction feedback / inspection text.

Holding **Space** reveals interactable regions without revealing what puzzle conclusion they support.

### Linked test locations

The Chapter One scaffold now contains two traversable rooms:

1. **Her's Workstation**
   - workstation hotspot;
   - window hotspot;
   - hall-door transition.
2. **Apartment Corridor**
   - return-door transition;
   - intercom hotspot;
   - building-office hotspot.

This is still framework/greybox material. Final Chapter One investigation content remains in the later content slices.

## Validation

Godot 4.7.2 CI passes:

1. project settings;
2. all core scripts compile and instantiate;
3. required scenes load;
4. hotspot primary/inspect dispatch;
5. disabled-hotspot suppression;
6. hotspot reveal propagation;
7. walk-bound clamping;
8. linked-room targets load in both directions;
9. real main-scene startup.

The test harness was hardened during this slice so script compile failures now fail CI rather than only printing Godot errors.

## NEXT OPERATION

**Slice 4 — Canonical state and persistence**

Execute without requesting design decisions:

1. Implement the canonical `GameState` service for:
   - current room;
   - clues;
   - deductions;
   - hypotheses;
   - witness trust;
   - chapter flags;
   - skill values;
   - inventory;
   - playtime.
2. Make room transitions update canonical current-room state rather than relying on scene-local state.
3. Implement a versioned save schema with:
   - schema version;
   - content version;
   - manual slots;
   - auto-save slot;
   - migration hook.
4. Implement save/load persistence using Godot user storage compatible with Web export.
5. Add minimal Save/Load UI reachable from the game shell.
6. Auto-save on room transition.
7. Restore the correct room and spawn-safe player state after loading.
8. Add serialization, round-trip, invalid-save, and migration tests.
9. Protect the existing movement/hotspot/room-transition tests.
10. Run Godot validation and main-scene startup regression.
11. Update `ROADMAP.md`, `ARCHITECTURE.md`, and `CURRENT.md`.
12. Commit/push, follow CI and Web deployment to terminal status, and verify exact `main` head.

Do not start Slice 5 in the same turn unless the user explicitly asks for multiple slices.
