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

## Phase B — Umbrella Quest gameplay proof

These slices established the complete gameplay grammar. Their mechanics remain authoritative, but completion of a gameplay slice does **not** mean its presentation is production-complete.

- [x] **Slice 9 — Visual direction foundation**
- [x] **Slice 10 — Multi-room Umbrella world skeleton**
- [x] **Slice 11 — Umbrella investigation loop**
- [x] **Slice 12 — Umbrella RPG integration**
- [x] **Slice 13 — Umbrella combat slice**
- [x] **Slice 14 — Environment-background production pass**
  - All eight room backgrounds are accepted production art.
  - Earlier Slice 14 wording that implied characters/UI/animation/combat presentation were also production-complete is superseded.
- [x] **Post-Slice 14 prototype — scene-aware PC/#3 runtime**
  - Established pose selection and perspective mechanics.
  - Did **not** establish production-complete character art.

## Phase C — Umbrella Quest production completion

**Chapter One is blocked until this entire phase is complete and the deployed Umbrella Quest has been accepted as production-complete.**

Current production status:

- **Production-complete:** eight environment backgrounds only.
- **Not production-complete:** PC/#3 art/presentation, NPC sprites, portraits, UI, notebook/dialogue/combat presentation, animation/transitions/depth, audio, settings, accessibility, save/load UX, ending presentation, final QA.

- [x] **Slice 15 — Production rebaseline + PC/#3 staging repair**
  - Remove misleading production-complete claims.
  - Restore PC to credible human scale against the accepted backgrounds and NPC staging.
  - Preserve gameplay foot position while enlarging only the rendered character.
  - Keep room-authored angle/perspective behavior.
  - Use appropriate texture filtering for scaled comic art.
  - Protect scale, angle, perspective, combat pose, and unchanged gameplay footprint in CI.

- [x] **Slice 16 — PC/#3 production implementation**
  - Use the accepted #3 identity; do not redesign the protagonist.
  - Replace the destructively downsampled 216x72 runtime atlas with a high-resolution derivative of the accepted 2172x724 source sheet.
  - Preserve scene-authored angle selection, perspective scaling, gameplay foot position, movement poses, and combat pose.
  - Keep automated validation separate from user visual acceptance.
  - Do not mark #3 user-accepted production-complete until the deployed result is actually accepted.

- [ ] **Slice 17 — NPC + portrait art production**
  - Bring Alex, Mina, the loading-bay opponent, and dialogue portraits to the accepted environment quality bar.
  - Make room sprites and portraits unambiguously depict the same identities.
  - Replace prototype/vector-placeholder live assets where required.
  - Stage NPC scale/perspective coherently inside the accepted room backgrounds.

- [ ] **Slice 18 — UI + ending presentation production**
  - Production HUD.
  - Notebook/evidence/hypothesis presentation.
  - Dialogue presentation.
  - Character screen.
  - Combat UI.
  - Title/menu presentation.
  - Finished case-closed sequence rather than a prototype modal.

- [ ] **Slice 19 — Motion, depth, and transition production**
  - Room transitions.
  - Character movement/idle minimums.
  - Witness presence/reactions.
  - Foreground occlusion/depth where justified.
  - Combat visual staging.
  - Rain/practical-light polish.
  - No feature-system expansion.

- [ ] **Slice 20 — Audio + settings production**
  - Music/ambient sound.
  - Room ambience.
  - Interaction/dialogue/combat SFX.
  - Audio mixing.
  - Production Settings UI with volume/mute and supported presentation options.
  - Web-safe packaging and persistence.

- [ ] **Slice 21 — Usability, accessibility, and persistence closure**
  - Full start-to-finish player-path review.
  - Objective clarity.
  - Hotspot/readability checks.
  - Keyboard/mouse parity.
  - Save/load UX and messaging.
  - 640x480 modal/layout safety.
  - Accessibility/reveal behavior.
  - Regression coverage for corrected friction.

- [ ] **Slice 22 — Final Umbrella QA + acceptance gate**
  - Fresh-run completion on deployed Web build.
  - All backgrounds, characters, UI, motion, audio, settings, persistence, investigation, RPG, and combat treated as final.
  - Firefox/Web verification.
  - No prototype labels/assets/panels in the player path.
  - Production checklist and release candidate.
  - **Do not begin Chapter One until the user accepts this deployed Umbrella build as production-complete.**

## Phase D — Chapter One content

- [ ] **Slice 23 — Chapter One content skeleton**
- [ ] **Slice 24 — Act I: The Impossible Packet**
- [ ] **Slice 25 — Act II: The Missing Witness**
- [ ] **Slice 26 — Act III: The Seam**
- [ ] **Slice 27 — Act IV: The Sender**
- [ ] **Slice 28 — Act V: The Threshold**

## Phase E — Chapter One production and closure

- [ ] **Slice 29 — Chapter One final art/audio pass**
- [ ] **Slice 30 — Full progression QA**
- [ ] **Slice 31 — Web release closure**

When Slice 31 is complete and verified, respond:

**ok final slice done play chapter one**
