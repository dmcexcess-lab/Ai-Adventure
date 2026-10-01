# Current

## Status

**Umbrella Quest Slice 13 — Bounded combat: COMPLETE**

Chapter One production remains paused.

Umbrella Quest now proves investigation, dialogue, RPG routing, persistence, **and one bounded combat encounter** inside the same comic-noir exploration presentation.

Combat remains subordinate to investigation.

## Encounter trigger

The encounter is staged in the existing:

**Loading Bay / Service Exit**

It does not trigger merely because the player discovers the room.

The encounter becomes eligible only after the player has established:

**Mina carried 47B through the service route.**

Entering the loading bay after that deduction starts the encounter.

If that deduction is established while the player is already in the loading bay, combat starts there immediately.

Once completed, the encounter does not retrigger on later room entries.

## Encounter fiction

The rear service door slams open.

A soaked trespasser, startled to find the player blocking the narrow loading bay, swings a heavy flashlight and tries to force past.

This encounter is deliberately incidental to the umbrella mystery.

Winning or losing the physical exchange does not rewrite the evidence chain or make the umbrella explanation dependent on combat.

## Presentation

Combat does **not** change to a detached battle screen.

The loading-bay room stays visible.

The existing comic-noir shell gains a translucent combat layer containing:

- the opponent silhouette;
- player condition;
- opponent condition;
- leverage / guard;
- next opponent intent;
- rolling surfaced-resolution log;
- four action buttons.

Keyboard 1-4 map to the same four actions.

The bottom investigation shell remains visually part of the same scene, but interaction behind the combat overlay is blocked until the encounter ends.

## Deterministic combat state

Starting values:

- **Player condition:** 8 / 8
- **Opponent condition:** 6 / 6
- **Leverage:** 0
- **Guard:** 0

There are no random rolls.

The opponent uses a visible repeating intent sequence:

1. **RUSH — 3 damage**
2. **FLASHLIGHT SWING — 2 damage**
3. **SHOVE — 2 damage**

The next intent is shown before the player chooses an action.

## Action grammar

### 1 // STRIKE

Base:

**2 damage**

RPG interaction:

- Resolve 3 adds **+1** direct-action damage.
- One point of existing leverage can be spent for **+1** damage.

Example Anchor opening strike:

**2 base + 1 Resolve + 0 leverage = 3 damage**

### 2 // GUARD

Base:

**2 block**

RPG interaction:

- Resolve 3 adds **+1 block**.

Guard applies to the opponent's next surfaced action.

### 3 // MANEUVER

Base:

**+1 leverage**

The resolver checks the strongest of:

- Observation;
- Reasoning;
- Empathy.

If that strongest skill is 3, Maneuver gains another:

**+1 leverage**

Maneuver also supplies one point of immediate guard.

This makes existing backgrounds matter without inventing combat attributes.

Examples:

- Watcher uses Observation expertise;
- Analyst uses Reasoning expertise;
- Reader uses Empathy expertise;
- Anchor lacks the non-Resolve expertise bonus but has stronger direct control through Resolve.

### 4 // DISENGAGE

Deterministic rule:

**Resolve + Leverage >= 3**

Examples:

- Anchor can disengage immediately: **3 + 0 = 3 / 3**
- Reader can Maneuver first, gain 2 leverage from Empathy expertise, then disengage: **1 + 2 = 3 / 3**

A failed disengage consumes the action and the opponent resolves the already-visible intent.

## Outcomes

### Victory

Reducing opponent condition to zero ends combat immediately.

The player remains in the loading bay and resumes the investigation.

### Voluntary disengage

Passing the disengage check breaks contact.

The trespasser bolts into the rain.

Investigation resumes in the same room.

### Forced disengage / failure consequence

If player condition reaches zero:

- there is no death screen;
- there is no reload requirement;
- there is no case failure.

The player is forced back from the exchange.

Demo state records:

**bruised_ribs**

The Character panel reports the combat outcome and consequence.

The umbrella investigation remains fully completable.

## Save/load safety

Umbrella local persistence now treats combat as an atomic authored event.

While combat is active:

- SAVE is locked;
- LOAD is locked.

The demo never serializes a half-resolved combat round.

After victory, disengagement, or forced disengagement:

- safe SAVE is restored;
- safe LOAD is restored;
- snapshots preserve the completed combat outcome and consequence.

Loading a completed encounter does not restart it.

Loading an intentionally older safe snapshot from before combat can naturally make the encounter eligible again when its trigger conditions are reached.

Canonical Chapter One saves remain untouched.

## Reusable combat resolver

The deterministic rules live in:

`core/combat/bounded_combat.gd`

The loading-bay authored encounter lives in:

`content/demo/umbrella_combat.gd`

The resolver owns no GameState and is not an autoload.

The Umbrella shell supplies:

- encounter definition;
- local RPG profile.

This keeps the contract reusable for later Chapter One authoring while keeping Slice 13 combat state strictly demo-local.

## Validation

Godot 4.7.2 CI now protects:

1. loading-bay combat trigger after service-route deduction;
2. no premature combat requirement in prior Slice 11/12 paths;
3. four locked combat actions;
4. authored 8/6 condition values;
5. surfaced deterministic Strike math;
6. surfaced opponent intent/damage;
7. Anchor victory path;
8. Reader Empathy-assisted Maneuver;
9. deterministic Reader disengage path;
10. failed-disengage sequence;
11. forced-disengage `bruised_ribs` consequence;
12. clean return to the exploration shell;
13. completed encounter does not retrigger;
14. active-combat save rejection;
15. safe post-combat save/load;
16. umbrella case completion after the failure consequence;
17. canonical background/skills/failures/clues/deductions remain untouched;
18. all Slice 9-12 regressions;
19. all canonical interaction/evidence/deduction/dialogue/RPG/persistence regressions;
20. real main-scene startup.

The Web packaging gate also verifies the combat opponent art is physically present in the exported PCK.

## NEXT OPERATION

**Umbrella Quest Slice 14 — Full graphics production pass**

Execute without requesting design decisions:

1. Preserve every Slice 9-13 gameplay contract exactly unless a visual integration bug requires a narrow correction.
2. Upgrade all eight Umbrella Quest rooms from current authored reference/world-skeleton art to finished-production comic-book backgrounds.
3. Follow `VISUAL_DIRECTION.md` as authoritative:
   - polished comic-book illustration;
   - dark gritty city / institutional interiors;
   - strong ink silhouettes;
   - layered depth;
   - controlled dirty teal / charcoal / amber palette;
   - readable interaction staging;
   - no placeholder/greybox look.
4. Bring every room to a consistent final-style quality bar:
   - exterior entry / awning;
   - lobby;
   - front desk;
   - Lost & Found hall;
   - staff office;
   - storage room;
   - maintenance corridor;
   - loading bay / service exit.
5. Upgrade the player sprite and NPC staging art so Alex, Mina, the player, and the combat opponent feel like one coherent finished visual language.
6. Upgrade dialogue portraits for Alex and Mina to the same final comic-production style.
7. Add the minimum animation set that materially improves readability:
   - player movement;
   - idle presence;
   - witness presence where justified;
   - restrained combat feedback;
   - no animation system expansion for its own sake.
8. Add restrained lighting/FX polish compatible with Godot Web and the 640x480 budget:
   - rain;
   - practical light pools;
   - subtle room-specific motion where valuable;
   - no dynamic 3D or heavy post-processing.
9. Polish the combat presentation so it feels embedded in the loading-bay scene rather than like an overlaid prototype while preserving the exact deterministic combat rules.
10. Preserve hotspot readability and avoid visual-detail clutter that harms interaction discovery.
11. Keep all critical art referenced as importable Godot resources so Web export cannot omit it.
12. Strengthen visual resource/PCK validation for every new production asset.
13. Protect all Slice 9-13 gameplay tests unchanged where possible.
14. Run all existing regressions and main-scene startup.
15. Update `ROADMAP.md`, `ARCHITECTURE.md`, and `CURRENT.md`.
16. Commit/push, follow CI and Web deployment to terminal status, and verify exact `main` head.

Do not start Slice 15 in the same turn unless the user explicitly asks for multiple slices.
