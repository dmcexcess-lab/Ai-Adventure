# Current

## Status

**Slice 7 — Dialogue and witness framework: COMPLETE**

The project now has a reusable authored conversation system with persistent trust/topics/reactions, conditional dialogue, filtered evidence presentation, and a playable seed witness in the corridor.

## Implemented

### Authored witness graphs

Chapter One witness data now lives under `content/ch01/dialogue/`.

A witness definition supports:

- stable witness ID;
- display name and role;
- authored start node;
- conversation nodes;
- numbered player choices;
- topic IDs;
- conditional visibility;
- terminal choices;
- once-only choice reactions;
- evidence reactions keyed by clue IDs and/or clue tags.

The seed witness is **Mara Bell**, the building manager in the apartment corridor.

### DialogueService

`DialogueService` is now an autoload.

It evaluates dialogue conditions against canonical state including:

- discovered clues;
- established deductions;
- selected hypotheses;
- witness trust;
- chapter flags;
- skill values;
- opened topics;
- consumed reactions.

It applies authored effects for:

- evidence acquisition/upgrades;
- witness trust changes;
- chapter flags;
- topic opening;
- once-only reaction recording.

### Persistent dialogue state

`GameState` now canonically stores:

- `witness_trust`;
- `dialogue_topics`;
- `dialogue_reactions`.

These fields normalize safely when loading older schema-1 saves, so the save schema remains version **1**.

The save content version is now **ch01-slice7**.

### Evidence presentation

Evidence is a first-class conversation action.

The conversation UI only lists discovered clues that have an eligible authored reaction for the current witness.

This prevents classic inventory-combination spam and does not reveal undiscovered clue names.

Once-only reactions disappear from the relevant-evidence list after use.

### Conversation UI

The reusable modal conversation panel provides:

- witness name;
- role;
- trust value;
- current authored line;
- topic/response choices;
- **PRESENT EVIDENCE** mode;
- choices numbered 1-9;
- keyboard 1-9 selection;
- clean exit back to room play.

Room interaction is paused while a conversation is open.

### Generic witness hotspot hook

Hotspots now support optional `witness_id`.

The reusable room controller emits a conversation request after the approach completes. The game shell opens ConversationUI without any witness-specific room code.

The corridor's building-office hotspot is wired to `mara_bell`.

### Seed conversation behavior

Mara's framework conversation exercises:

- a public maintenance topic;
- trust gain;
- a packet topic unlocked by discovered evidence;
- a conditional service-record branch;
- a once-only question;
- presenting the impossible timestamp;
- a once-only evidence reaction;
- an alternate route to acquire the physical service record.

This remains framework seed content rather than the full Act I conversation pass.

## Validation

Godot 4.7.2 CI passes:

1. project/autoload/resource validation;
2. protected movement/hotspot regression suite;
3. protected evidence regression suite;
4. protected deduction regression suite;
5. witness catalog loading;
6. public topic visibility;
7. evidence-unlocked topic visibility;
8. combined clue/deduction/hypothesis/trust/flag/skill/topic conditions;
9. trust effects;
10. chapter-flag effects;
11. topic persistence;
12. dialogue evidence acquisition;
13. filtered relevant-evidence presentation;
14. once-only choice behavior;
15. once-only evidence reaction behavior;
16. dialogue-state GameState serialization;
17. generic witness hotspot wiring;
18. protected persistence/migration regression suite;
19. real main-scene startup.

## Scope discipline

Slice 7 consumes existing skill values in dialogue conditions but does not yet establish the Chapter One skill/background-choice experience or deterministic skill-routing rules. That belongs to Slice 8.

## NEXT OPERATION

**Slice 8 — Light RPG layer**

Execute without requesting design decisions:

1. Implement the four locked skills:
   - Observation;
   - Reasoning;
   - Empathy;
   - Resolve.
2. Implement a small opening background-choice flow that assigns a fixed, authored Chapter One skill profile without a min-max/stat-allocation screen.
3. Implement a reusable deterministic check service:
   - skill value;
   - authored threshold;
   - contextual modifier;
   - explicit pass/fail result;
   - no random rolls.
4. Implement condition/effect hooks so skill checks can:
   - expose alternate observations;
   - expose dialogue choices;
   - unlock stronger clue detail;
   - record failed approaches;
   - expose authored alternate routes rather than dead ends.
5. Implement the Character panel showing:
   - Her's current background;
   - all four skill values;
   - concise skill descriptions;
   - recorded failed approaches where useful.
6. Integrate skill-gated seed behavior with the existing evidence/deduction/dialogue framework without beginning the full Act I content pass.
7. Preserve background, skill values, and failed-approach state through GameState/save/load.
8. Add tests for:
   - each background profile;
   - deterministic threshold pass/fail;
   - contextual modifiers;
   - failed-approach recording;
   - skill-gated dialogue/evidence behavior;
   - persistence.
9. Protect all Slice 3-7 regression suites.
10. Run Godot validation and main-scene startup regression.
11. Update `ROADMAP.md`, `ARCHITECTURE.md`, and `CURRENT.md`.
12. Commit/push, follow CI and Web deployment to terminal status, and verify exact `main` head.

Do not start Slice 9 in the same turn unless the user explicitly asks for multiple slices.
