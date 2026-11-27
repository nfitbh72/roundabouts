class_name LaneGroups
extends RefCounted
## Works out how wide the lanes are, and which lane lines belong to the same road.

## Largest angle between two lane lines that still count as parallel.
const PARALLEL_DEGREES: float = 15.0
## Plausible lane widths, in pixels. Closer lines are double lines; further ones
## have a lane line missing between them.
const MIN_LANE_WIDTH: float = 8.0
const MAX_LANE_WIDTH: float = 80.0
## Lane width to assume when no two lane lines run side by side.
const DEFAULT_LANE_WIDTH: float = 24.0
## Lane lines up to this many lane widths apart belong to the same road.
const NEIGHBOUR_REACH: float = 1.6
## Spacing between the points used to measure the distance between two lines.
const SAMPLE_SPACING: float = 8.0


## Returns the typical width of a lane, in pixels, from the spacing between
## neighbouring [param lines].
static func lane_width(lines: Array[PackedVector2Array]) -> float:
	var widths: Array[float] = []
	for a: int in lines.size():
		var nearest: float = INF
		for b: int in lines.size():
			if a != b:
				nearest = minf(nearest, spacing(lines[a], lines[b]))
		if nearest >= MIN_LANE_WIDTH and nearest <= MAX_LANE_WIDTH:
			widths.append(nearest)
	return Median.of(widths, DEFAULT_LANE_WIDTH)


## Returns [param lines] sorted into groups that run side by side along the
## same road, given lanes [param width] pixels wide.
static func group(lines: Array[PackedVector2Array], width: float) -> Array:
	var groups: Array[int] = []
	for index: int in lines.size():
		groups.append(index)
	for a: int in lines.size():
		for b: int in range(a + 1, lines.size()):
			if spacing(lines[a], lines[b]) <= width * NEIGHBOUR_REACH:
				groups[UnionFind.root(groups, a)] = UnionFind.root(groups, b)
	return UnionFind.collect(groups, lines)


## Returns the typical distance between two lines running side by side, or
## [constant @GDScript.INF] if they are not parallel or do not overlap at all.
static func spacing(a: PackedVector2Array, b: PackedVector2Array) -> float:
	var heading: Vector2 = Polyline.direction(a)
	var angle: float = acos(clampf(absf(heading.dot(Polyline.direction(b))), 0.0, 1.0))
	if angle > deg_to_rad(PARALLEL_DEGREES):
		return INF
	return minf(_spacing_from(a, b), _spacing_from(b, a))


## The median distance to [param a] from the points of [param b] that lie alongside it.
static func _spacing_from(a: PackedVector2Array, b: PackedVector2Array) -> float:
	var heading: Vector2 = Polyline.direction(a)
	var reach: Vector2 = Polyline.extent_along(a, a[0], heading)
	var distances: Array[float] = []
	for point: Vector2 in Polyline.resampled(b, SAMPLE_SPACING):
		var along: float = (point - a[0]).dot(heading)
		if along >= reach.x and along <= reach.y:
			distances.append(Polyline.distance_to(a, point))
	return Median.of(distances, INF)
