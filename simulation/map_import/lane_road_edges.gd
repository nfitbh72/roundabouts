class_name LaneRoadEdges
extends RefCounted
## Places the edges of a road outside its outermost lane lines.
##
## From each outer lane line, steps outwards until the tarmac ends. Where the
## tarmac gives no clear answer, no edge is drawn: a missing edge is easier
## to spot and fix than one in the wrong place.

## Spacing between the places along a lane line to step outwards from.
const SAMPLE_SPACING: float = 8.0
## Furthest an edge can be from the outer lane line, in lane widths.
const MAX_REACH: float = 2.0
## Closest an edge can be from the outer lane line, in lane widths. Anything
## nearer is a car or a gap in the tarmac, not the edge.
const MIN_REACH: float = 0.4
## How many pixels in a row must be off the road to count as its edge.
const STOP_RUN: int = 3


## Returns the edges of the road whose lane lines are [param lines], with
## lanes [param width] pixels wide, using [param road] to find where the tarmac
## ends. Returns up to two edges, one for each side the tarmac clearly ends on.
static func edges_of(
	lines: Array[PackedVector2Array], width: float, road: BitMap
) -> Array[PackedVector2Array]:
	var heading: Vector2 = Polyline.direction(Polyline.longest(lines))
	var across: Vector2 = heading.orthogonal()
	var origin: Vector2 = Polyline.centre(Polyline.longest(lines))
	var outermost: PackedVector2Array = PackedVector2Array()
	var innermost: PackedVector2Array = PackedVector2Array()
	var highest: float = -INF
	var lowest: float = INF
	for line: PackedVector2Array in lines:
		var side: float = (Polyline.centre(line) - origin).dot(across)
		if side > highest:
			highest = side
			outermost = Polyline.facing(line, heading)
		if side < lowest:
			lowest = side
			innermost = Polyline.facing(line, heading)
	var edges: Array[PackedVector2Array] = []
	for edge: PackedVector2Array in [
		edge_beside(outermost, 1.0, width, road), edge_beside(innermost, -1.0, width, road)
	]:
		if not edge.is_empty():
			edges.append(edge)
	return edges


## Returns the road edge beside [param line], on the side its normals point
## to if [param side] is positive, or the other side if negative. Returns an
## empty array if the edge cannot be found.
static func edge_beside(
	line: PackedVector2Array, side: float, width: float, road: BitMap
) -> PackedVector2Array:
	var distance: float = edge_distance(line, side, width, road)
	if distance < 0.0:
		return PackedVector2Array()
	return Polyline.offset(line, signf(side) * distance)


## Returns how far the road edge is from [param line] on the given [param side],
## or -1.0 if it is not clear along most of the line.
static func edge_distance(
	line: PackedVector2Array, side: float, width: float, road: BitMap
) -> float:
	var points: PackedVector2Array = Polyline.resampled(line, SAMPLE_SPACING)
	var outwards: PackedVector2Array = Polyline.normals(points)
	var found: Array[float] = []
	for index: int in points.size():
		var distance: float = distance_to_edge(
			points[index], outwards[index] * signf(side), width, road
		)
		if distance > 0.0:
			found.append(distance)
	if found.size() * 2 < points.size():
		return -1.0
	return Median.of(found)


## Steps from [param from] in [param direction] until the road ends, and returns
## how far that was. Returns -1.0 if the edge is not within a plausible distance.
static func distance_to_edge(
	from: Vector2, direction: Vector2, width: float, road: BitMap
) -> float:
	var bounds: Rect2i = Rect2i(Vector2i.ZERO, road.get_size())
	var off_road: int = 0
	for step: int in range(1, ceili(width * MAX_REACH) + STOP_RUN):
		var pixel: Vector2i = Vector2i((from + direction * step).floor())
		if not bounds.has_point(pixel):
			return -1.0
		off_road = 0 if road.get_bitv(pixel) else off_road + 1
		if off_road == STOP_RUN:
			# The edge lies between the last pixel on the road and the first one off it.
			var distance: float = step - STOP_RUN + 0.5
			if distance < width * MIN_REACH or distance > width * MAX_REACH:
				return -1.0
			return distance
	return -1.0
