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
    demo/
    ch01/
  content/
    demo/
    ch01/
      clues/
      deductions/
      dialogue/
      rooms/
  art/
    demo/
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
- opened dialogue topics;
- consumed/once-only dialogue reactions;
- chapter flags;
- selected background ID;
- skill values;
- failed approaches;
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

`EvidenceService` is an autoload backed by authored Chapter One clue definitions under `content/ch01/clues/`.

Each clue definition provides:
- stable ID;
- title;
- source;
- reliability;
- tags;
- contradiction tags;
- one or more detail levels;
- optional temporal provenance.

The canonical discovery state remains in `GameState.clues`; the service does not duplicate story state. Each discovered entry currently stores its highest detail level plus acquisition playtime.

Responsibilities:
- reject unknown clue IDs;
- acquire clues idempotently;
- upgrade detail levels without duplicate entries;
- merge authored definitions with canonical discovery state for presentation;
- filter discovered evidence by tag;
- expose discovered tag values;
- emit evidence-added, evidence-upgraded, and evidence-changed events.

The notebook UI reads only through EvidenceService.

### DeductionService

`DeductionService` is an autoload backed by authored Chapter One deduction definitions under `content/ch01/deductions/`.

Each deduction definition can declare:
- stable deduction ID;
- title and description;
- required clue IDs;
- required evidence tags;
- minimum support count;
- prerequisite deductions;
- evidence-tag refutation conditions;
- contradiction-tag refutation conditions;
- optional skill-insight metadata.

Evaluation is deterministic and returns one of:

- `unsupported` — current discovered evidence/prerequisites are insufficient;
- `supported` — current discovered evidence satisfies the authored rule, but the player has not yet committed to the conclusion;
- `established` — the player selected the hypothesis while the rule was supported;
- `refuted` — discovered evidence currently matches an authored refutation condition.

Only discovered evidence IDs are returned as visible support/contradictions. Missing or undiscovered clue identities are never exposed by the evaluator.

Player hypothesis selections persist in `GameState.hypotheses`, including unsupported/refuted guesses. Established deductions persist in `GameState.deductions`. Re-selecting an already established deduction is idempotent.

Establishing a deduction triggers the existing autosave path.

The service never guesses deductions from free text.

### DialogueService

`DialogueService` is an autoload backed by authored witness definitions under `content/ch01/dialogue/`.

Each witness definition provides:
- stable witness ID and display identity;
- start node;
- graph nodes with authored witness lines;
- player choices/topics;
- conditional visibility;
- terminal choices;
- once-only choice reactions;
- evidence reactions keyed by clue IDs and/or evidence tags.

Conditions can inspect:
- discovered clue IDs;
- established deductions;
- selected hypotheses;
- witness trust thresholds;
- chapter flag values;
- skill thresholds;
- opened topics;
- unseen reactions.

Effects can:
- acquire/upgrade evidence through EvidenceService;
- change or set witness trust;
- set chapter flags;
- open topics;
- record once-only reactions.

Canonical dialogue state lives in GameState:
- `witness_trust`;
- `dialogue_topics`;
- `dialogue_reactions`;
- ordinary `chapter_flags`.

Active conversation node position is intentionally ephemeral; closing/reopening a witness begins from the authored start node while all investigation consequences remain persistent.

Evidence presentation is filtered. The UI receives only discovered evidence for which that witness currently has an eligible authored reaction. Once-only evidence reactions are removed from the presentable list after consumption.

The service never performs generic clue-on-NPC matching or free-text inference.

Dialogue choices may also declare a deterministic `skill_check`. The choice remains visible; selecting it resolves through SkillService. Authored success/failure nodes and effects then determine the route. Failed checks can therefore expose alternate topics instead of disappearing behind invisible gates.

### SkillService

`SkillService` is an autoload and owns the light-RPG rule layer.

Locked skills:
- Observation;
- Reasoning;
- Empathy;
- Resolve.

Chapter One begins with one of four fixed authored backgrounds:

- **The Watcher** — Observation 3, Reasoning 2, Empathy 1, Resolve 1;
- **The Analyst** — Observation 2, Reasoning 3, Empathy 1, Resolve 1;
- **The Reader** — Observation 2, Reasoning 1, Empathy 3, Resolve 1;
- **The Anchor** — Observation 1, Reasoning 2, Empathy 1, Resolve 3.

There is no point-buy screen.

Checks are deterministic:

`skill value + contextual modifier >= authored threshold`

The service returns the explicit base value, modifier, total, threshold, pass/fail result, and margin. It never rolls random numbers.

Failed authored approaches can be recorded in `GameState.failed_approaches` with check ID, skill, last total, threshold, modifier, context, and attempt count. Content can condition alternate routes on that persistent failure state.

Background application writes both `background_id` and the fixed skill profile into GameState.

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

The game shell currently exposes manual slot 1 through simple **SAVE** / **LOAD** controls; the service already supports the remaining manual slots for later UI expansion. The content version is now **ch01-slice8**; the save schema remains version 1 because background and failed-approach state are normalized optional GameState fields and older schema-1 saves default them safely.

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
- optional evidence ID + evidence detail level;
- optional witness ID;
- optional deterministic skill-check metadata;
- optional skill-success evidence/detail upgrade;
- optional destination room + destination spawn;
- enabled/disabled state.

Hotspots emit primary/inspect actions and hover changes. Evidence-bearing primary actions delegate acquisition to EvidenceService through the room controller. Witness-bearing primary actions emit a generic conversation request consumed by the game shell/ConversationUI. Hotspots never mutate GameState directly.

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


## Umbrella Quest vertical-slice contract

Before Chapter One content production resumes, the non-canon Umbrella Quest must prove the final gameplay and presentation language.

It is allowed to use separate demo-local state/content where that protects canon-state isolation, but reusable systems should continue to use the same interaction, notebook, dialogue, RPG, persistence, and later combat contracts intended for Chapter One.

### Visual architecture

`VISUAL_DIRECTION.md` is authoritative for:
- room composition;
- palette;
- lighting;
- sprite/portrait language;
- UI skin;
- dialogue/notebook presentation;
- later combat presentation.

The visual pipeline favors static 2D illustrated assets, SVG/texture-based authored elements, and lightweight Godot UI styling compatible with Web export. It must not require dynamic 3D, compute shaders, or heavy runtime effects.

The current reference room stores authored illustrations as SVG files under `art/demo/`. Those SVGs are referenced directly by the Godot scene as `Texture2D` resources. Godot's normal import pipeline rasterizes them into engine texture resources and the Web exporter packages those imported resources into the PCK.

Do **not** use `FileAccess` to load visual source files by path at runtime. The first Slice 9 deployment did that and the browser build omitted the unreferenced source files, producing a blank world while the UI still rendered.

CI now runs Godot's import-completion pass before resource tests. The Pages workflow also checks the exported PCK for the three required Umbrella reference-art resource names before deployment.

The reusable UI skin lives at `ui/theme/comic_noir_theme.tres` and is applied to the Umbrella Quest reference scene.


### Umbrella multi-room runtime

Slice 10 expands the non-canon vertical slice into eight separately authored room scenes under `rooms/demo/`:

1. exterior entry / awning;
2. lobby;
3. front desk;
4. Lost & Found hall;
5. staff office;
6. storage room;
7. maintenance corridor;
8. loading bay / service exit.

The persistent `ui/demo/ui_demo.tscn` shell owns the noir HUD, notebook, character panel, dialogue panel, and demo-local investigation state. Its `RoomHost` swaps one demo room scene at a time.

Each demo room uses `rooms/demo/demo_room.gd` and reuses the production interaction primitives:

- `AdventurePlayerActor` for click-to-walk movement;
- `AdventureHotspot` for hover, inspect, primary actions, approach points, witness IDs, and transition metadata;
- authored walk bounds;
- named destination spawn markers;
- direct imported `Texture2D` background art.

The demo room controller emits room-local signals for:

- status feedback;
- hover labels;
- witness conversation requests;
- ordinary hotspot activation;
- transitions.

Demo transitions intentionally do **not** call the canonical `SceneRouter`. The shell resolves the target demo scene and spawn marker locally, preserving strict isolation from Chapter One `GameState`.

The demo-local in-memory save snapshot now includes current demo room path and player foot position in addition to evidence/trust state. Loading restores the saved room and safe player position without touching canonical save slots.

The Slice 10 graph is deliberately interconnected rather than linear. The lobby branches toward reception and Lost & Found, the service rooms cross-connect through maintenance, and the loading bay loops back to the exterior.

A protected `demo_world_smoke.gd` test verifies:

- all eight room scenes load;
- each room has imported background art, shared player visuals, and representative hotspots;
- every transition target belongs to the demo graph;
- every transition spawn exists in the destination scene;
- every room has an outgoing route;
- the entire graph is reachable from the lobby.


### Umbrella investigation runtime

Slice 11 turns the multi-room demo into a complete non-canon investigation while preserving canon isolation.

Authored case content lives in `content/demo/umbrella_case.gd` and supplies:

- clue definitions;
- deduction definitions;
- witness identity/presentation data.

The persistent Umbrella shell owns demo-local case state:

- discovered evidence;
- established deductions;
- selected hypotheses;
- witness trust;
- case-resolution state;
- in-memory demo save snapshot.

It does not write these values into Chapter One `GameState`, `EvidenceService`, `DeductionService`, `DialogueService`, or canonical save slots.

The demo deduction evaluator deliberately mirrors the production deduction contract:

- authored required clue IDs;
- minimum visible support;
- prerequisite deductions;
- refuting evidence tags;
- refuting contradiction tags;
- explicit player hypothesis selection;
- `unsupported`, `supported`, `established`, and `refuted` states.

Only discovered support/contradiction evidence is shown in the notebook. Later case conclusions become visible only after their prerequisite conclusion is established.

The current Umbrella deduction chain is:

1. Ticket 47B is Nora Vale's umbrella.
2. The umbrella moved from the lobby to Lost & Found.
3. Cabinet B was only an intermediate stop.
4. Mina carried 47B through the service route.
5. The umbrella was moved to dry, not stolen.

Two intentionally bad hypotheses remain selectable and can later become refuted.

Demo witness interaction now supports Alex and Mina Reyes. Both use topic dialogue plus evidence presentation. Evidence shown to a witness can add witness-backed evidence or clarify motive, matching the production conversation grammar without touching canonical dialogue state.

Critical case conclusions have alternate support where practical. In particular, the service-route deduction can be established from documentary/physical evidence without Mina's admission, and the drying conclusion can be established from policy + physical endpoint evidence without requiring a single dialogue route.

The final deduction does not immediately end the quest. It changes the objective to the loading-bay drying rail. Interacting with that endpoint records recovery evidence and opens a case-closed panel, proving the investigation can resolve through world interaction after notebook reasoning.

The demo-local save snapshot now includes:

- current room;
- safe player foot position;
- discovered case evidence;
- established deductions;
- selected hypotheses;
- per-witness trust;
- case-resolution state.

A protected `umbrella_case_smoke.gd` test covers:

- fresh-case initialization;
- witness-assisted progression;
- evidence presentation;
- the complete five-deduction chain;
- alternate documentary/physical progression;
- bad-hypothesis refutation;
- final case resolution;
- canon-state isolation.
