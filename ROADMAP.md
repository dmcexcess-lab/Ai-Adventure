# Roadmap

The user only says **next slice** / **continue**. The assistant executes the next unchecked slice, updates this file and `CURRENT.md`, commits/pushes, verifies the resulting head, then returns the next prompt.

## Phase A — Foundation and engine

- [x] **Slice 1 — Design lock**
  - Establish project north star.
  - Translate canon into Chapter One.
  - Lock engine architecture, investigation grammar, RPG scope, and chapter structure.
  - Establish finite production slices.

- [x] **Slice 2 — Godot web bootstrap**
  - Create Godot 4 project.
  - 640x480 viewport and scaling.
  - Main menu, game shell, room router.
  - One temporary room.
  - Web export configuration.
  - GitHub Pages workflow or repository-appropriate static deployment path.
  - Smoke-test project startup.

- [x] **Slice 3 — Interaction and room framework**
  - Point-and-click movement.
  - Hotspots.
  - Context actions.
  - Room transitions.
  - Interaction feedback.
  - Hotspot reveal accessibility key.

- [x] **Slice 4 — Canonical state and persistence**
  - GameState.
  - Save schema.
  - Manual save/load UI.
  - Auto-save.
  - Browser persistence.
  - Serialization tests.

- [x] **Slice 5 — Evidence notebook**
  - Clue definitions.
  - Evidence acquisition.
  - Notebook UI.
  - Evidence detail/upgrades.
  - Evidence filtering.
  - Tests.

- [x] **Slice 6 — Deduction engine**
  - Hypothesis selection.
  - Authored rule evaluator.
  - Established/refuted/unsupported states.
  - Contradiction presentation.
  - Tests.

- [x] **Slice 7 — Dialogue and witness framework**
  - Topic dialogue.
  - Evidence presentation.
  - Conditional nodes/effects.
  - Trust.
  - Conversation UI.
  - Tests.

- [x] **Slice 8 — Light RPG layer**
  - Observation, Reasoning, Empathy, Resolve.
  - Opening background choice.
  - Deterministic checks.
  - Alternate-route handling.
  - Character panel.

## Phase B — Chapter One content

- [ ] **Slice 9 — Chapter One content skeleton**
  - All primary rooms.
  - Navigation.
  - Scene transitions.
  - Placeholder actors/backgrounds.
  - Full chapter flag graph.
  - Start-to-ending greybox route.

- [ ] **Slice 10 — Act I: The Impossible Packet**
  - Opening sequence.
  - Workstation investigation.
  - Building records.
  - First witness.
  - Deductions 1-2.

- [ ] **Slice 11 — Act II: The Missing Witness**
  - Café/social hub.
  - Records office.
  - erased-witness traces.
  - Alternate critical clue routes.
  - Deduction 3.

- [ ] **Slice 12 — Act III: The Seam**
  - Transit anomaly.
  - Observation overlook.
  - Utility room.
  - invariant-time evidence.
  - Deductions 4-5.

- [ ] **Slice 13 — Act IV: The Sender**
  - identity-signature investigation.
  - contradiction challenges.
  - optional deep evidence.
  - Deductions 6-9.

- [ ] **Slice 14 — Act V: The Threshold**
  - threshold site.
  - final conversations.
  - evidence-dependent ending variants.
  - chapter-complete state.
  - Chapter Two hook.

## Phase C — Presentation and closure

- [ ] **Slice 15 — Final art/audio pass**
  - Replace greybox visuals.
  - Period-appropriate UI polish.
  - Character animation minimum set.
  - Ambient loops and interaction audio.
  - Dialogue readability/accessibility.

- [ ] **Slice 16 — Full progression QA**
  - Golden path.
  - Alternate critical-clue path.
  - save/load regression.
  - fresh-browser persistence test.
  - fix all progression blockers.

- [ ] **Slice 17 — Web release closure**
  - Production web export.
  - Firefox verification.
  - deployment verification.
  - exact live-build link in `CURRENT.md`.
  - release notes.
  - mark Chapter One complete.

When Slice 17 is complete and verified, respond:

**ok final slice done play chapter one**
