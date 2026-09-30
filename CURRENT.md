# Current

## Status

**Slice 8 — Light RPG layer: COMPLETE**

Phase A foundation/engine work is complete. The project now has the locked four-skill system, fixed Chapter One background selection, deterministic checks, persistent failed approaches, skill-routed evidence/dialogue behavior, and a Character panel.

## Implemented

### Locked skills

The four Chapter One skills are live:

- **Observation** — physical/visual irregularities;
- **Reasoning** — technical/documentary inference;
- **Empathy** — emotional mismatch and human routes;
- **Resolve** — pressure/evasion resistance.

Skills remain bounded to the authored Chapter One profiles rather than a point-buy system.

### Opening background choice

Starting Chapter One now opens a one-sentence background-choice panel before the game shell.

Four fixed profiles exist:

- **The Watcher** — OBS 3 / REA 2 / EMP 1 / RES 1;
- **The Analyst** — OBS 2 / REA 3 / EMP 1 / RES 1;
- **The Reader** — OBS 2 / REA 1 / EMP 3 / RES 1;
- **The Anchor** — OBS 1 / REA 2 / EMP 1 / RES 3.

The selected background ID and exact skill values become canonical GameState.

### Deterministic checks

`SkillService` now resolves authored checks with:

`skill + contextual modifier >= threshold`

Every result exposes:

- base skill;
- modifier;
- total;
- threshold;
- pass/fail;
- margin.

There are no hidden/random dice rolls.

### Failed approaches

Failed checks can be recorded canonically in `GameState.failed_approaches`.

Each entry stores:

- check ID;
- skill;
- threshold;
- last total;
- last modifier;
- context;
- attempt count.

Dialogue/content conditions can query these failures to expose authored fallback routes.

### Skill-routed seed behavior

The existing framework content now demonstrates both physical and social skill routes without beginning the full Act I content pass.

**Workstation Observation**

The packet hotspot always records the basic Impossible Timestamp clue.

An Observation 3 check can additionally recognize the same impossible time in a second packet field and upgrade the clue to detail level 2.

Failure records the attempted observation but does not remove the base clue.

**Mara Empathy**

After the timestamp clue is known, Mara has an authored Empathy 3 attempt.

Success:
- enters a distinct success node;
- gains trust;
- upgrades the timestamp clue to detail level 2.

Failure:
- enters a distinct failure node;
- records the failed approach;
- preserves progression;
- can unlock a direct paper-trail fallback route after the maintenance topic has been opened.

### Dialogue integration

Dialogue choices can now carry an explicit deterministic `skill_check`.

The choice remains player-visible. Selecting it resolves the check and then follows authored:

- success node/effects; or
- failure node/effects.

Dialogue conditions can also require recorded failed approaches.

This keeps skill failures visible and consequential rather than hiding routes behind invisible checks.

### Character panel

The lower HUD now exposes **CHAR**, and **C** opens the Character panel.

It shows:

- Her's selected background;
- the background sentence;
- all four current skill values;
- concise skill descriptions;
- recorded failed approaches.

Room interaction pauses while the Character panel is open.

### Persistence

GameState now persists:

- `background_id`;
- `skill_values`;
- `failed_approaches`.

The save content version is **ch01-slice8**.

Schema version remains **1** because the new fields normalize safely when absent from older schema-1 saves.

## Validation

Godot 4.7.2 CI passes:

1. project/autoload/resource validation;
2. all four fixed background profiles;
3. deterministic threshold pass/fail;
4. contextual modifiers;
5. failed-approach recording;
6. Observation success evidence upgrade;
7. Observation failure preservation;
8. Empathy dialogue success branch;
9. Empathy dialogue failure branch;
10. failure-conditioned alternate route;
11. alternate-route evidence acquisition;
12. RPG state serialization/persistence;
13. four-choice opening background UI;
14. protected movement/hotspot regression suite;
15. protected evidence regression suite;
16. protected deduction regression suite;
17. protected dialogue regression suite;
18. protected persistence/migration regression suite;
19. real main-scene startup.

## Scope discipline

The reusable engine layer is now complete enough to begin Chapter One assembly.

Slice 8 does not build the remaining primary locations or the full chapter flag/progression graph. Those belong to Slice 9.

## NEXT OPERATION

**Slice 9 — Chapter One content skeleton**

Execute without requesting design decisions:

1. Build greybox versions of all remaining primary Chapter One locations so the repository contains the full 9-scene route:
   - Her's room/workstation;
   - apartment corridor/building office;
   - systems archive;
   - transit concourse;
   - café;
   - records office;
   - observation overlook;
   - restricted utility room;
   - threshold site.
2. Add the three planned close-up scenes where needed:
   - workstation terminal;
   - evidence table/notebook;
   - threshold instrument panel.
3. Establish authored navigation/transitions among the primary locations without creating item-key puzzle chains.
4. Create the complete Chapter One progression/flag skeleton:
   - Act I through Act V boundaries;
   - required scene-entry flags;
   - required deduction gates;
   - final-threshold eligibility;
   - chapter-complete flag;
   - optional/deep-understanding flags reserved for later Acts.
5. Add placeholder actors/hotspots sufficient to exercise every required location and route.
6. Create a start-to-ending **greybox route** that can be traversed using placeholder progression hooks even though Acts I-V content is not yet authored.
7. Add a protected scripted progression test proving:
   - all required locations load;
   - all transitions resolve;
   - the chapter flag graph can advance from fresh state to the threshold ending skeleton;
   - no scene in the required route is orphaned.
8. Preserve all Phase A systems and tests.
9. Keep the skeleton content clearly separated from later Act-specific prose/evidence so Slices 10-14 can fill it without architectural rewrites.
10. Run Godot validation and main-scene startup regression.
11. Update `ROADMAP.md`, `ARCHITECTURE.md`, and `CURRENT.md`.
12. Commit/push, follow CI and Web deployment to terminal status, and verify exact `main` head.

Do not start Slice 10 in the same turn unless the user explicitly asks for multiple slices.
