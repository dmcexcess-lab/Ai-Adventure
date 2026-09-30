# Current

## Status

**Umbrella Quest Slice 12 — RPG integration: COMPLETE**

Chapter One production remains paused.

Umbrella Quest now exercises the complete investigation + light-RPG grammar intended for the finished game before combat is added.

## Opening background choice

Starting Umbrella Quest now presents a blocking four-choice approach screen.

The choices are the same fixed profiles used by Chapter One:

1. **The Watcher**
   - Observation 3
   - Reasoning 2
   - Empathy 1
   - Resolve 1
   - “I notice what everyone else edits out.”
2. **The Analyst**
   - Observation 2
   - Reasoning 3
   - Empathy 1
   - Resolve 1
   - “I trust the structure before the story.”
3. **The Reader**
   - Observation 2
   - Reasoning 1
   - Empathy 3
   - Resolve 1
   - “People tell me more than they mean to.”
4. **The Anchor**
   - Observation 1
   - Reasoning 2
   - Empathy 1
   - Resolve 3
   - “When something pushes back, I keep going.”

There is no point allocation.

This selection is Umbrella-local and does not mutate the canonical Chapter One background or skills.

## Deterministic skill rule

Umbrella Quest now uses the same deterministic math as the production RPG service:

**skill value + contextual modifier >= authored threshold**

The player receives the actual calculation in the feedback:

- skill;
- base value;
- modifier;
- total;
- threshold;
- PASS / FAIL.

There are no hidden rolls.

`SkillService` now exposes a pure local-value evaluator so sandbox/demo content can use the exact production math without borrowing or mutating canonical GameState.

## Observation route — The Watcher

Interacting with the wet lobby umbrella rack now attempts:

**Observation 3**

Success reads a subtle adhesive filament + scuff direction and records:

**Transfer Residue at the Rack**

That extra physical evidence supports the first-transfer deduction and can reduce dependence on Alex / the closing log.

Failure still records the ordinary dry-rack evidence and explicitly redirects the player toward the paper record or Alex.

## Reasoning route — The Analyst

Inspecting the maintenance fan timing attempts:

**Reasoning 4**

The rear timer by itself is underdetermined.

If the player has already found the front-desk closing log, that independent timing anchor supplies:

**+1 contextual modifier**

This produces a visible fail/recover pattern for The Analyst:

- 3 + 0 = 3 / 4 // FAIL
- find closing log;
- 3 + 1 = 4 / 4 // PASS

Success records:

**Service Timing Reconstruction**

That evidence supports Mina's service-route deduction and can replace the storage-tag/witness route.

Other backgrounds can still use the normal Slice 11 evidence chain.

## Empathy route — The Reader

Once Mina becomes relevant, conversation can expose:

**[EMPATHY 3] You're worried about the paperwork, not the accusation.**

Reader success identifies that Mina reacts to damage to files and donation cartons before she reacts to the theft implication.

Success records:

**Mina's Protective Tell**

This becomes motive/drying evidence and gives a human shortcut toward the final explanation.

Failure makes Mina close off but explicitly preserves fallback routes through policy questions and physical evidence.

## Resolve route — The Anchor

Mina can also be challenged with:

**[RESOLVE 3] No procedure. Give me the exact route.**

Anchor success gets Mina to stop hedging and state:

**Cabinet B → storage cart → maintenance corridor → rear drying rail**

Success records:

- Mina's ordinary second-transfer statement;
- **Mina's Exact Service Route**.

This creates a direct witness-supported shortcut through the service-route deduction.

Failure costs trust and redirects the player toward the shift board, transfer tag, fan timer, and evidence presentation.

## Failed approaches

Umbrella Quest now keeps demo-local failed-approach state.

Each failed approach records:

- check ID;
- skill;
- last total;
- modifier;
- threshold;
- context;
- attempts;
- authored fallback hint.

The Character panel displays these failures and their fallback routes.

A deterministic failure therefore changes the investigation instead of silently hiding content or creating a dead end.

## Character panel

The Character panel is no longer a placeholder test profile.

It now shows:

- selected background;
- authored sentence;
- all four real skill values;
- real production skill descriptions;
- failed approaches;
- fallback guidance.

## Universal solvability

The complete Slice 11 non-skill investigation remains available.

All four backgrounds can still solve the umbrella case through ordinary evidence:

- Ticket 47B;
- rack / closing-log evidence;
- Cabinet B trace;
- shift board + transfer tag;
- wet-property policy + drying rail.

Skill success changes the route; it does not determine whether the game can be completed.

## Demo persistence

The local Umbrella snapshot now preserves:

- current room;
- player position;
- evidence;
- deductions;
- hypotheses;
- witness trust;
- case-resolution state;
- selected Umbrella background;
- all four Umbrella skill values;
- failed approaches;
- last skill-check results.

Canonical Chapter One saves remain untouched.

## Validation

Godot 4.7.2 CI now protects:

1. all four Umbrella background profiles;
2. exact fixed skill values;
3. pure deterministic local-value checks through SkillService;
4. Observation success route;
5. Reasoning fail-without-context route;
6. Reasoning +1 contextual modifier recovery;
7. Empathy success route;
8. Resolve success route;
9. failed-approach math + fallback recording;
10. RPG-aware local save/load;
11. full universal case completion under every background;
12. canonical background isolation;
13. canonical skill isolation;
14. canonical failed-approach isolation;
15. all Slice 11 investigation paths;
16. all eight-room navigation;
17. all prior canonical interaction/evidence/deduction/dialogue/RPG/persistence regressions;
18. real main-scene startup.

## NEXT OPERATION

**Umbrella Quest Slice 13 — Combat slice**

Execute without requesting design decisions:

1. Preserve the complete Slice 12 investigation and all four RPG routes.
2. Add one compact, authored combat encounter that proves the finished game's bounded combat grammar without turning Umbrella Quest into a combat game.
3. Stage the encounter inside the existing comic-noir exploration presentation rather than switching to an unrelated JRPG/arcade screen.
4. Use the loading-bay / service-exit area as the representative combat location unless current implementation constraints clearly favor another existing room.
5. Trigger combat from an authored world-state event after enough of the umbrella investigation has progressed that combat can return cleanly to investigation.
6. Implement a finite combat state with:
   - player and opponent condition/health;
   - a small readable action set;
   - explicit turn/order feedback;
   - deterministic or fully surfaced resolution math;
   - no hidden random dice unless the repository explicitly introduces and documents them in this slice.
7. Keep the action set compact and production-oriented. Senior default:
   - Strike / direct action;
   - Guard / reduce or prevent incoming harm;
   - Maneuver / positional or leverage action;
   - Disengage / attempt to end the encounter.
8. Let existing RPG skills influence authored combat options or consequences where appropriate, but do not create a separate combat-stat progression system.
9. Failure must create a consequence rather than an arbitrary game-over:
   - injury / pressure / lost leverage;
   - forced disengagement;
   - altered witness or investigation state;
   - or another bounded authored consequence.
10. Victory, disengagement, and failure/consequence paths must all return to the existing room/investigation shell.
11. Add combat UI using the established comic-noir skin and 640x480 constraints.
12. Keep combat state demo-local and isolated from canonical Chapter One state until the production combat contract is proven.
13. Preserve save/load safety outside active combat. Do not allow a local save snapshot to restore into an invalid half-resolved encounter.
14. Protect with tests proving:
   - encounter trigger;
   - action availability;
   - deterministic/surfaced resolution;
   - victory path;
   - disengage path;
   - failure/consequence path;
   - clean return to investigation;
   - RPG interaction where authored;
   - case remains completable;
   - canon-state isolation;
   - all Slice 9-12 regressions.
15. Run all existing regressions and main-scene startup.
16. Update `ROADMAP.md`, `ARCHITECTURE.md`, and `CURRENT.md`.
17. Commit/push, follow CI and Web deployment to terminal status, and verify exact `main` head.

Do not start Slice 14 in the same turn unless the user explicitly asks for multiple slices.
