class_name LaneChains
extends RefCounted
## Joins painted marks that line up end to end into continuous lane lines.
##
## Dashes on a road follow one another along it. Car park bays sit side by
## side, and roof edges point every which way, so neither chains up.

## Largest change of direction between two marks in the same chain.
const MAX_TURN_DEGREES: float = 20.0
## Longest gap between the ends of two marks in the same chain, in pixels.
const MAX_GAP: float = 45.0
## How far a mark may sit to the side of the line through the previous one, in
## pixels, plus a share of the distance between them to allow for curves.
const MAX_DRIFT: float = 3.0
const DRIFT_PER_DISTANCE: float = 0.12
## A lane line is a chain of at least this many marks, spanning at least this far.
## Lone solid lines are left out for now: they are as often the edge of a
## building or a kerb as a line between lanes.
const MIN_MARKS: int = 3
const MIN_SPAN: float = 60.0
## Spacing between the points of a finished lane line. Paint within this
## distance either side of each point is averaged, which smooths out marks
## that overlap or sit slightly askew, such as the letters of a map label.
const SMOOTHING_STEP: float = 10.0


## Returns a polyline for each chain of [param marks] long enough to be a lane line.
## Each mark is a two-point line, as made by [LaneMarks].
static func join(marks: Array[PackedVector2Array]) -> Array[PackedVector2Array]:
	var lines: Array[PackedVector2Array] = []
	for chain: Array[PackedVector2Array] in _chains(marks):
		var line: PackedVector2Array = centre_line(chain)
		if is_lane_line(line, chain.size()):
			lines.append(line)
	return lines


## Returns true if marks [param a] and [param b] could be neighbours in a chain.
static func can_join(a: PackedVector2Array, b: PackedVector2Array) -> bool:
	return _follows(a, b) or _follows(b, a)


## Returns a smooth line along the middle of a chain of [param marks], from
## one end to the other, always moving forwards along the chain.
static func centre_line(marks: Array[PackedVector2Array]) -> PackedVector2Array:
	var heading: Vector2 = Polyline.direction(Polyline.longest(marks))
	var across: Vector2 = heading.orthogonal()
	var origin: Vector2 = marks[0][0]
	var points: PackedVector2Array = PackedVector2Array()
	for mark: PackedVector2Array in marks:
		for point: Vector2 in Polyline.resampled(mark, SMOOTHING_STEP / 2.0):
			points.append(Vector2((point - origin).dot(heading), (point - origin).dot(across)))
	var reach: Vector2 = Polyline.extent_along(points, Vector2.ZERO, Vector2.RIGHT)
	# Evenly spaced, so there is no stub of a segment at the end to throw the direction off.
	var steps: int = maxi(1, ceili((reach.y - reach.x) / SMOOTHING_STEP))
	var line: PackedVector2Array = PackedVector2Array()
	for step: int in steps + 1:
		var along: float = lerpf(reach.x, reach.y, float(step) / steps)
		var sideways: float = _average_sideways(points, along)
		if not is_nan(sideways):
			line.append(origin + heading * along + across * sideways)
	return line


## Returns true if a chain of [param mark_count] marks forming [param line] is
## long enough to be a lane line.
static func is_lane_line(line: PackedVector2Array, mark_count: int) -> bool:
	return mark_count >= MIN_MARKS and line[0].distance_to(line[-1]) >= MIN_SPAN


## Groups the marks into chains of neighbours, keeping the order marks were found in.
static func _chains(marks: Array[PackedVector2Array]) -> Array:
	var groups: Array[int] = []
	for index: int in marks.size():
		groups.append(index)
	for a: int in marks.size():
		for b: int in range(a + 1, marks.size()):
			if can_join(marks[a], marks[b]):
				groups[UnionFind.root(groups, a)] = UnionFind.root(groups, b)
	return UnionFind.collect(groups, marks)


## Returns true if [param b] carries on from [param a]: pointing the same way,
## close to the line through [param a], and not too far beyond its end.
static func _follows(a: PackedVector2Array, b: PackedVector2Array) -> bool:
	var reach: float = MAX_GAP + (Polyline.length(a) + Polyline.length(b)) / 2.0
	if Polyline.centre(a).distance_squared_to(Polyline.centre(b)) > reach * reach:
		return false
	var heading: Vector2 = Polyline.direction(a)
	if absf(heading.dot(Polyline.direction(b))) < cos(deg_to_rad(MAX_TURN_DEGREES)):
		return false
	var origin: Vector2 = Polyline.centre(a)
	var b_middle: Vector2 = Polyline.centre(b)
	var along: float = absf((b_middle - origin).dot(heading))
	if absf((b_middle - origin).dot(heading.orthogonal())) > MAX_DRIFT + DRIFT_PER_DISTANCE * along:
		return false
	var a_range: Vector2 = Polyline.extent_along(a, origin, heading)
	var b_range: Vector2 = Polyline.extent_along(b, origin, heading)
	var gap: float = maxf(b_range.x - a_range.y, a_range.x - b_range.y)
	return gap <= MAX_GAP


## The average sideways position of the [param points] (stored as along, sideways)
## within half a smoothing step of [param along], or NAN if there are none.
static func _average_sideways(points: PackedVector2Array, along: float) -> float:
	var total: float = 0.0
	var count: int = 0
	for point: Vector2 in points:
		if absf(point.x - along) <= SMOOTHING_STEP / 2.0:
			total += point.y
			count += 1
	if count == 0:
		return NAN
	return total / count
