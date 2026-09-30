# Current

## Status

**Umbrella Quest Slice 11 — Investigation loop: COMPLETE**

Chapter One production remains paused.

The eight-room Umbrella Quest is now a complete playable missing-item investigation rather than a navigation/UI showcase.

## Case premise

Nora Vale reports a distinctive missing umbrella:

- navy fabric;
- yellow electrical-tape repair on the handle;
- small brass duck-head cap;
- left on the community-center lobby rack around 8:40 PM.

The case resolves through evidence rather than an inventory-key chain.

## Case spine

The player reconstructs this movement chain:

1. Nora leaves the umbrella on the lobby rack.
2. Alex clears the rack during closing and moves the umbrella to Lost & Found.
3. Ticket 47B records it in Cabinet B.
4. Mina Reyes later moves it out of Cabinet B during her closing sweep.
5. Mina routes the soaking umbrella through the service corridor.
6. The umbrella is placed on the loading-bay drying rail under wet-property procedure.
7. The claim ticket is never updated, creating the apparent disappearance.
8. The player recovers the umbrella from behind the loading-bay safety curtain.

The final explanation is mundane by design: a broken handoff reconstructed from evidence.

## Authored evidence

The demo case now includes evidence distributed across the existing world, including:

- owner's missing-item description;
- rain forecast;
- dry rack outline;
- Ticket 47B;
- Alex's transfer statement;
- front-desk closing log;
- Cabinet B water/adhesive trace;
- closing shift board;
- wet-property procedure;
- MR transfer tag;
- rear fan timer;
- Mina's second-transfer statement;
- Mina's reason for moving the umbrella;
- rear drying-rail trace;
- recovered umbrella.

## Notebook progression

The notebook now drives the case.

Five sequential conclusions form the required investigation chain:

1. **Ticket 47B is Nora's umbrella.**
2. **The umbrella moved from the lobby to Lost & Found.**
3. **Cabinet B was only an intermediate stop.**
4. **Mina carried 47B through the service route.**
5. **The umbrella was moved to dry, not stolen.**

Each conclusion can be:

- unsupported;
- supported;
- established;
- refuted.

The player must explicitly select/test a supported conclusion to establish it.

Later conclusions remain hidden until their prerequisite conclusion is established.

The notebook never lists missing clue identities. It only shows support or contradiction the player has actually discovered.

## Wrong hypotheses

Two bad theories can be recorded:

- Alex kept the umbrella.
- Someone stole it from Cabinet B.

They can begin plausible or unsupported and later become visibly refuted by discovered evidence.

## Witnesses and evidence presentation

### Alex

Alex remains at the front desk and can discuss:

- his rack-clearing transfer;
- who handled lost property after him;
- who could have moved something out of Cabinet B.

Presenting Ticket 47B, the closing log, or Cabinet B evidence produces authored reactions.

### Mina Reyes

Mina is now physically staged in the staff office with a room sprite and dedicated portrait.

She can discuss:

- her closing sweep;
- wet-property procedure;
- Ticket 47B after the case reaches the relevant stage.

Presenting Cabinet B traces, the MR transfer tag, fan timing, policy, or Ticket 47B can produce new evidence and motive clarification.

## Alternate evidence routes

Critical progress does not depend on a single witness confession.

The service-route conclusion can be established through:

- Mina's statement plus corroboration; or
- shift-board + transfer-tag / mechanical evidence.

The final drying conclusion can be established through:

- Mina's motive statement plus the rail; or
- written wet-property procedure plus the rail.

This protects the mini-case from dialogue softlocks.

## Resolution

Once the final deduction is established, the objective changes to the loading-bay drying rail.

Interacting with the rail then:

- records the recovered umbrella as evidence;
- marks the case resolved;
- opens a dedicated **CASE CLOSED // UMBRELLA QUEST** panel;
- explains the complete transfer chain.

The player can close the resolution panel and continue exploring.

## Save behavior

The local Umbrella snapshot now preserves:

- room;
- player position;
- evidence;
- established deductions;
- selected hypotheses;
- Alex/Mina trust;
- case-resolution state.

It still does not touch Chapter One save slots or canonical state.

## Validation

Godot 4.7.2 CI now protects:

1. fresh Umbrella case initialization;
2. owner-description evidence at case start;
3. five-step deduction progression;
4. explicit hypothesis selection/establishment;
5. Alex witness route;
6. Mina witness route;
7. evidence presentation;
8. witness-generated evidence;
9. alternate documentary/physical route without Mina's admission;
10. bad-hypothesis refutation;
11. final case resolution;
12. umbrella recovery evidence;
13. canon-state isolation;
14. eight-room graph/navigation integrity;
15. Slice 9/10 visual and interaction behavior;
16. all canonical interaction/evidence/deduction/dialogue/RPG/persistence regressions;
17. real main-scene startup.

The Web packaging gate also includes Mina's room sprite and portrait.

## NEXT OPERATION

**Umbrella Quest Slice 12 — RPG integration**

Execute without requesting design decisions:

1. Keep the Slice 11 case spine and resolution intact.
2. Make the four existing backgrounds materially change investigation routes:
   - The Watcher / Observation;
   - The Analyst / Reasoning;
   - The Reader / Empathy;
   - The Anchor / Resolve.
3. Give each skill at least one meaningful deterministic route that can produce:
   - extra evidence;
   - stronger evidence detail;
   - an alternate witness response;
   - or a shortcut / different support combination.
4. Use the existing deterministic rule:
   - skill value + contextual modifier >= authored threshold.
5. Show the player the check outcome clearly; no hidden dice and no ambiguous random failure.
6. Failed checks must change or redirect the investigation rather than dead-end it.
7. Add at least one persistent failed-approach consequence or fallback route per representative skill pattern where practical.
8. Make background choice available for Umbrella Quest itself without mutating canonical Chapter One background state.
9. Reflect the selected demo background and four skill values in the Character panel.
10. Preserve the full non-skill golden path so no background can make the case impossible.
11. Keep combat out of this slice; Slice 13 owns combat.
12. Protect with tests proving:
    - all four backgrounds apply their fixed profiles;
    - deterministic pass/fail thresholds;
    - each skill exposes a meaningful case route;
    - failed checks expose or preserve fallback progress;
    - every background can still resolve the case;
    - save/load preserves demo background/skill/failure state;
    - canon-state isolation;
    - all Slice 11 case and room regressions.
13. Run all existing regressions and main-scene startup.
14. Update `ROADMAP.md`, `ARCHITECTURE.md`, and `CURRENT.md`.
15. Commit/push, follow CI and Web deployment to terminal status, and verify exact `main` head.

Do not start Slice 13 in the same turn unless the user explicitly asks for multiple slices.
