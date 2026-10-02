# Current

## Status

**Umbrella Quest production rebaseline: ACTIVE**

Chapter One is blocked.

The user has explicitly corrected the production-readiness assessment:

> **The eight room backgrounds are the only production-complete part of Umbrella Quest so far.**

That statement is authoritative.

The functional gameplay vertical slice remains valuable and protected, but green tests or working systems do not imply production presentation.

## Production-complete

### Environment backgrounds

All eight Umbrella Quest room backgrounds are accepted as the finished environment-quality bar:

1. Exterior Entry / Awning
2. Community Center Lobby
3. Front Desk
4. Lost & Found Hall
5. Staff Office
6. Storage Room
7. Maintenance Corridor
8. Loading Bay / Service Exit

Runtime resources remain under:

`art/demo/production/`

These backgrounds establish the production target for every unfinished category.

## Not production-complete

### PC / #3

The current six-pose atlas and scene-aware perspective system are a **technical/reference prototype**.

They successfully prove:
- one consistent identity;
- per-room angles;
- direction-aware pose selection;
- perspective scaling;
- combat pose switching.

They do **not** prove finished sprite quality, animation quality, scene integration, or user acceptance.

The accepted PC/#3 design remains a useful master identity reference. Future production work must extend that identity rather than redesigning the protagonist.

### NPCs and portraits

Alex, Mina, and the loading-bay opponent are functional placeholders/pre-production assets.

Their current room sprites and portraits are not production-complete.

### UI

The HUD, notebook, dialogue UI, profile selection, character panel, combat UI, save/load controls, main menu, and resolution panel remain functional/prototype interfaces.

They are not production-complete.

### Animation and staging

Current walk bob, idle motion, ambient drawing, and combat Tweens are implementation scaffolding.

Finished authored animation, room depth/occlusion, character grounding, and transition presentation remain incomplete.

### Audio

`audio/` currently contains no production audio.

Room ambience, UI cues, interaction feedback, combat audio, music decisions, and volume controls remain incomplete.

### Menus/settings/accessibility

There is no finished Settings implementation.

Final accessibility/readability controls, save/load presentation, title flow, and end-of-demo flow remain incomplete.

### Ending

The current case-closed panel proves state resolution only.

It is not the finished ending presentation.

## Functional systems that must be preserved

The production passes must not casually rewrite the already-proven gameplay contracts:

- eight-room graph;
- click-to-walk and approach behavior;
- evidence acquisition;
- notebook/hypothesis loop;
- Alex/Mina witness logic;
- four RPG backgrounds;
- deterministic skill checks;
- alternate/failure routes;
- bounded loading-bay combat;
- combat victory/disengage/consequence paths;
- demo-local persistence;
- canon isolation.

## Production acceptance rule

Automated tests can prove correctness and packaging.

They cannot declare a visual/audio/UI category production-complete.

For Umbrella Quest, a category is production-complete only when:
1. its final assets/behavior are deployed;
2. its technical regressions pass;
3. the user has had a chance to see/play it;
4. the user has not rejected the result.

Chapter One cannot begin merely because Slice 20 tests are green.

It begins only after **Slice 21 — Umbrella production acceptance gate** is explicitly accepted by the user.

## NEXT OPERATION

**Slice 15 — Character production**

Priority order:

1. PC/#3 final in-world production assets and animation, using the accepted identity reference and OpenAI image generation rather than fal.
2. Scene-specific angle/perspective integration across all eight finished backgrounds.
3. Alex final room art + portrait/expression set.
4. Mina final room art + portrait/expression set.
5. Loading-bay opponent final art + combat-reaction set.
6. Replace prototype bob/Tween character motion only where final authored animation exists.
7. Preserve exact gameplay foot positions, room graph, investigation logic, RPG rules, and combat math.
8. Add/strengthen production-character validation.
9. Deploy for visual review.
10. Do **not** call the character category production-complete until the user accepts the deployed result.

Do not begin Slice 16 in the same turn unless the user explicitly asks for multiple slices.
