# Project North Star

## Product

**ANAMNESIS: The Third Witness** is a browser-playable, 1990s-style point-and-click detective adventure with light RPG systems.

The target experience is closer to a compact investigative CRPG/adventure hybrid than to an item-combination comedy adventure. The player should feel like a detective inside a reality that is becoming logically impossible.

## Non-negotiable player-facing rules

1. **Clues beat keys.** Progress comes from understanding evidence, not guessing which inventory object belongs on which hotspot.
2. **The notebook is gameplay.** Evidence, contradictions, witness claims, hypotheses, and deductions are persistent interactive state.
3. **No pixel hunting.** Important hotspots are readable; accessibility can reveal interactables without solving deductions.
4. **No arbitrary verb roulette.** A small context-action set replaces classic LOOK/USE/TALK spam.
5. **RPG skills expose routes, not grind.** Skills create alternate observations, dialogue leverage, and deduction confidence. There is no combat loop and no XP farming.
6. **Failure changes the situation.** Failed checks, poor choices, and combat outcomes should create alternate routes, incomplete evidence, pressure, injury, or harder conversations rather than arbitrary dead ends.
7. **Canon stays mysterious.** Chapter One establishes the rules through evidence and contradiction. It does not dump the cosmology.
8. **Web first.** Everything must remain practical in Godot Web export and playable in desktop Firefox.
9. **Finite scope.** The engine exists to ship the Umbrella Quest vertical slice, Chapter One, and later chapters—not to become a general adventure framework.
10. **Combat is bounded, not dominant.** Combat is part of the finished concept and must be proven in Umbrella Quest, but investigation remains the primary grammar.\n11. **Repository handoff.** Every completed slice ends with an updated `CURRENT.md` containing the exact next operation.

## Chapter One completion definition

Chapter One is done when a fresh player can open the deployed web build, start a new game, complete the full investigation, reach the chapter ending, save/load reliably, and encounter no progression blocker in the protected test path.

At that point the assistant says:

> ok final slice done play chapter one
