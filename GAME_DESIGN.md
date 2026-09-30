# Game Design

## Presentation

- Internal canvas: **640x480**, 4:3.
- Crisp nearest-neighbor scaling with integer scaling when practical.
- Painted/pixel-art hybrid backgrounds, limited animation, strong silhouettes.
- Full-screen room views with a thin bottom interaction strip.
- UI evokes 1993-1997 adventure games without cloning a specific title.
- Text remains high-resolution enough for modern displays while preserving period framing.

## Controls

### Mouse

- Left click: walk / select / perform contextual action.
- Right click: inspect.
- Hover: hotspot label.
- Bottom bar: Notebook, Evidence, Character, Save, Load, Settings.

### Keyboard

- Esc: menu/back.
- N: notebook.
- E: evidence.
- C: character.
- Space: temporarily reveal interactable hotspot outlines.
- 1-9: dialogue choices when visible.

## Investigation loop

1. Enter a location.
2. Observe scene and people.
3. Acquire claims, records, traces, and anomalies.
4. Notebook automatically records raw evidence.
5. Player marks relationships between evidence or selects a hypothesis.
6. Relevant witnesses/locations gain new investigative topics.
7. Player tests the hypothesis against contradictory evidence.
8. A deduction becomes **Established** only when its required evidence pattern is met.
9. Established deductions unlock story movement.

The game never requires blind combinatorial clicking between every clue pair.

## Evidence model

Every clue has:

- ID;
- title;
- source;
- reliability;
- tags;
- contradiction tags;
- discovered state;
- optional skill-dependent detail;
- optional witness relationship;
- optional temporal provenance.

Example:

`audit_log_split_history`
- tags: `system_log`, `timeline_conflict`, `pre_e`
- contradiction: `single_history`
- supports: `history_overwrite`

## Deductions

Deductions are authored rule checks over evidence tags and state.

Example:

**"The discrepancy is not random corruption."**

Requires any 3 of:
- two independent clocks disagree in the same direction;
- checksum verifies on both conflicting records;
- a human witness remembers only one branch;
- an offline printout preserves the other branch.

The player chooses the conclusion, but the engine validates whether the case supports it.

Wrong hypotheses remain in the notebook and can create dialogue consequences. They do not destroy the save.

## Light RPG systems

Four skills, fixed at character creation for Chapter One through a small background choice. No min-max screen is required before play; the player chooses one sentence about how Her approaches problems.

- **Observation** — notices physical or visual irregularities.
- **Reasoning** — extracts stronger deductions from technical/documentary evidence.
- **Empathy** — reads emotional mismatch and opens witness routes.
- **Resolve** — resists pressure, challenges evasions, and follows disturbing evidence.

Skills range 0-3.

Checks are deterministic thresholds plus contextual modifiers; no invisible dice. If a check fails, the game records the failed approach and usually exposes an alternate route.

## Character state

Chapter One tracks:

- skill values;
- witness trust;
- suspicion/pressure;
- discovered clues;
- established deductions;
- selected hypotheses;
- visited locations;
- chapter flags;
- save metadata.

No hunger, crafting, combat, equipment stats, or economy.

## Inventory

Minimal and literal.

Inventory can hold documents, removable media, keys, and small evidence objects, but inventory use is never the primary puzzle grammar.

If an object logically belongs somewhere, the context action exposes that use directly. The player is not expected to drag every object onto every hotspot.

## Conversation system

Dialogue is topic-driven.

Witnesses have:
- public topics;
- evidence-unlocked topics;
- contradiction challenges;
- trust gates;
- skill-gated reads;
- once-only emotional reactions.

Showing evidence is a first-class action. The UI filters to evidence relevant to the current witness/topic.

## Chapter One location plan

Target: 9 primary scenes plus 3 close-up scenes.

1. Her's room / workstation — opening packet, save tutorial, first anomaly.
2. Apartment corridor / building office — mundane records contradict packet metadata.
3. Systems archive — logs, checksums, backup media, split-history evidence.
4. Transit concourse — witness traffic and clock anomaly.
5. Café — social witness hub; memory and phrase evidence.
6. Records office — missing-person/non-person traces.
7. Observation overlook — repeated environmental event; establishes invariant timing.
8. Restricted utility room — physical clock and offline record path.
9. Threshold site — final investigation and E approach.

Close-ups:
- workstation terminal;
- evidence table / notebook;
- threshold instrument panel.

## Chapter One core deductions

1. The packet is not a simple local forgery.
2. The conflicting records were each internally valid.
3. A missing person left secondary traces despite having no primary record.
4. The contradictions cluster around one temporal boundary.
5. The boundary is more stable than the histories around it.
6. The sender shares Her's identity signature.
7. The sender is not Her's future in a single continuous history.
8. Information survived the erasure of a prior iteration.
9. The sender deliberately targeted this Her before E.

Deductions 1-5 are required to reach the final act.
Deductions 6-9 determine how much Her understands at the threshold and alter the chapter ending dialogue.

## Anti-frustration rules

- Critical evidence has at least two acquisition routes.
- No critical clue can be permanently missed.
- No timed dialogue selection.
- No death from dialogue.
- No softlock from consuming/dropping an object.
- Save anywhere outside transitions.
- Auto-save on location entry and major deduction.
