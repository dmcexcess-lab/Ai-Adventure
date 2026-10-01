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


### Umbrella RPG runtime

Slice 12 applies the production four-skill/background model directly to the non-canon Umbrella Quest while preserving Chapter One state isolation.

Umbrella Quest now begins with a blocking local background choice using the same four profiles exposed by `SkillService`:

- **The Watcher** — Observation 3, Reasoning 2, Empathy 1, Resolve 1;
- **The Analyst** — Observation 2, Reasoning 3, Empathy 1, Resolve 1;
- **The Reader** — Observation 2, Reasoning 1, Empathy 3, Resolve 1;
- **The Anchor** — Observation 1, Reasoning 2, Empathy 1, Resolve 3.

The demo copies the selected profile into local Umbrella state. It never calls `SkillService.apply_background()`, so canonical `GameState.background_id`, canonical skill values, and canonical failed approaches are untouched.

`SkillService` now exposes a pure `evaluate_values(skill_values, skill_id, threshold, modifier)` helper. Canonical `evaluate_check()` delegates to the same helper, allowing sandbox/local content to use exactly the same deterministic rule without temporarily mutating GameState.

The rule remains:

`base skill + contextual modifier >= authored threshold`

Umbrella skill checks store explicit:

- check ID;
- skill;
- base value;
- contextual modifier;
- total;
- threshold;
- pass/fail;
- context;
- fallback hint.

Failed approaches persist in demo-local state with attempt count and remain visible in the Character panel.

The current representative routes are:

1. **Observation / Watcher**
   - rack-residue check;
   - threshold 3;
   - success discovers `watcher_transfer_residue`;
   - the extra physical evidence can replace a witness/documentary support item in the first-transfer deduction.
2. **Reasoning / Analyst**
   - rear-fan timing reconstruction;
   - threshold 4;
   - closing-log context supplies +1;
   - the same deterministic check can therefore visibly fail at 3/4, direct the player toward a timing anchor, then pass at 4/4 after that context is found;
   - success discovers `analyst_service_timing`.
3. **Empathy / Reader**
   - Mina protective-tell read;
   - threshold 3;
   - success discovers `reader_protective_tell` and a motive-oriented route toward the drying explanation.
4. **Resolve / Anchor**
   - direct challenge for Mina's exact physical route;
   - threshold 3;
   - success discovers both Mina's ordinary second-transfer statement and `anchor_exact_route`;
   - this creates a faster witness route through the service-movement deduction.

Failures do not dead-end the case. Every failed representative check records an authored fallback such as:

- use the paper record / Alex instead of the rack read;
- find the front-desk closing log, transfer tag, or Mina instead of relying on the fan timer alone;
- ask about policy or present physical evidence after a failed Empathy read;
- reconstruct the route from records and traces after a failed Resolve challenge.

The Slice 11 universal non-skill route remains fully valid for every background.

The Umbrella Character panel now reflects:

- selected background title;
- authored background sentence;
- all four current skill values;
- production skill descriptions;
- recorded failed approaches and fallback hints.

The demo-local save snapshot now additionally preserves:

- Umbrella background ID;
- Umbrella skill values;
- failed approaches;
- last skill-check results.

A protected `umbrella_rpg_smoke.gd` test verifies:

- all four fixed profiles;
- deterministic threshold behavior;
- contextual modifiers;
- each representative skill route;
- failed-route fallback recording;
- Analyst fail-then-context-then-pass behavior;
- universal case solvability under every background;
- RPG-aware demo save/load;
- canonical background/skill/failure isolation.


### Umbrella bounded-combat runtime

Slice 13 proves the representative combat grammar without turning investigation into a combat loop.

The reusable deterministic resolver lives at `core/combat/bounded_combat.gd`. It is a plain `RefCounted` object rather than an autoload. It owns no canonical state and accepts:

- one authored encounter definition;
- the current four RPG skill values.

Umbrella Quest keeps the resulting encounter state local to the demo shell.

The current authored encounter lives in `content/demo/umbrella_combat.gd` and triggers in the existing loading bay only after the required `mina_service_route` deduction is established.

Combat never changes scenes. The loading-bay background, player staging, and investigation shell remain visible. A comic-noir overlay adds the opponent silhouette, condition readouts, intent preview, combat log, and four actions.

The locked representative action grammar is:

1. **Strike**
   - base damage is authored;
   - Resolve 3 grants a surfaced +1 direct-action bonus;
   - one point of existing leverage may be spent for +1 damage.
2. **Guard**
   - grants an authored block value for the next opponent action;
   - Resolve 3 grants +1 additional block.
3. **Maneuver**
   - creates leverage;
   - the strongest of Observation / Reasoning / Empathy is named explicitly;
   - skill 3 in that strongest non-Resolve skill grants +1 additional leverage;
   - the maneuver also provides one point of immediate guard.
4. **Disengage**
   - resolves as `Resolve + current leverage >= 3`;
   - success ends the encounter without victory;
   - failure consumes the player's action and allows the opponent's surfaced response.

There is no random roll.

Opponent behavior is an authored repeating intent sequence. The UI shows the next intent and its raw damage before the player commits:

- RUSH — 3;
- FLASHLIGHT SWING — 2;
- SHOVE — 2.

Every resolution records readable math in the combat log, including:

- player base values;
- RPG-derived bonuses;
- leverage gained/spent;
- guard;
- raw incoming damage;
- damage after guard;
- disengage threshold math.

Combat condition is intentionally local and bounded:

- player condition: 8;
- opponent condition: 6.

The encounter has three terminal outcomes:

- `victory`;
- `disengaged`;
- `forced_disengage`.

Dropping to zero condition does **not** produce a game-over. The player is forced back into investigation with the authored `bruised_ribs` consequence recorded in demo-local state and shown on the Character panel. The umbrella case remains completable.

Completed combat never retriggers on later loading-bay entries unless an earlier safe snapshot from before the encounter is deliberately restored.

Save/load safety:

- local SAVE is rejected while combat is active;
- local LOAD is rejected while combat is active;
- active half-resolved combat is never serialized;
- after an encounter ends, safe snapshots preserve only the completed outcome/consequence plus the existing investigation/RPG state;
- restoring a completed outcome never reopens the encounter.

The UI shell remains the owner of demo combat state, so canonical Chapter One GameState is untouched.

A protected `umbrella_combat_smoke.gd` test verifies:

- authored trigger timing;
- exact four-action availability;
- deterministic condition values;
- surfaced Strike + Resolve math;
- surfaced opponent damage;
- victory;
- RPG-assisted Maneuver leverage;
- deterministic disengage;
- forced-disengage consequence;
- unsafe-save rejection during combat;
- safe post-combat persistence;
- no completed-encounter retrigger;
- case completion after combat consequence;
- canon-state isolation.
