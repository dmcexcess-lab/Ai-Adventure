# Current

## Status

**Slice 2 — Godot web bootstrap: COMPLETE**

Chapter One now has a verified Godot runtime scaffold rather than only design documents.

## Implemented

- Godot 4.7.2 stable project.
- 640x480 internal canvas with 4:3 presentation.
- Compatibility renderer for WebGL 2 browser export.
- Single-threaded Web export preset for broad Firefox/static-host compatibility.
- Main menu for **ANAMNESIS: The Third Witness**.
- Game shell with persistent lower status strip.
- SceneRouter autoload.
- Temporary Chapter One workstation room.
- Runtime input actions:
  - left click: primary interaction;
  - right click: inspect;
  - N: notebook;
  - E: evidence;
  - C: character;
  - Space: reveal hotspots;
  - Escape: return/menu.
- Repository folder skeleton from `ARCHITECTURE.md`.
- Automated Godot smoke test.
- Main-scene startup test.
- GitHub Pages Web export/deployment workflow.

## Validation

Pull request validation ran against Godot 4.7.2 stable and completed successfully.

Protected bootstrap checks passed:

1. project settings load;
2. required scripts/scenes load;
3. viewport is 640x480;
4. Compatibility renderer is active;
5. SceneRouter autoload exists;
6. the real main scene starts successfully in headless Godot.

## Scope discipline

Slice 2 intentionally does **not** implement evidence, deductions, dialogue, saves, RPG checks, or Chapter One investigation content. Those remain in their recorded slices.

## NEXT OPERATION

**Slice 3 — Interaction and room framework**

Execute without requesting design decisions:

1. Replace the temporary noninteractive-room behavior with the reusable point-and-click room contract.
2. Implement click-to-walk player movement inside room walk bounds/navigation.
3. Implement reusable hotspots with:
   - hover label;
   - primary contextual action;
   - right-click inspect;
   - enabled/disabled state.
4. Implement room transitions through SceneRouter.
5. Add interaction/status feedback in the lower HUD.
6. Implement Space-held hotspot reveal without exposing puzzle solutions.
7. Create at least two linked test rooms so movement and transition behavior are exercised end-to-end.
8. Add automated tests/smoke coverage for hotspot action dispatch and room changes where practical.
9. Run Godot validation and protected startup regression.
10. Update `ROADMAP.md` and `CURRENT.md`.
11. Commit/push and verify exact `main` head.

Do not start Slice 4 in the same turn unless the user explicitly asks for multiple slices.
