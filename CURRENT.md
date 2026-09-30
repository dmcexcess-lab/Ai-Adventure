# Current

## Status

**Slice 6 — Deduction engine: COMPLETE**

The investigation loop now supports authored hypotheses, rule-based support/refutation, persistent player conclusions, and established deductions inside the existing case notebook.

## Implemented

### Authored deduction definitions

Chapter One deduction rules now live under `content/ch01/deductions/`.

Definitions support:

- stable deduction ID;
- title;
- description;
- required clue IDs;
- required evidence tags;
- minimum support count;
- prerequisite deductions;
- refuting evidence tags;
- refuting contradiction tags;
- optional skill-insight metadata.

The seed set exercises the framework without beginning full Act I content.

### DeductionService

`DeductionService` is now an autoload.

It evaluates authored rules against discovered evidence and canonical GameState only.

Evaluation states are:

- **unsupported** — insufficient discovered support and/or unmet prerequisites;
- **supported** — the authored rule is satisfied, but the player has not yet committed to it;
- **established** — the player selected the hypothesis while it was supported;
- **refuted** — discovered evidence matches an authored refutation condition.

The service never generates conclusions from free text.

### Player hypothesis flow

Selecting a hypothesis always records the player's choice in `GameState.hypotheses`, even when unsupported or refuted.

A supported hypothesis becomes established only when the player explicitly selects it.

Established deduction state persists in `GameState.deductions`.

Re-selecting an established deduction is idempotent.

Wrong hypotheses remain part of the case record rather than destroying progression.

### Evidence privacy / anti-spoiler behavior

The evaluator reports only discovered evidence as:

- visible supporting evidence;
- visible contradicting evidence.

It does not expose names of undiscovered clues required by a rule.

The notebook can therefore show how strong the current case is without leaking future evidence.

### Notebook hypothesis view

The case notebook now has two modes:

1. **Evidence**
2. **Hypotheses**

The hypothesis view shows:

- every authored hypothesis;
- current evaluation status;
- whether the player has recorded it;
- visible support count;
- prerequisite state;
- discovered supporting evidence;
- discovered contradicting evidence;
- a **TEST / RECORD HYPOTHESIS** action.

The room remains paused while either notebook mode is open.

### Autosave

Establishing a deduction triggers the existing autosave path, matching the project rule that major investigative breakthroughs are protected automatically.

### Persistence

Hypothesis selections and established deduction state survive the existing GameState save/load path.

The save content version is now **ch01-slice6**. Schema version remains **1** because the canonical state already contained the required `hypotheses` and `deductions` fields.

## Validation

Godot 4.7.2 CI passes:

1. project/autoload/resource validation;
2. protected movement/hotspot regression suite;
3. protected evidence acquisition/filtering regression suite;
4. insufficient-evidence evaluation;
5. minimum support-count rules;
6. unsupported hypothesis persistence;
7. supported-to-established transition;
8. established deduction idempotence;
9. prerequisite gates;
10. refutation conditions;
11. visible discovered contradiction reporting;
12. hypothesis/deduction serialization through GameState;
13. protected persistence/migration regression suite;
14. real main-scene startup.

## Scope discipline

Slice 6 does not implement witness conversations or evidence presentation to NPCs. Deduction state is now ready for dialogue conditions/effects, which belongs to Slice 7.

## NEXT OPERATION

**Slice 7 — Dialogue and witness framework**

Execute without requesting design decisions:

1. Implement authored dialogue/witness definitions with:
   - stable witness ID;
   - conversation nodes;
   - player choices;
   - topic IDs;
   - conditional visibility;
   - once-only reactions;
   - terminal/return behavior.
2. Implement `DialogueService` that can evaluate conditions against:
   - discovered clues;
   - established deductions;
   - selected hypotheses;
   - witness trust;
   - chapter flags;
   - skill values.
3. Implement dialogue effects for:
   - acquiring/upgrading evidence;
   - changing witness trust;
   - setting chapter flags;
   - opening topics;
   - recording once-only reactions.
4. Implement evidence presentation as a first-class dialogue action:
   - show only discovered/relevant evidence;
   - let witness definitions react to specific evidence IDs/tags;
   - preserve the existing anti-combinatorial design.
5. Implement a reusable conversation UI with:
   - witness name;
   - current line;
   - topic/choice list;
   - evidence-present mode;
   - keyboard 1-9 choice support;
   - clean exit back to room play.
6. Add at least one seed Chapter One witness/conversation sufficient to exercise:
   - public topic;
   - evidence-unlocked topic;
   - trust change;
   - conditional branch;
   - once-only reaction.
7. Add generic room/hotspot hooks to start a witness conversation without hardcoding dialogue logic into individual rooms.
8. Persist trust, flags, opened topics/reaction state through the existing GameState path.
9. Add tests for:
   - condition evaluation;
   - effect application;
   - evidence presentation;
   - trust changes;
   - once-only behavior;
   - persisted dialogue state.
10. Protect all Slice 3-6 regression suites.
11. Run Godot validation and main-scene startup regression.
12. Update `ROADMAP.md`, `ARCHITECTURE.md`, and `CURRENT.md`.
13. Commit/push, follow CI and Web deployment to terminal status, and verify exact `main` head.

Do not start Slice 8 in the same turn unless the user explicitly asks for multiple slices.
