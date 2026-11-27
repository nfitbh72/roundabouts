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
6. **Place the road edges** by stepping outwards from the outermost lane line on each side until the colour stops matching the tarmac right beside that line, between 0.4 and 2 lane widths away. Comparing with the road's own tarmac tells it from a pavement of almost the same grey. If the outermost line gives no clear answer, try the next line in, but only accept an edge that lies beyond the outermost line. Lines that meet another line at a steep angle are stop lines, crossings or lane lines at the mouth of a junction, and are not used for edges. Where nothing gives a clear answer, draw no edge at all: a missing edge is easier to spot and fix than a wrong one.
7. **Join the roads up at the junction**, by extending the edges until they meet.

### Prototype result

Steps 1 to 6 are built, in `simulation/map_import/`. Step 7 is not. On the Hornsby screenshot, conversion takes about half a second and finds:

- lane lines on every arm: two on the B83 north of the junction, three on the eastern B83 (from rows of specks), and the centre lines of Pretoria Parade and College Cres
- road edges along both kerbs of the B83 north of the junction, the southern kerb of the eastern B83, the eastern kerb of College Cres and a short stretch of Pretoria Parade

Nothing is drawn on the car park, the roofs or the pavements, and no edge is drawn in the wrong place. What it gets wrong or misses:

- **Junction markings.** Stop lines and the edges of the pedestrian crossings are rows of paint on tarmac too, so they come out as lane lines. They are kept out of edge building.
- **Some edges.** Most of Pretoria Parade, the western kerb of College Cres and the northern side of the eastern B83 have none. Usually a row of kerb specks has been taken for a lane line, and the edge beside it is refused because it would sit inside that line.
- **The junction itself**, which waits for step 7.

Each wrong edge found along the way was replaced by a rule that leaves the edge out instead, so what is drawn can be trusted, but too little is drawn. The next gains are in telling kerb specks from lane specks, and in step 7.

### A second Hornsby screenshot

A sharper capture of the same junction (1887 × 1518) did worse: more lines that follow kerbs and medians, the clearly visible dashes on the Pacific Highway missed, and three road edges at the usual working size or none at full size.

Every setting is a fixed number of pixels, tuned on the first screenshot, where a lane was about 34 pixels wide. That explains the failure at full size, where lanes are about 50 pixels wide. It does not explain the failure at the usual working size, where lanes measure about 35 pixels, the same as the first screenshot. There the difference is the capture itself: a different aerial photo, different shadows, and street names and road numbers written along every road.

Working at one standard scale was tried: measure the lane width from a first look for lane lines, resize the screenshot so a lane is 34 pixels wide, then look again. The measurement itself is reliable, agreeing to within a few pixels at every size tried. But on copies of the first screenshot shrunk and enlarged to imitate other zoom levels, it changed the results by at most one line and one edge. Resizing cannot restore detail a capture never had. The code was set aside rather than committed.

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
- Roads are tagged with useful details: `lanes`, `lanes:forward` and `lanes:backward`, `oneway`, `turn:lanes` (and `turn:lanes:forward` and `turn:lanes:backward` on two-way roads), `placement`, and the road type through `highway`.
- Real traffic signals (`highway=traffic_signals`, often with `traffic_signals:direction`) and crossings (`highway=crossing`, or `crossing=traffic_signals` on a signal node) are mapped in many places. The game could show where the council actually put the lights.
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
- **The licence has obligations.** OpenStreetMap data is under the Open Database Licence (ODbL). The game must credit OpenStreetMap and make clear the data is under the ODbL; "© OpenStreetMap contributors", linked to openstreetmap.org/copyright, does both. Whether a level file is a derivative database (shared levels would then be ODbL too) or a produced work is not settled: see the prototype result below. This needs a proper check before launch, and none of this is legal advice.
- **The public Overpass server is not for products.** Its policy says commercial use "should use self-hosted or paid Overpass servers". Nominatim (search) tolerates searches started by players of an app at moderate volume, and the tile server allows apps but not offline use. A released game would need its own or a paid Overpass server at least. Details are in the prototype result below.
- **Detail varies by place.** Some areas have every lane and turn arrow tagged, others only the road's centre line. Defaults will be wrong sometimes.
- **Roads are mapped as single lines.** Edges and lanes are built from offsets, so islands and odd junction shapes come out simplified. Busy roads are often mapped as one line per direction, and a `placement` tag can say the line follows a lane marking rather than the middle of the road, so the offsets must read it.
- **Import needs a connection,** unless data is bundled or cached.

### Prototype result

Built in `simulation/osm_import/`, with the network request in `display/osm/osm_importer.gd`. The title screen has latitude and longitude fields and a **Fetch from OpenStreetMap** button. The game asks the public Overpass API for every road for cars in a 300-metre square, widens each road's line into lanes 3.5 metres wide, and draws the result with the same `MapOutlineView` as a screenshot, with "© OpenStreetMap contributors" in the corner, linked to the copyright page. No image is involved at any point.

Steps 2 to 6 are built, step 6 simply. Placing the point is typing coordinates, standing in for step 1. Junctions are shaped in three passes:

1. **Rejoin split roads.** OpenStreetMap splits a road into a new way wherever its tags change, which at Hornsby happens every few dozen metres. Ways that share an end node are joined back into one strip when they are the only two there, or when they carry straight on (turning by less than 35°) while another road branches off, as where the slip road joins the B83. Where the lane count changes, the edges taper over about three metres per metre of step, lane lines that line up carry on, and the line of a new lane starts at the joint.
2. **Clear the junction.** Each road's lines stop where they run onto another road's tarmac.
3. **Join the kerbs.** Where one road's edge stops at another's, the two cut ends land on the same point. Edges that meet there are joined into one kerb, with the corner rounded off over up to six metres. Edges that meet all the way round become closed islands.

On the Hornsby junction (-33.70849, 151.09851, between the two nodes the B83 shares with Pretoria Parade) it draws:

- **every arm, in full and to scale:** the B83 north and east of the junction, Pretoria Parade, College Crescent and the side streets around them, with straight, unbroken edges
- **the shape of the junction:** the B83 north of the junction as two one-way carriageways with a median between them, the two-lane left-turn slip road from the north arm to the east arm with its triangular island, and College Crescent's split approach around its traffic island
- **continuous kerbs:** every corner rounded, the slip road merging smoothly into the B83, the median and both islands closed with rounded noses, and Pretoria Parade tapering where it widens
- **a believable lane count on every arm**, because every road at the junction has its lanes tagged

What OpenStreetMap knows about Hornsby, within 70 metres of the junction:

| Arm | Tagged |
| --- | --- |
| B83 north, southbound | 4 lanes, `turn:lanes=left\|left\|through\|right`, plus the 2-lane slip road (`left\|left`) with a give-way at its end |
| B83 north, northbound | 2 lanes |
| B83 east | 4 lanes, 3 towards the junction (`turn:lanes:backward=left;through\|right\|right`) and 1 away, widening to 5 further east; `placement:backward=right_of:3` says the line is drawn between the two directions |
| Pretoria Parade | 4 lanes at the junction, approach `left\|` (two lanes, the left one turning left), narrowing to 2 |
| College Crescent | split approach: 1 lane southbound, 2 northbound, joining into 2 two-way lanes |

- **Signals:** five `highway=traffic_signals` nodes within 25 metres of the centre, one for each approach, each with `traffic_signals:direction`, which gives roughly where the stop lines are.
- **Crossings:** five signalised pedestrian crossings. Two are tagged on the signal node itself (`highway=traffic_signals` with `crossing=traffic_signals`); the rest are `highway=crossing` with `crossing=traffic_signals`, and most have `button_operated` and audible-signal tags. The crossings are also mapped as `footway=crossing` ways. Unsignalled side-street crossings are tagged `crossing=unmarked`.
- **Not tagged:** lane widths, kerb lines (beyond a few kerb nodes at crossings), stop lines and the signal timings.

#### Compared with lanes first

| | Lanes first (first screenshot) | OpenStreetMap |
| --- | --- | --- |
| Arms drawn | lane lines on every arm; edges on parts of four arms | every arm, with both edges |
| Lane counts | guessed from the lines found | tagged on every road at the junction, with turn arrows |
| Slip road, carriageways, islands | not found | all present, with rounded kerbs |
| Scale | unknown | exact |
| Positions | within a pixel or two where found | follow the mapped lines; widths assumed, so a lane or so out where the real lanes are wider or narrower |
| Signals and crossings | none | where they are, and which way they face |
| What breaks it | a different capture of the same place | a busy server: 4 of 9 requests in an hour failed, twice "at capacity" and twice with no answer within 40 seconds |

Still missing from the junction: lane lines stop at its edge rather than guiding traffic through it, they are also cut where a side road meets a main road, every corner gets the same six-metre radius, and there are no stop lines or crossings drawn yet, though OpenStreetMap knows where they are.

For Hornsby, OpenStreetMap is better on almost everything a player would otherwise fix in the editor. Its weakness is exact positions: a mapped line can be a metre or two off, and lane widths are assumed. The hybrid suggested below would cover exactly that.

#### What the record got wrong

Checked against the OpenStreetMap wiki and OSM Foundation policies on 27 November 2026:

- **Tags.** The list missed `placement`, `placement:forward` and `placement:backward`, which say which lane marking a way is drawn along. Hornsby needs them: without them, the eastern B83 came out a whole lane off. Signal nodes can double as crossings, so finding crossings means checking `crossing=traffic_signals` on signal nodes as well as `highway=crossing`.
- **Overpass.** The usage limit for the public server is about 10,000 queries and 1 GB a day, and its documentation lists "setting up an app for more than just OSM mappers and relying on the public instances as backend" as problematic behaviour. A User-Agent identifying the app is required; the game sends `RoundaboutsAreBetter/0.1 (prototype)`. When at capacity, the server itself replies that it "is intended for browser-based and human-operated tools". Fine for this prototype, not for a release.
- **Nominatim** (address search) is not ruled out for an app. Searches each started by a player are allowed at moderate volume, at most one per second, with an identifying User-Agent, cached results and no search-as-you-type.
- **Map tiles** for a place picker are allowed for apps, with visible attribution, but not offline. As with Nominatim, access to the OSM Foundation's servers "may be withdrawn at any point" for commercial services.
- **Attribution.** For games, the attribution guidelines allow the credit on a splash screen, in the game view, the menus or the credits, as long as it links to more information. The prototype shows it whenever OpenStreetMap roads are on screen, which is more than required.
- **Licence of level files.** The record called them "probably derivative databases". The guidelines do not say. A result is a produced work unless it is meant for getting the original data back out, and a level file is a list of road positions, so it could fall on either side. An extract of fewer than 100 features, taken once, is insubstantial, and one junction is about that size. But repeated extracts for the same project count together, so a game shipping many pre-made junctions may not qualify, and a produced work made from a modified database still has to offer that database under the ODbL. This is for a lawyer before launch.

## Where this stands, 27 November 2026

Lanes first has reached the point where each fix is tuned to the screenshot in front of it. On the first Hornsby screenshot every edge it draws is real, but it draws too little. On a sharper screenshot of the same junction it does worse, for reasons that have little to do with the junction itself: the aerial photo, the shadows and the map labels. A capture of the same place should not change the answer this much.

So the next step is the OpenStreetMap prototype, with the trial tool (`tools/try_maps.sh`) and the lanes-first code kept as they are for the comparison. A hybrid remains possible: OpenStreetMap for the layout and lane counts, and the screenshot only to refine where the lines sit.

The OpenStreetMap prototype now exists, and on Hornsby it beats lanes first on layout, lane counts, scale and signals. The comparison still needs the other junctions on the list before choosing, especially ones less carefully mapped than Hornsby.

## Things common to both

- **One output format.** Both approaches produce the same junction geometry, `MapOutline` for now and a proper lane model later. Detection lives behind that boundary, so the rest of the game does not care where a level came from.
- **The level editor is needed either way.** Neither approach will be right every time, so players must be able to fix roads, lanes and junction shapes before playing or sharing.
- **Pure logic, as everywhere else.** Image analysis and data parsing go in `simulation/`, as pure functions with tests. Network requests and file loading stay out of it.
- **A hybrid is possible.** OpenStreetMap could provide the layout while a screenshot of the same place adds lane detail where OpenStreetMap has none, or the reverse.

## How the two will be compared

1. Choose about ten junctions of different kinds and countries: a simple crossroads, a large signalised junction, a staggered junction, a junction with slip lanes, one with faded paint and one left-hand-traffic junction. Hornsby is the first.
2. Run both approaches on each one. For the screenshot approach, `tools/try_maps.sh <folder>` converts every screenshot in a folder and writes a page showing the lines found over each screenshot, with lane and edge counts compared to the previous run.
3. Judge each result by how much a player would have to fix in the level editor before it is playable: missing or extra roads, wrong lane counts, misplaced edges.
4. Time-box each approach so the comparison happens before either becomes too polished to abandon.

Screenshots used for testing are copyrighted by the map services. They stay outside the repository and are never committed, in line with [map-conversion-decision.md](map-conversion-decision.md). Automated tests use painted synthetic images instead.

## Caveats

- The licence and usage-policy notes in the Approach 2 weaknesses and prototype result were checked against the OpenStreetMap wiki and OSM Foundation pages on 27 November 2026. They are a reading of those pages, not legal advice.
- The OpenStreetMap result comes from a single, well-mapped junction. Detail varies a lot from place to place.
- The lanes-first figures come from a single screenshot. They show the direction is promising, not that it works in general.
