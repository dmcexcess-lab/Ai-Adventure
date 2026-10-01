# Roadmap

The user normally says **next slice** / **continue**. The assistant executes the next unchecked slice, updates this file and `CURRENT.md`, commits/pushes, verifies the resulting head, then returns the next prompt.

## Phase A — Foundation and engine

- [x] **Slice 1 — Design lock**
- [x] **Slice 2 — Godot web bootstrap**
- [x] **Slice 3 — Interaction and room framework**
- [x] **Slice 4 — Canonical state and persistence**
- [x] **Slice 5 — Evidence notebook**
- [x] **Slice 6 — Deduction engine**
- [x] **Slice 7 — Dialogue and witness framework**
- [x] **Slice 8 — Light RPG layer**

## Phase B — Umbrella Quest systems and environment proof

Umbrella Quest is deliberately non-canon, but it is the authoritative compact proof of the finished game. Chapter One production remains blocked until the Umbrella Quest itself is production-complete.

- [x] **Slice 9 — Visual direction foundation**
- [x] **Slice 10 — Multi-room Umbrella Quest world skeleton**
- [x] **Slice 11 — Umbrella investigation loop**
- [x] **Slice 12 — Umbrella RPG integration**
- [x] **Slice 13 — Umbrella combat slice**
- [x] **Slice 14 — Umbrella environment production pass**
  - All eight room backgrounds reached the accepted production comic-book quality bar.
  - Background composition, lighting, grit, city/institutional tone, and interaction readability are the visual reference for the finished game.
  - Earlier Slice 14 claims that characters, portraits, UI, animation, combat presentation, or other presentation layers were also production-complete are superseded.
- [x] **Post-Slice 14 prototype integration — scene-aware PC / #3**
  - Proved room-specific pose selection and perspective scaling.
  - Proved one reusable #3 identity can drive all rooms.
  - This was a prototype integration, **not** a production-complete character pass.

## Phase C — Umbrella Quest production completion

**Production baseline correction:** as of the start of Slice 15, the eight environment backgrounds are the only production-complete presentation layer. Everything listed below must independently clear its production slice before Chapter One begins.

- [ ] **Slice 15 — PC / #3 production character pass**
  - Use the accepted full-resolution #3 reference already created; no new art-generation call is required for this slice.
  - Replace the severely downsampled runtime atlas with a high-resolution Web-sized derivative.
  - Preserve scene-aware pose selection, room-specific resting angles, and foot-Y perspective scale.
  - Correct pose framing/aspect so the character reads naturally rather than as a stretched atlas crop.
  - Keep player gameplay coordinates invariant.
  - Protect all eight rooms, movement directions, perspective range, and combat-pose restoration with tests.
  - Treat #3 as production-complete only after runtime quality and integration pass CI and live Web verification.

- [ ] **Slice 16 — NPC and portrait production pass**
  - Alex room character.
  - Mina room character.
  - loading-bay opponent.
  - Alex/Mina dialogue portraits.
  - Match production backgrounds and #3 in line weight, scale, lighting, and silhouette.
  - Add scene-specific staging/perspective rather than pasted fixed-size figures.
  - Preserve dialogue/combat mechanics exactly.

- [ ] **Slice 17 — UI, menus, notebook, dialogue, combat HUD, and ending production pass**
  - Replace remaining prototype/tool-panel presentation.
  - Production title/menu flow.
  - production background-choice screen.
  - notebook/evidence/hypothesis hierarchy.
  - character panel.
  - dialogue/evidence presentation.
  - combat HUD.
  - save/load messaging.
  - settings screen appropriate to the Web build.
  - finished case-resolution / end-of-demo presentation.

- [ ] **Slice 18 — Animation, depth, transitions, and room presentation pass**
  - Production movement/idle minimum.
  - witness presence animation where justified.
  - room-to-room transitions.
  - foreground occlusion/depth planes where backgrounds call for them.
  - environmental motion.
  - combat feedback integrated into the loading-bay panel.
  - no gameplay-system expansion.

- [ ] **Slice 19 — Audio production pass**
  - room ambience;
  - rain/exterior bed;
  - UI feedback;
  - footsteps/interaction cues;
  - dialogue presentation cues where useful;
  - combat impacts/guard/maneuver/disengage;
  - restrained music or tonal bed only if it materially improves the finished experience;
  - volume/settings integration and Web-safe packaging.

- [ ] **Slice 20 — Umbrella Quest final production QA and acceptance build**
  - Full fresh-start-to-case-closed playthrough.
  - hotspot/art alignment.
  - pacing/readability.
  - keyboard/mouse parity.
  - save/load across rooms and after combat.
  - 640x480 layout safety.
  - Firefox/Web performance.
  - no prototype labels, placeholder copy, or unfinished panels.
  - all automated regressions.
  - deploy a final acceptance build.
  - **Do not mark Umbrella Quest production-complete until the user has played this build and accepted it or requested only bounded fixes.**

## Phase D — Chapter One content

Chapter One starts only after Slice 20 acceptance.

- [ ] **Slice 21 — Chapter One content skeleton**
- [ ] **Slice 22 — Act I: The Impossible Packet**
- [ ] **Slice 23 — Act II: The Missing Witness**
- [ ] **Slice 24 — Act III: The Seam**
- [ ] **Slice 25 — Act IV: The Sender**
- [ ] **Slice 26 — Act V: The Threshold**

## Phase E — Chapter One presentation and closure

- [ ] **Slice 27 — Chapter One final art/audio pass**
- [ ] **Slice 28 — Full progression QA**
- [ ] **Slice 29 — Web release closure**

When Slice 29 is complete and verified, respond:

**ok final slice done play chapter one**
