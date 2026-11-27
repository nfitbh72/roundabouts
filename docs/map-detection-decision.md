# Map detection decision

**Status:** decided, 27 November 2026
**Decision:** build two approaches side by side, compare them on the same junctions, then choose one (or combine them).

1. **Lanes first:** read the lane markings from a screenshot and build the roads outwards from them.
2. **OpenStreetMap:** take the road layout from OpenStreetMap data instead of from pixels.

Both produce the same output, so the display, the level editor and the simulation never need to know which one made a level.

## Where this started

The first version of map import (`simulation/map_import/`) sorts pixels by colour. Grey pixels are tarmac and white or yellow pixels are paint. It then traces the edges of the tarmac and turns each painted mark into a short lane line.

On an aerial screenshot of a real junction (the B83 at Pretoria Parade, Hornsby, Sydney), it found most of the lane dashes, but the road edges were poor. Three refinements were tried:

| Attempt | Result |
| --- | --- |
| Fixed grey range, then filling small gaps and dropping small blobs | Clutter gone, but the car park, a pale grey roof and pavements all counted as road. |
| Learning the tarmac colour of each image from the pixels next to lane paint | Better separation, but the road broke up into speckle wherever the tarmac texture varied. |
| The same, averaged over 4×4 blocks | Worse. The car park's own bay lines pulled the car park's colour into the sample. |

The underlying problem is that road and car park differ by only about 10 points per colour channel (0 to 255), while ordinary tarmac texture varies by about 20. **Colour alone cannot tell a road from a car park.** Any approach that works has to use structure as well.

## Approach 1: lanes first

Instead of finding the road and then the lanes inside it, find the lanes and build the road around them.

### Why it might work

- Lane markings are the most distinctive thing on a road from above: bright, thin, and arranged in regular patterns.
- Car parks, roofs and pavements do not have dashes that line up end to end down a long corridor.
- The spacing between lane lines gives the lane width in pixels. Real lanes are 3.0 to 3.7 metres wide, so this also gives the **scale** of the screenshot, which the simulation needs and which a screenshot does not otherwise reveal.
- It produces lanes directly, and lanes are what the traffic simulation runs on.

### Steps

1. **Find paint.** Pixels clearly brighter than the area around them (or yellow), grouped into connected marks. Judging brightness against the surroundings, rather than against a fixed level, picks up worn paint.
2. **Keep lane-like marks.** A mark must be long and thin, with tarmac on both sides. This rejects roof edges, building outlines and the white lines along the kerb.
3. **Chain dashes into lane lines.** Join marks that point the same way and line up end to end, allowing for gentle curves. Prototype settings: directions within 20°, gaps up to 45 pixels, and a sideways drift of up to 3 pixels plus 12% of the distance. Keep chains of three or more marks spanning at least 60 pixels. Each chain becomes a smoothed line through its marks. Lone solid lines are left out for now, because they are as often the edge of a building or kerb as a line between lanes.

   Dashes too faint or distant to make marks break up into specks of a pixel or two. These are found separately: a Hough transform finds straight rows of specks on tarmac, and a row counts as a lane line only if the colour either side matches. A kerb has road on one side and pavement on the other, and fails that test even where the pavement is as grey as the road.
4. **Group lane lines into roads.** Lane lines that run roughly parallel and about one lane width apart belong to the same carriageway.
5. **Measure the lane width** from the spacing between neighbouring lane lines.
6. **Place the road edges** by stepping outwards from the outermost lane line on each side until the tarmac ends, between 0.4 and 2 lane widths away. Where that is unclear along most of the line, draw no edge at all: a missing edge is easier to spot and fix than a wrong one.
7. **Join the roads up at the junction**, by extending the edges until they meet.

### Prototype result

Steps 1 to 6 are built, in `simulation/map_import/`. Step 7 is not. On the Hornsby screenshot, conversion takes under a second and finds:

- lane lines on every arm: two on the B83 north of the junction, three on the eastern B83 (from rows of specks), and the centre lines of Pretoria Parade and College Cres
- road edges along the western kerb of the B83, the northern side of Pretoria Parade and the western kerb of College Cres

Nothing is drawn on the car park, the roofs or the pavements. What it gets wrong or misses:

- **Junction markings.** Stop lines and the edges of the pedestrian crossings are rows of paint on tarmac too, so they come out as lane lines.
- **Most edges.** Where the tarmac merges with a car park or footpath, stepping outwards finds no clear end. Lines found as rows of specks are not yet used for edges at all: when they were, a row along a kerb put an edge on a church roof.
- **The junction itself**, which waits for step 7.

The next gain is in step 6: stepping outwards until the colour stops matching the tarmac beside the lane line, rather than until the colour-classified road mask ends. That is the same matching-sides idea that tells kerbs from lane lines, and it should give the eastern arm its edges.

### Known weaknesses

- Roads with no markings, or with worn paint, give it nothing to work with.
- Cars, shadows, trees and map labels cover or break up the paint.
- Screenshots vary in zoom, compression and colour between map services, so the settings will need tuning across many images.
- It cannot tell which side of the road traffic drives on. That has to come from the player or from where the junction is.
- The junction interior has no lane lines, so step 7 is guesswork that the level editor will need to correct.

## Approach 2: OpenStreetMap

[OpenStreetMap](https://www.openstreetmap.org/) is a free, editable map of the world whose data includes roads, and often lane counts, turn lanes, traffic signals and crossings. Instead of reading a picture, the game could ask for the roads within a couple of hundred metres of a chosen point.

### Why it might work

- The road layout is already known, so there is nothing to detect and no car park to confuse with a road.
- It is in real-world coordinates, so the scale is exact.
- Roads are tagged with useful details: `lanes`, `lanes:forward` and `lanes:backward`, `oneway`, `turn:lanes`, and the road type through `highway`.
- Real traffic signals (`highway=traffic_signals`) and crossings (`highway=crossing`) are mapped in many places. The game could show where the council actually put the lights.
- The driving side follows from the country.
- No image is involved at all, which satisfies the map conversion rule trivially.

### Steps

1. **Pick a place.** The player searches for an address or pans a map to the junction.
2. **Fetch the roads** in a small box around it, for example through the Overpass API.
3. **Project to metres**, using a flat approximation centred on the junction. The distortion is negligible over a few hundred metres.
4. **Read the lane counts** from the tags, falling back to sensible defaults for each road type where lanes are not tagged.
5. **Build the road edges and lane lines** by offsetting each road's centre line by the right number of lane widths.
6. **Shape the junction** where roads meet, by trimming and joining their edges.

### Known weaknesses

- **It changes the pitch.** The README promises "upload a screenshot of any junction". Picking a place on a map is a different experience, though arguably an easier one for the player.
- **The licence has obligations.** OpenStreetMap data is under the Open Database Licence (ODbL). The game must credit "© OpenStreetMap contributors". Level files built from the data are probably derivative databases, which would make shared levels ODbL-licensed too. This needs a proper check before launch, and none of this is legal advice.
- **The public servers are not for products.** The usage policies of the public Overpass, Nominatim (search) and map tile servers rule out heavy use by an app. A released game would need a commercial provider or its own server for data, search and the map shown while picking a place.
- **Detail varies by place.** Some areas have every lane and turn arrow tagged, others only the road's centre line. Defaults will be wrong sometimes.
- **Roads are mapped as centre lines.** Edges and lanes are built from offsets, so slip lanes, islands and odd junction shapes come out simplified.
- **Import needs a connection,** unless data is bundled or cached.

## Things common to both

- **One output format.** Both approaches produce the same junction geometry, `MapOutline` for now and a proper lane model later. Detection lives behind that boundary, so the rest of the game does not care where a level came from.
- **The level editor is needed either way.** Neither approach will be right every time, so players must be able to fix roads, lanes and junction shapes before playing or sharing.
- **Pure logic, as everywhere else.** Image analysis and data parsing go in `simulation/`, as pure functions with tests. Network requests and file loading stay out of it.
- **A hybrid is possible.** OpenStreetMap could provide the layout while a screenshot of the same place adds lane detail where OpenStreetMap has none, or the reverse.

## How the two will be compared

1. Choose about ten junctions of different kinds and countries: a simple crossroads, a large signalised junction, a staggered junction, a junction with slip lanes, one with faded paint and one left-hand-traffic junction. Hornsby is the first.
2. Run both approaches on each one.
3. Judge each result by how much a player would have to fix in the level editor before it is playable: missing or extra roads, wrong lane counts, misplaced edges.
4. Time-box each approach so the comparison happens before either becomes too polished to abandon.

Screenshots used for testing are copyrighted by the map services. They stay outside the repository and are never committed, in line with [map-conversion-decision.md](map-conversion-decision.md). Automated tests use painted synthetic images instead.

## Caveats

- Licence terms and usage policies were written from general knowledge in November 2026 and were not checked against the current OpenStreetMap Foundation policies. Verify before building on them.
- The prototype figures come from a single screenshot. They show the direction is promising, not that it works in general.
