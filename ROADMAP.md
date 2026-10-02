# Roadmap

The user normally says **next slice** / **continue**. The assistant executes the next unchecked slice, updates this file and `CURRENT.md`, commits/pushes, verifies the resulting head, then returns the next operation.

## Phase A — Foundation and engine

- [x] **Slice 1 — Design lock**
- [x] **Slice 2 — Godot web bootstrap**
- [x] **Slice 3 — Interaction and room framework**
- [x] **Slice 4 — Canonical state and persistence**
- [x] **Slice 5 — Evidence notebook**
- [x] **Slice 6 — Deduction engine**
- [x] **Slice 7 — Dialogue and witness framework**
- [x] **Slice 8 — Light RPG layer**

## Phase B — Umbrella Quest functional vertical slice

Umbrella Quest is non-canon, but it is the authoritative compact proof of the finished game. The gameplay systems below are implemented and protected by tests. Completing a functional slice does **not** mean its presentation is production-complete.

- [x] **Slice 9 — Visual direction foundation**
- [x] **Slice 10 — Multi-room Umbrella Quest world skeleton**
- [x] **Slice 11 — Umbrella investigation loop**
- [x] **Slice 12 — Umbrella RPG integration**
- [x] **Slice 13 — Umbrella bounded combat**
- [x] **Slice 14 — Production environment-background pass**
  - Eight finished room backgrounds.
  - Final comic-book / dark gritty city environment language.
  - Production PNG packaging and Web validation.
  - Backgrounds are the **only** Umbrella presentation category currently accepted as production-complete.

- [x] **Post-Slice 14 technical prototype — scene-aware PC/#3 staging**
  - One shared protagonist identity reference.
  - Six-pose runtime atlas.
  - Per-room default angle and perspective scaling.
  - Direction-aware pose switching.
  - Combat-pose integration.
  - This proves the staging/runtime approach only. It does **not** make the protagonist art or animation production-complete.

## Phase C — Umbrella Quest production closure

Chapter One is blocked until **all** production slices below are complete and the user has played and accepted the finished Umbrella Quest.

- [ ] **Slice 15 — Character production**
  - Treat the accepted PC/#3 reference as design authority, not finished runtime art.
  - Produce final in-world PC/#3 sprites using OpenAI image generation rather than fal.
  - Preserve identity across all room angles and perspective sizes.
  - Final PC animation set must cover:
    - idle/rest poses;
    - side walk;
    - walk toward camera;
    - walk away from camera;
    - inspect/interact;
    - conversation/listening;
    - combat-ready;
    - Strike;
    - Guard;
    - Maneuver;
    - Disengage;
    - hit/consequence reaction.
  - Produce final Alex and Mina in-world art that matches the environment quality bar.
  - Produce final Alex/Mina dialogue portraits with enough expression variants for their authored conversation beats.
  - Produce final loading-bay opponent art and combat reactions.
  - Keep feet, approach points, perspective scaling, room graph, RPG rules, and combat math unchanged.
  - A character category is not marked production-complete until the deployed result is visually accepted by the user.

- [ ] **Slice 16 — UI production**
  - Main menu.
  - HUD / objective feedback.
  - Notebook evidence view.
  - Hypothesis/deduction view.
  - Background/profile selection.
  - Character panel.
  - Dialogue / evidence presentation.
  - Combat UI.
  - Save/load UI.
  - Case-closed UI.
  - Replace prototype abbreviations/debug-like controls with finished readable product language.
  - Validate all panels at 640x480.

- [ ] **Slice 17 — Scene staging, animation, depth, and transitions**
  - Foreground occlusion/depth where backgrounds call for it.
  - Character/NPC grounding and room-specific scale tuning.
  - Finished room-entry/exit transitions.
  - Interaction approach/readability polish.
  - Hotspot alignment against production backgrounds.
  - Final ambient FX behavior.
  - Remove placeholder bob/tween motion where final authored animation replaces it.

- [ ] **Slice 18 — Audio production**
  - Room ambience.
  - Rain/exterior ambience.
  - Interior electrical/HVAC texture.
  - UI feedback sounds.
  - Footsteps where useful.
  - Evidence/deduction cues.
  - Dialogue presentation cues.
  - Combat action/impact/guard/disengage cues.
  - Case-resolution cue.
  - Music only where it improves the finished experience; no requirement to fill every room.
  - Add volume controls and Web-safe playback behavior.

- [ ] **Slice 19 — Menus, settings, accessibility, persistence, and ending production**
  - Finished Settings UI.
  - Master/music/SFX volume.
  - Text/readability options that fit current architecture.
  - Hotspot reveal/accessibility behavior.
  - Save/load messaging and safe-state handling.
  - Proper title-to-game and game-to-title flow.
  - Finished case introduction.
  - Finished case-closed/end-of-demo sequence.
  - Replay/return-to-title behavior.

- [ ] **Slice 20 — Full production playtest and correction**
  - Start-to-finish fresh run through every major system.
  - All four RPG backgrounds.
  - Alternate investigation routes.
  - Bad-hypothesis/refutation behavior.
  - Victory/disengage/consequence combat outcomes.
  - Save/load across multiple rooms and post-combat.
  - Keyboard/mouse parity.
  - 640x480 layout safety.
  - Firefox/Web performance.
  - Correct all player-facing friction and regression defects found.

- [ ] **Slice 21 — Umbrella production acceptance gate**
  - Deploy the complete production candidate.
  - Run all automated regressions and package checks.
  - User plays the candidate.
  - Fix all remaining issues the user identifies.
  - Do **not** mark this slice complete from automated tests alone.
  - Do **not** begin Chapter One until the user explicitly accepts the Umbrella Quest as production-complete.

## Phase D — Chapter One content

Chapter One begins only after Slice 21 is complete.

- [ ] **Slice 22 — Chapter One content skeleton**
- [ ] **Slice 23 — Act I: The Impossible Packet**
- [ ] **Slice 24 — Act II: The Missing Witness**
- [ ] **Slice 25 — Act III: The Seam**
- [ ] **Slice 26 — Act IV: The Sender**
- [ ] **Slice 27 — Act V: The Threshold**

## Phase E — Chapter One presentation and closure

- [ ] **Slice 28 — Chapter One final art/audio pass**
- [ ] **Slice 29 — Full progression QA**
- [ ] **Slice 30 — Web release closure**

When Slice 30 is complete and verified, respond:

**ok final slice done play chapter one**
