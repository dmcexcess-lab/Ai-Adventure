# Visual Direction

## Finished-product target

ANAMNESIS and the Umbrella Quest vertical slice use a **polished comic-book adventure** presentation.

The intended feeling is:
- dark, gritty urban environments;
- hand-authored comic-panel composition;
- stylized realism rather than parody;
- heavy silhouette and ink language;
- rainy streets, dirty practical light, worn public interiors, service spaces, and late-night city texture;
- premium 1990s adventure-game readability with modern clarity.

The Umbrella Quest vertical slice is the first production proof of this visual language. Its art is non-canon, but its presentation rules are authoritative for Chapter One.

## Reference-room standard

Slice 9 establishes the Umbrella Quest community-center lobby as the visual reference room.

A reference room must communicate all of these before interaction begins:

1. **Where am I?**
2. **Where can I plausibly walk?**
3. **Who can I talk to?**
4. **Which props are compositionally important?**
5. **What is the scene's emotional temperature?**

The player should not need floating labels to understand the room.

## Environment language

### Composition

Every primary room should read as a deliberate comic panel:
- one dominant focal area;
- one or two secondary areas;
- clear foreground, midground, and background separation;
- strong diagonals or perspective lines that guide the eye toward usable space;
- negative space around characters and important props;
- foreground occlusion only when it adds depth without concealing navigation.

### City tone

Use:
- wet pavement;
- rain-streaked glass;
- reflected signage;
- stained concrete;
- old tile;
- chipped paint;
- paper notices;
- maintenance labels;
- tired fluorescent light;
- sodium/amber practical light;
- cyan/blue exterior spill;
- occasional controlled red accent.

Avoid:
- clean generic sci-fi;
- broad cheerful color blocking;
- engine-default boxes as final props;
- overly dark scenes where interaction becomes guesswork.

### Ink and texture

Finished assets should favor:
- heavy outer contours;
- selective interior linework;
- broad shadow shapes;
- limited cross-hatching/noise;
- painterly color blocks beneath ink;
- visible wear and material texture at focal props.

Texture should support forms, not dissolve them.

## Palette

Default visual family:
- charcoal / near-black: structure and deep shadow;
- desaturated slate blue: city ambient;
- dirty teal/cyan: cool practical accents;
- nicotine amber: warm interior light;
- muted burgundy/red: warning/focal accent;
- off-white newsprint: readable text and paper.

Each room may bend the palette, but should remain inside the same noir-comic family.

## Lighting

Lighting is authored, not simulated for its own sake.

Use light to:
- silhouette characters;
- separate walkable floor from background;
- reveal important props;
- create readable pools of interaction;
- imply depth through warm/cool contrast.

Avoid bloom-heavy presentation. Hard-edged comic shadow shapes and soft painted pools are preferred.

## Character language

Characters use:
- readable full-body silhouettes;
- slightly exaggerated comic-book proportions;
- clear pose language;
- limited animation with strong key poses;
- consistent sprite scale across rooms;
- dark clothing shapes separated by rim/highlight accents.

Dialogue can use portrait art or cropped bust art when the face needs to carry emotion.

Portraits should be more detailed than room sprites, but clearly depict the same design.

## UI language

The UI should feel like part of the comic/noir product, not a Godot tool panel.

Rules:
- dark translucent or near-opaque panels;
- hard rectangular framing;
- thin warm/cool accent rules;
- restrained border treatment;
- off-white body text;
- teal/cyan active state;
- amber for evidence emphasis;
- muted red only for refuted/danger states;
- generous internal spacing;
- button labels that read like designed controls, not debug widgets.

The UI may echo dossier/case-file language but usability wins over literal paper simulation.

## Dialogue presentation

Dialogue should feel like a composed comic panel:
- portrait-capable layout;
- witness identity visually separated from response choices;
- current line given more space than metadata;
- numbered responses clearly scannable;
- evidence presentation visually distinct from normal topics;
- no modal that looks like a raw settings form.

## Notebook presentation

The notebook is an investigation interface:
- evidence list and detail hierarchy must be obvious;
- source/reliability metadata is secondary to clue title and detail;
- hypothesis state must be readable at a glance;
- filters should not dominate the screen;
- established/supported/refuted/unsupported states need consistent visual treatment.

## Combat presentation

Combat is part of the full concept and must share the same world/presentation language.

Combat should:
- occur in authored room compositions rather than a visually unrelated battle screen;
- preserve comic-panel staging;
- use strong silhouettes and readable intent/action feedback;
- keep UI compact;
- avoid arcade/JRPG visual mismatch unless a later explicit design decision changes this.

Slice 9 does not implement combat rules. It establishes a visual language that later combat must inherit.

## Production rule

From Slice 9 onward:
- greyboxes may exist only as temporary implementation scaffolds;
- room composition is authored for finished art from the start;
- Umbrella Quest is a vertical slice, not disposable UI test content;
- Chapter One production stays paused until the umbrella vertical slice is polished and mechanically representative.
