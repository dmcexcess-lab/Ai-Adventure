# Architecture

## Technology target

- Godot 4.x stable.
- GDScript.
- Web export using the compatibility renderer.
- Firefox desktop is the primary browser target.
- No native-only plugin may be required for Chapter One.
- No external backend is required to play.
- Save data uses Godot user storage/local browser persistence.

## Project shape

```
res://
  autoload/
    game_state.gd
    save_service.gd
    content_db.gd
    scene_router.gd
  core/
    interaction/
    dialogue/
    evidence/
    deductions/
    rpg/
    persistence/
  ui/
    hud/
    notebook/
    dialogue/
    menus/
  rooms/
    ch01/
  content/
    ch01/
      clues/
      deductions/
      dialogue/
      rooms/
  art/
  audio/
  tests/
```

## Authoring model

Content is data-driven, but only where that lowers chapter-authoring cost.

Use Godot Resources or JSON-like dictionaries for:
- clue definitions;
- deduction definitions;
- dialogue nodes;
- hotspot metadata;
- room transitions.

Do **not** build a general-purpose visual scripting language.

## Core runtime services

### GameState

Owns the canonical serializable state:
- current room path and room ID;
- spawn-safe player foot position;
- clues;
- deductions;
- hypotheses;
- witness trust;
- chapter flags;
- skill values;
- inventory;
- visited locations;
- playtime.

The service exposes normalized dictionary serialization so later evidence/dialogue/RPG systems add data without making room scenes authoritative.

No room scene is allowed to be the sole owner of critical story state.

### SceneRouter

Handles:
- room changes;
- transition locks;
- spawn markers;
- canonical room/player-position synchronization;
- save restoration;
- auto-save hooks.

Room loads update GameState only after the new room is instantiated and positioned. Save restoration can provide an explicit player foot position; the room contract clamps that position to its valid walk bounds before play resumes.

### InteractionController

Normalizes mouse input into:
- walk;
- inspect;
- interact;
- talk;
- present evidence;
- transition.

Hotspots declare allowed contextual actions.

### EvidenceService

Responsibilities:
- register clue acquisition;
- merge upgraded clue detail;
- surface relevant evidence for current context;
- publish evidence-added events.

### DeductionService

Evaluates authored deduction rules against canonical state.

Rules are declarative:
- required clue IDs;
- minimum support count;
- exclusion/contradiction conditions;
- prerequisite deductions;
- optional skill insight.

The service never guesses deductions from free text.

### DialogueService

Runs graph-based authored conversations.

Node conditions can inspect:
- clue/deduction state;
- trust;
- skills;
- chapter flags.

Node effects can:
- add clue;
- change trust;
- set flag;
- open topic;
- transition conversation.

### SaveService

Versioned JSON save schema stored under Godot `user://`.

Current schema fields:
- `schema_version`;
- `content_version`;
- `saved_at_unix`;
- canonical `state` payload from GameState.

Supported slots:
- `manual_1`;
- `manual_2`;
- `manual_3`;
- `autosave`.

The game shell currently exposes manual slot 1 through simple **SAVE** / **LOAD** controls; the service already supports the remaining manual slots for later UI expansion.

SaveService responsibilities:
- validate slot names;
- capture current room/player state before writes;
- serialize/deserialize JSON;
- reject malformed or future-version saves;
- migrate older schema versions;
- apply GameState;
- ask SceneRouter to restore the saved room and safe player position.

Auto-save runs after successful room entry. Loading does not immediately overwrite the loaded save with another auto-save.

Godot `user://` is used so the same implementation targets desktop files and browser-backed Web persistence. Fresh-browser Firefox persistence remains part of release QA before Chapter One is called done.

## Room contract

Every room is a Godot scene implementing a small common interface.

Required child concepts:
- visual background;
- simple authored walk bounds;
- `PlayerActor`;
- `Hotspots` container;
- optional NPC actors;
- named spawn markers for transitions.

The reusable Slice 3 room controller owns:
- click-to-walk dispatch;
- movement clamping to walk bounds;
- hotspot registration;
- approach-before-primary-action behavior;
- inspect dispatch;
- held hotspot reveal;
- transition requests through `SceneRouter`;
- status/hover signals to the shell HUD.

Rooms do not hardcode cross-chapter systems.

### Hotspot contract

A hotspot declares:
- stable `hotspot_id`;
- player-facing label;
- inspect text;
- primary-action feedback;
- optional approach point;
- optional destination room + destination spawn;
- enabled/disabled state.

Hotspots emit primary/inspect actions and hover changes. They do not own case-state logic.

## Movement

Point-and-click destination movement uses a lightweight visual actor. Destinations are clamped to an authored per-room `Rect2` walk region.

This is intentionally simpler than general pathfinding for the current room layouts. NavigationRegion2D remains available if a later authored room genuinely needs obstacle routing; it is not required by default.

## Testing strategy

### Fast script tests

Headless tests cover:
- clue acquisition idempotence;
- deduction rules;
- dialogue conditions/effects;
- save serialize/deserialize;
- migration behavior.

### Protected progression tests

A scripted Chapter One golden path validates:
- every required deduction can be reached;
- all scene transitions resolve;
- the chapter ending is reachable from a fresh save.

A second route intentionally misses optional clues and uses alternate critical-clue paths.

### Web smoke

For release slices:
- export web build;
- serve locally or via Pages;
- load in Firefox;
- new game;
- one room transition;
- notebook open/close;
- save/load;
- audio unlock after user gesture;
- chapter completion path on final release.

## Performance budget

The project should remain modest enough for ordinary desktop Firefox:
- static 2D backgrounds;
- small sprite animation sets;
- no dynamic 3D;
- no compute shaders;
- no large runtime-generated textures;
- no continuous simulation outside the active room.

## Git discipline

- Main remains playable after implementation slices once the first playable scaffold exists.
- Every slice updates `CURRENT.md`.
- Do not expand scope during implementation unless a concrete blocker demands it.
