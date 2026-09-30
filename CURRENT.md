# Current

## Status

**Umbrella Quest Slice 9 — Visual direction foundation: COMPLETE**

Chapter One production remains paused.

Umbrella Quest is now the project's non-canon **visual and mechanical vertical slice** and the repository roadmap has been re-baselined around it.

## Authoritative visual target

The finished-product direction is now locked as:

**polished comic-book adventure presentation with dark, gritty cityscapes.**

`VISUAL_DIRECTION.md` is authoritative for:

- comic-panel composition;
- dark urban palette;
- environment wear/material language;
- practical lighting;
- character silhouette/sprite treatment;
- portrait treatment;
- case-file/noir UI;
- later combat presentation.

The visual target is intentionally much higher than the original rectangle/greybox demo.

## Reference room

The Umbrella Quest community-center lobby is now the first visual reference room.

The old primitive room blocks have been replaced by an authored illustrated lobby containing:

- rain-streaked city windows;
- exterior skyline and reflected city light;
- worn civic-building architecture;
- physical lost-and-found board;
- vending machine;
- umbrella rack;
- front desk;
- exit door;
- floor perspective/tile staging;
- cool exterior versus warm practical-light contrast;
- heavy comic outline/shadow language.

Existing hotspot positions and interaction behavior remain intact over the illustration.

## Character visual language

The demo player is now represented by a full-body comic-noir sprite instead of geometric body blocks.

The visual language uses:

- heavy outer contour;
- broad shadow shapes;
- muted urban clothing;
- restrained warm skin tone;
- limited high-value detail;
- readable silhouette at room scale.

This is the baseline for later production sprites rather than a claim that the Slice 9 sprite is final animation-quality art.

## Dialogue portrait language

Alex now has a dedicated comic-book portrait integrated into the conversation panel.

The dialogue layout now provides a portrait-capable composition with:

- identity header;
- role line;
- trust state;
- large portrait area;
- larger authored dialogue-line area;
- numbered topic/evidence actions.

## Comic-noir UI skin

A reusable `comic_noir_theme.tres` now styles the reference slice.

The skin establishes:

- near-black/charcoal panels;
- restrained teal/cyan interactive accent;
- warm amber evidence/focus accent;
- off-white body text;
- hard rectangular borders;
- stronger hover/pressed/focus states;
- designed ItemList selections;
- consistent separators.

The notebook, hypotheses, character panel, dialogue panel, and bottom interaction strip now share the same visual family.

## Web-safe art pipeline

Source art is stored as raw SVG under `art/demo/`.

At runtime the reference scene:

1. reads the SVG text;
2. rasterizes it through Godot `Image.load_svg_from_string()`;
3. creates an `ImageTexture`;
4. applies it to the room/background/sprite/portrait controls.

This keeps authored source art resolution-independent while avoiding reliance on editor-generated SVG import metadata during headless and Web validation.

## Roadmap re-baseline

The authoritative production order is now:

1. Slice 9 — visual direction foundation — **complete**
2. Slice 10 — multi-room Umbrella Quest world skeleton
3. Slice 11 — Umbrella investigation loop
4. Slice 12 — Umbrella RPG integration
5. Slice 13 — Umbrella combat slice
6. Slice 14 — Umbrella full graphics production pass
7. Slice 15 — Umbrella polish/usability closure
8. Slice 16+ — return to Chapter One

Combat is now explicitly part of the finished concept, but remains bounded rather than replacing investigation as the primary gameplay grammar.

## Validation

Godot 4.7.2 CI passes:

1. visual-direction/theme resource validation;
2. raw SVG art-file validation;
3. runtime SVG rasterization;
4. reference-room background texture creation;
5. player sprite texture creation;
6. dialogue portrait texture creation;
7. comic-noir theme application;
8. preserved Umbrella Quest movement/hotspots;
9. hotspot reveal;
10. notebook modal;
11. character modal;
12. dialogue modal;
13. local demo save/load;
14. canonical ANAMNESIS state isolation;
15. all protected interaction/evidence/deduction/dialogue/RPG/persistence regressions;
16. real main-scene startup.

## NEXT OPERATION

**Umbrella Quest Slice 10 — Multi-room world skeleton**

Execute without requesting design decisions:

1. Expand Umbrella Quest from the reference lobby into the complete compact demo map:
   - exterior entry / awning;
   - lobby;
   - front desk;
   - Lost & Found hall;
   - staff office;
   - storage room;
   - maintenance corridor;
   - loading bay / service exit.
2. Build each room with final-art composition in mind from the start:
   - comic-noir palette;
   - authored focal areas;
   - clear walkable staging;
   - foreground/midground/background separation;
   - readable interaction silhouettes.
3. Reuse the Slice 9 comic-noir theme, sprite scale, and portrait language.
4. Establish all room transitions and spawn points.
5. Keep the umbrella story content lightweight/placeholding in this slice; full investigation content belongs to Slice 11.
6. Add representative hotspots/NPC positions sufficient to evaluate navigation and visual readability.
7. Keep Umbrella Quest state isolated from canonical Chapter One state.
8. Add protected tests proving:
   - every demo room loads;
   - every required transition target exists;
   - the whole room graph is traversable;
   - no primary room is orphaned;
   - Slice 9 visual assets/theme still load.
9. Run all existing regressions and main-scene startup.
10. Update `ROADMAP.md`, `ARCHITECTURE.md`, and `CURRENT.md`.
11. Commit/push, follow CI and Web deployment to terminal status, and verify exact `main` head.

Do not start Slice 11 in the same turn unless the user explicitly asks for multiple slices.
