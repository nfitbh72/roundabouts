# Map conversion decision

**Status:** decided, 27 November 2026
**Decision:** every uploaded map image is converted into the game's own art style, with nothing left of the original image.

## The decision

A screenshot of a junction is only ever an input. The game reads the road layout from it and redraws the junction entirely in the game's own style. No part of the original image appears in the finished level.

This applies to every level, without exception:

- **Pre-made levels** that ship with the game
- **User-contributed levels**, whether played privately or shared with others

## What this means in practice

- A level is stored as data: roads, lanes, entry and exit points, and scenery. It is not stored as a picture.
- Level files contain no pixels from the source image, whether as a background, a texture or a thumbnail.
- Level previews and thumbnails are rendered from the game-style version.
- Shared levels never include the source image, so it never reaches the Workshop or other players.
- Anything in the source image that is not part of the layout, such as map labels, logos, watermarks and satellite imagery, is dropped.

## Why

- **Copyright.** Screenshots from commercial map services are copyrighted. Shipping or sharing them would put the game and its Workshop content at risk. Keeping only the redrawn layout greatly reduces that risk. This is not legal advice, and it is worth a proper check before launch.
- **One consistent look.** Every junction looks like it belongs in the same game, whatever the source image looked like.
- **Small level files.** Layout data is far smaller than an image, which helps with sharing.
- **The roundabout wrap-up.** Superimposing a roundabout needs the junction as geometry, not as a picture.

## Still to decide

- **Tracing reference during import.** Fixing a badly detected junction is much easier with the screenshot visible underneath. Whether the level editor may show it temporarily on the player's own machine, discarded once the level is saved, is not yet decided.
- **How the conversion works.** The detection method is a separate decision and remains the riskiest feature in the game.
