class_name LaneRoadEdges
extends RefCounted
## Places the edges of a road outside its outermost lane lines.
##
## From each outer lane line, steps outwards until the colour stops matching
## the tarmac right beside the line. Comparing with the road's own tarmac,
## rather than with a fixed idea of grey, tells a road from a pavement or car
## park of almost the same colour. Where the answer is unclear, no edge is
## drawn: a missing edge is easier to spot and fix than one in the wrong place.

## Spacing between the places along a lane line to step outwards from.
const SAMPLE_SPACING: float = 8.0
## Furthest an edge can be from the outer lane line, in lane widths.
const MAX_REACH: float = 2.0
## Closest an edge can be from the outer lane line, in lane widths. Anything
## nearer is a car or a gap in the tarmac, not the edge.
const MIN_REACH: float = 0.4
## How many pixels in a row must differ from the tarmac to count as the edge.
const STOP_RUN: int = 3
## How far beside the line the tarmac's colour is sampled, in pixels. Close
## enough to be the same road, far enough to miss the paint.
const REFERENCE_DISTANCES: Array[float] = [3.0, 4.5, 6.0]
## Where stepping outwards starts, in pixels, clear of the paint itself.
const FIRST_STEP: int = 3
## Largest colour difference from the tarmac that is still road, as a distance
## between colours with channels from 0 to 255.
const MAX_COLOUR_CHANGE: float = 30.0


## Returns the edges of the road whose lane lines are [param lines], with
## lanes [param width] pixels wide, using [param image] to find where the tarmac
## ends. Returns up to two edges, one for each side the tarmac clearly ends on.
static func edges_of(
	lines: Array[PackedVector2Array], width: float, image: Image
) -> Array[PackedVector2Array]:
	var heading: Vector2 = Polyline.direction(Polyline.longest(lines))
	var facing: Array[PackedVector2Array] = []
	for line: PackedVector2Array in lines:
		facing.append(Polyline.facing(line, heading))
	var edges: Array[PackedVector2Array] = []
	for side: float in [1.0, -1.0]:
		var edge: PackedVector2Array = edge_on_side(facing, side, width, image)
		if not edge.is_empty():
			edges.append(edge)
	return edges


## Returns the road edge on one [param side] of [param lines], which all run the
## same way. Starts from the outermost line on that side; if it gives no clear
## edge, tries the next one in, and so on. An edge found from an inner line only
## counts if it lies as far beyond the outermost line as any edge must lie from
## a lane line, so it never ends up inside a lane.
## Returns an empty array if no line gives an edge.
static func edge_on_side(
	lines: Array[PackedVector2Array], side: float, width: float, image: Image
) -> PackedVector2Array:
	var across: Vector2 = Polyline.direction(Polyline.longest(lines)).orthogonal() * signf(side)
	var outward: Callable = func(line: PackedVector2Array) -> float:
		return Polyline.centre(line).dot(across)
	var ordered: Array[PackedVector2Array] = lines.duplicate()
	ordered.sort_custom(
		func(a: PackedVector2Array, b: PackedVector2Array) -> bool:
			return outward.call(a) > outward.call(b)
	)
	var furthest: float = outward.call(ordered[0])
	for line: PackedVector2Array in ordered:
		var distance: float = edge_distance(line, side, width, image)
		if distance >= 0.0 and outward.call(line) + distance >= furthest + width * MIN_REACH:
			return Polyline.offset(line, signf(side) * distance)
	return PackedVector2Array()


## Returns how far the road edge is from [param line] on the given [param side],
## or -1.0 if it is not clear along most of the line.
static func edge_distance(
	line: PackedVector2Array, side: float, width: float, image: Image
) -> float:
	var points: PackedVector2Array = Polyline.resampled(line, SAMPLE_SPACING)
	var outwards: PackedVector2Array = Polyline.normals(points)
	var found: Array[float] = []
	for index: int in points.size():
		var distance: float = distance_to_edge(
			points[index], outwards[index] * signf(side), width, image
		)
		if distance > 0.0:
			found.append(distance)
	if found.size() * 2 < points.size():
		return -1.0
	return Median.of(found)


## Steps from [param from] in [param direction] until the colour stops matching
## the tarmac beside [param from], and returns how far that was. Returns -1.0
## if the edge is not within a plausible distance.
static func distance_to_edge(
	from: Vector2, direction: Vector2, width: float, image: Image
) -> float:
	var tarmac: Vector3 = tarmac_beside(from, direction, image)
	if tarmac.x < 0.0:
		return -1.0
	var bounds: Rect2i = Rect2i(Vector2i.ZERO, image.get_size())
	var off_road: int = 0
	for step: int in range(FIRST_STEP, ceili(width * MAX_REACH) + STOP_RUN):
		var pixel: Vector2i = Vector2i((from + direction * step).floor())
		if not bounds.has_point(pixel):
			return -1.0
		var differs: bool = (
			PixelColours.smoothed(image, pixel).distance_to(tarmac) > MAX_COLOUR_CHANGE
		)
		off_road = off_road + 1 if differs else 0
		if off_road == STOP_RUN:
			# The edge lies between the last pixel on the road and the first one off it.
			var distance: float = step - STOP_RUN + 0.5
			if distance < width * MIN_REACH or distance > width * MAX_REACH:
				return -1.0
			return distance
	return -1.0


## Returns the colour of the tarmac just beside [param from] in [param direction],
## or [code]Vector3(-1, -1, -1)[/code] if that is off the image.
static func tarmac_beside(from: Vector2, direction: Vector2, image: Image) -> Vector3:
	var points: PackedVector2Array = PackedVector2Array()
	for distance: float in REFERENCE_DISTANCES:
		points.append(from + direction * distance)
	return PixelColours.average(image, points)
