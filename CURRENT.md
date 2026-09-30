# Current

## Status

**Slice 5 — Evidence notebook: COMPLETE**

The project now has the first real investigation-state layer: authored clues, canonical evidence acquisition, detail upgrades, filtering, and a playable case notebook.

## Implemented

### Authored clue definitions

Chapter One evidence is now authored as data under `content/ch01/clues/`.

Each definition supports:

- stable clue ID;
- title;
- source;
- reliability;
- tags;
- contradiction tags;
- ordered detail levels;
- optional temporal provenance.

The seed catalog contains framework-level Chapter One clues for the impossible packet and corridor record path without implementing the full Act I investigation.

### EvidenceService

`EvidenceService` is now an autoload.

It:

- loads authored clue definitions;
- rejects unknown clue IDs;
- acquires clues idempotently;
- upgrades discovered detail without duplicates;
- stores canonical discovery/detail state in `GameState.clues`;
- merges definition + discovery state for UI;
- filters discovered evidence by tag;
- exposes discovered tags;
- emits evidence-added / evidence-upgraded / evidence-changed signals.

### Generic evidence hooks

Hotspots now support optional:

- `evidence_id`;
- `evidence_detail_level`.

The reusable room controller delegates those hooks to EvidenceService after the player's approach completes.

Rooms and hotspots do not write notebook state directly.

The workstation packet hotspot is wired to record **Impossible Timestamp** as the first framework evidence entry.

### Notebook / Evidence UI

The game shell now includes a modal 1990s-style case notebook.

It provides:

- discovered evidence list;
- selected clue title;
- source;
- reliability;
- full current detail text;
- temporal provenance;
- tags;
- contradiction tags;
- tag filter;
- explicit close control.

**N** and **E** both open/close the evidence notebook.

While the notebook is open, the active room is paused so movement or hotspot actions cannot continue behind the modal interface.

The lower HUD also exposes **NOTE** and **EVID** buttons.

### Persistence

Evidence discovery and upgraded detail survive the existing GameState save/load path.

The save content version is now **ch01-slice5**. Schema version remains **1** because the existing canonical `clues` dictionary already supports the evidence state.

## Validation

Godot 4.7.2 CI passes:

1. project/autoload/resource validation;
2. protected movement/hotspot regression suite;
3. clue catalog loading;
4. unknown clue rejection;
5. first acquisition;
6. idempotent re-acquisition;
7. detail upgrade;
8. tag filtering;
9. discovered-tag enumeration;
10. evidence serialization through GameState;
11. workstation hotspot evidence-hook wiring;
12. protected persistence/migration regression suite;
13. real main-scene startup.

## Scope discipline

Slice 5 does not implement hypotheses or deduction validation. Contradiction tags are now visible evidence metadata, but deciding what conclusions they support remains Slice 6.

## NEXT OPERATION

**Slice 6 — Deduction engine**

Execute without requesting design decisions:

1. Implement authored deduction definitions with:
   - stable deduction ID;
   - title;
   - description;
   - required clue IDs and/or required evidence tags;
   - minimum support count;
   - contradiction/exclusion conditions;
   - prerequisite deductions;
   - optional skill-insight metadata.
2. Implement `DeductionService` that:
   - evaluates authored rules against canonical GameState/EvidenceService state;
   - returns `unsupported`, `supported`, `established`, or `refuted` as appropriate;
   - never infers conclusions from free text;
   - persists selected hypotheses / established deduction state in GameState;
   - emits deduction-state changes.
3. Implement the player hypothesis flow:
   - notebook deduction/hypothesis view;
   - select a conclusion;
   - show what evidence currently supports or contradicts it without revealing undiscovered clues;
   - allow wrong/unsupported hypotheses to remain recorded without softlocking progression.
4. Add a small Chapter One seed deduction set sufficient to exercise the engine without beginning full Act I content.
5. Make the first seed deduction testable using the Slice 5 evidence catalog.
6. Preserve evidence/notebook state through save/load.
7. Add tests for:
   - insufficient evidence;
   - support-count rules;
   - prerequisite deductions;
   - contradiction/refutation rules;
   - persisted hypothesis state;
   - established deduction idempotence.
8. Protect all Slice 3 interaction, Slice 4 persistence, and Slice 5 evidence regressions.
9. Run Godot validation and main-scene startup regression.
10. Update `ROADMAP.md`, `ARCHITECTURE.md`, and `CURRENT.md`.
11. Commit/push, follow CI and Web deployment to terminal status, and verify exact `main` head.

Do not start Slice 7 in the same turn unless the user explicitly asks for multiple slices.
