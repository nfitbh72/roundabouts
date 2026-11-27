class_name OsmOutline
extends RefCounted
## Redraws OpenStreetMap roads as a [MapOutline]: each centre line widened into
## lanes, in metres across a square around the chosen point.
##
## Junctions are shaped simply. A road split into several ways is joined back
## into one. Where different roads meet, each road's lines stop where they run
## onto another road's tarmac, and the edges that meet there are joined into
## kerbs with rounded corners.

## Width of every lane, in metres. Real lanes are 3.0 to 3.7 metres wide.
const LANE_WIDTH: float = 3.5
## How far back from a corner its kerb starts to curve, in metres.
const CORNER_RADIUS: float = 6.0
## Pieces of line shorter than this, in metres, are left out as slivers.
const SHORTEST_PIECE: float = 1.0


## Returns the roads in [param extract] within the square of half-width
## [param radius] metres around [param centre]. The outline's coordinates are
## metres from the square's north-west corner.
static func build(extract: OsmExtract, centre: GeoPoint, radius: float) -> MapOutline:
	var size: Vector2 = Vector2(radius, radius) * 2.0
	var strips: Array[RoadStrip] = RoadChains.chained(
		strips_of(extract.roads, centre, Vector2(radius, radius)), LANE_WIDTH
	)
	var areas: Array[PackedVector2Array] = []
	for strip: RoadStrip in strips:
		areas.append(strip.area())
	var box: PackedVector2Array = LineClip.box(size)
	var edges: Array[PackedVector2Array] = []
	var lanes: Array[PackedVector2Array] = []
	for index: int in strips.size():
		var strip: RoadStrip = strips[index]
		var own_edges: Array[PackedVector2Array] = [strip.left_edge, strip.right_edge]
		edges.append_array(_visible(own_edges, index, areas, box))
		lanes.append_array(_visible(strip.dividers, index, areas, box))
	var kerbs: Array[PackedVector2Array] = KerbCorners.joined(edges, CORNER_RADIUS)
	return (
		MapOutline
		. new(
			Vector2i(size.round()),
			LineClip.at_least(kerbs, SHORTEST_PIECE),
			LineClip.at_least(lanes, SHORTEST_PIECE),
		)
	)


## Returns a strip for every drivable road in [param roads], in metres from
## [param centre] plus [param shift].
static func strips_of(roads: Array[OsmRoad], centre: GeoPoint, shift: Vector2) -> Array[RoadStrip]:
	var strips: Array[RoadStrip] = []
	for road: OsmRoad in roads:
		var line: PackedVector2Array = LocalProjection.line_to_metres(road.points, centre)
		if not RoadTypes.is_drivable(road.tags) or line.size() < 2:
			continue
		var lanes: RoadLanes = RoadLanes.from_tags(road.tags)
		var shifted: PackedVector2Array = Transform2D(0.0, shift) * line
		var strip: RoadStrip = RoadStrip.along(shifted, lanes.total, lanes.way_position, LANE_WIDTH)
		strip.nodes = road.node_ids
		strips.append(strip)
	return strips


## Returns the parts of [param lines] inside [param box] and off every road
## but road [param own].
static func _visible(
	lines: Array[PackedVector2Array],
	own: int,
	areas: Array[PackedVector2Array],
	box: PackedVector2Array,
) -> Array[PackedVector2Array]:
	var pieces: Array[PackedVector2Array] = LineClip.inside(lines, box)
	for index: int in areas.size():
		if index != own:
			pieces = LineClip.outside(pieces, areas[index])
	return pieces
