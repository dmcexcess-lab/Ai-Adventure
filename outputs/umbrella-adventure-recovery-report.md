# Umbrella Adventure recovery report

Recovered and reconstructed on 2026-10-02 from the surviving `dmcexcess-lab/Ai-Adventure` repository and the rendered ChatGPT task **Finish Umbrella Adventure Graphics**.

## What was found

- Published `main` stopped at commit `0343311c1b0c0db5fedaa7f7b388a85be1911339` (Slice 16).
- The lost cloud workspace had two local-only commits:
  - `f60763c2c106f76ea592eeffe51b8ec679b54bcc` — 32-file graphics integration, never pushed.
  - `8adf9ef` — final rendered-review documentation, never pushed.
- The push failed because that workspace had no GitHub credentials. The remote never received either commit, and GitHub no longer had the first object available for fetch.
- The rendered work log nevertheless preserved exact filenames, byte counts, behavior contracts, test results, and all generated image outputs.

## Assets recovered

Nine distinct PNG outputs were downloaded from the rendered task into `art/recovered/finish_umbrella_graphics/`. Seven exact production files were restored to their intended runtime paths; their byte sizes match the missing commit’s stat exactly:

- `pc3_walk.png` — 1,262,185 bytes
- `pc3_motion.png` — 1,784,477 bytes
- `pc3_combat.png` — 1,596,872 bytes
- `alex_atlas.png` — 1,661,646 bytes
- `mina_atlas.png` — 1,890,017 bytes
- `intruder_atlas.png` — 2,456,794 bytes
- `evidence_atlas.png` — 1,935,964 bytes

Two rejected/alternate source generations remain in the recovery folder for provenance.

## Integration reconstructed

- Four-frame side/front/rear player walk cycles at 12 frames per second.
- Nine investigation and combat action clips.
- Strong 0.64–1.16 perspective scaling around an invariant foot pivot.
- Matched Alex and Mina room poses and portraits from one atlas per identity.
- Illustrated art for every evidence entry plus the recovered umbrella in-world and at case closure.
- Staged player/opponent combat presentation with repeat-input lock.
- Foot-based actor ordering and front-desk occlusion cropped from the accepted painting.
- Modal layering and compact 640×480 notebook, character, dialogue, combat, and ending layouts.
- Painted exterior main-menu background with DEVELOPMENT BUILD labeling retained.

The eight previously accepted room paintings and all investigation/RPG/combat mechanics remain unchanged.

## Verification

- Godot 4.7.2 imported all assets successfully.
- Every existing smoke suite passed.
- A new graphics-completion regression passed, covering the seven atlases, alpha/dimensions, clue illustration coverage, fixed gameplay footprint, depth range, directional animation, nine action clips, witness identity correspondence, and combat repeat-input rejection.
- A real OpenGL capture run on the project’s Radeon/Mesa renderer produced and reviewed all eight rooms plus far/near depth, walking, Alex/Mina dialogue, notebook, character profile, combat/action, and ending at 640×480.
- The render pass found and repaired modal draw-order, character-panel overflow, combat/HUD overlap, duplicate fighter staging, and ending-overlay cleanup defects.

## Preserved recovery branches

- `recovery/slice15-pc3-original` at `76c8834`
- `recovery/umbrella-production-rebaseline` at `6090fbb`

## Remaining status

The work is implemented and locally render-verified. It is not described as user-accepted art until the user reviews and accepts it. The next planned production operation is Slice 20: audio and settings.
