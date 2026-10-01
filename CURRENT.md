# Current

## Status

**Umbrella Quest Slice 16 — PC/#3 production implementation: IN PROGRESS**

Chapter One production is blocked.

The repository acceptance rule remains:

**User-accepted production-complete: the eight environment backgrounds only.**

Slice 16 is producing a credible deployed #3 candidate. Automated completion of this slice does not automatically change that acceptance statement.

## Problem being corrected

The accepted #3 source sheet is **2172x724**.

The prototype runtime atlas was only:

**216x72**

Its individual poses retained only about 62-70 pixels of vertical source detail, then were rendered around 130-175 pixels tall in the game.

That destructive downsample was the main reason the otherwise-correct scene-aware pose system looked soft and cheap beside the accepted backgrounds.

## Slice 16 implementation

The live player source is being replaced by:

`art/characters/pc3/pc3_reference_atlas_hd.webp`

Dimensions:

**864x288**

It is derived from the exact accepted source sheet. No new protagonist design or art-generation call is involved.

The six live pose regions now retain roughly 248-280 pixels of source height before downsampling into the room.

The following runtime behavior remains unchanged:

- same #3 identity;
- same costume;
- same six key poses;
- same room-authored resting angles;
- same movement-direction pose selection;
- same horizontal mirroring;
- same far/near perspective system;
- same bottom-center pivot;
- same fixed gameplay foot position;
- same loading-bay combat-pose override;
- same investigation/combat mechanics.

## Production status after Slice 16 implementation

Even after technical closure, #3 remains **pending user visual acceptance**.

The next production slice does not assume the current Alex/Mina/opponent/portrait assets are final.

## NEXT OPERATION AFTER SLICE 16

**Slice 17 — NPC + portrait art production**

1. Keep the accepted room backgrounds untouched.
2. Treat Alex, Mina, the loading-bay opponent, and both dialogue portraits as prototype until replaced/accepted.
3. Bring those characters to the environment quality bar.
4. Make room sprite and portrait identity correspondence obvious.
5. Stage NPC scale/perspective coherently inside their accepted rooms.
6. Keep gameplay/witness/combat rules unchanged.
7. Protect resource packaging and staging with tests.
8. Keep the title screen visibly marked DEVELOPMENT BUILD.
9. Do not claim user acceptance merely because CI passes.
10. Do not begin UI production or Chapter One in the same turn.
