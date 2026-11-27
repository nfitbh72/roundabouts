class_name RoadEdges
extends RefCounted
## Traces the edges of a road mask as polylines.
##
## Where a road runs off the side of the picture, the picture's edge is not a
## road edge, so those stretches are left out.

## How far a traced outline may stray from the pixels, to smooth out staircases.
const SIMPLIFY_EPSILON: float = 1.5
## Smallest a patch of road can be, as a share of the picture. Smaller grey
## patches are roofs, paths and other things that only look like tarmac.
const MIN_ROAD_SHARE: float = 0.01
## Smallest a gap inside a road can be, as a share of the picture. Smaller gaps
## are cars, shadows and the like; larger ones are traffic islands.
const MIN_HOLE_SHARE: float = 0.002
## How close to the border a point must be to count as lying on it. Godot's
## tracer cuts the corner where a shape meets the border, leaving a small hook
## on the end of each line, so this is generous enough to trim those off.
const BORDER_TOLERANCE: float = 2.5


## Returns the road edges of [param road], looking only inside [param area].
static func trace(road: BitMap, area: Rect2i) -> Array[PackedVector2Array]:
	var picture: float = area.get_area()
	var outlines: Array[PackedVector2Array] = road.opaque_to_polygons(area, SIMPLIFY_EPSILON)
	var rings: Array[PackedVector2Array] = _larger_than(outlines, picture * MIN_ROAD_SHARE)
	rings.append_array(_larger_than(_holes(road, area), picture * MIN_HOLE_SHARE))
	var offset: Transform2D = Transform2D(0.0, Vector2(area.position))
	var edges: Array[PackedVector2Array] = []
	for ring: PackedVector2Array in rings:
		for line: PackedVector2Array in split_at_border(ring, Vector2(area.size)):
			edges.append(offset * line)
	return edges


## Splits a closed [param ring] into open polylines, dropping every stretch that
## lies along the border of a rectangle of [param size] with its corner at the origin.
## A ring that never touches the border comes back whole, closed by repeating its first point.
static func split_at_border(ring: PackedVector2Array, size: Vector2) -> Array[PackedVector2Array]:
	var count: int = ring.size()
	var start: int = -1
	for index: int in count:
		if _is_on_border(ring[index], ring[(index + 1) % count], size):
			start = index + 1
			break
	if start == -1:
		var closed: PackedVector2Array = ring.duplicate()
		closed.append(ring[0])
		return [closed]
	var lines: Array[PackedVector2Array] = []
	var current: PackedVector2Array = PackedVector2Array()
	for step: int in count:
		var from: Vector2 = ring[(start + step) % count]
		var to: Vector2 = ring[(start + step + 1) % count]
		if _is_on_border(from, to, size):
			_keep_if_line(current, lines)
			current = PackedVector2Array()
			continue
		if current.is_empty():
			current.append(from)
		current.append(to)
	_keep_if_line(current, lines)
	return lines


## Returns the signed area of a closed [param ring], using the shoelace formula.
static func area_of(ring: PackedVector2Array) -> float:
	var total: float = 0.0
	for index: int in ring.size():
		total += ring[index].cross(ring[(index + 1) % ring.size()])
	return total / 2.0


## Outlines of the gaps inside roads, such as traffic islands. These are the
## shapes left once the road is taken away, apart from any that reach the border.
static func _holes(road: BitMap, area: Rect2i) -> Array[PackedVector2Array]:
	var gaps: BitMap = BitMap.new()
	gaps.create(road.get_size())
	for y: int in range(area.position.y, area.end.y):
		for x: int in range(area.position.x, area.end.x):
			gaps.set_bit(x, y, not road.get_bit(x, y))
	var holes: Array[PackedVector2Array] = []
	var size: Vector2 = Vector2(area.size)
	for ring: PackedVector2Array in gaps.opaque_to_polygons(area, SIMPLIFY_EPSILON):
		if not _touches_border(ring, size):
			holes.append(ring)
	return holes


static func _larger_than(
	rings: Array[PackedVector2Array], min_area: float
) -> Array[PackedVector2Array]:
	return rings.filter(
		func(ring: PackedVector2Array) -> bool: return absf(area_of(ring)) >= min_area
	)


static func _touches_border(ring: PackedVector2Array, size: Vector2) -> bool:
	for point: Vector2 in ring:
		if _border_sides(point, size) != 0:
			return true
	return false


static func _is_on_border(from: Vector2, to: Vector2, size: Vector2) -> bool:
	return (_border_sides(from, size) & _border_sides(to, size)) != 0


## Returns a bit for each side of the border the point lies on: left, right, top, bottom.
static func _border_sides(point: Vector2, size: Vector2) -> int:
	var sides: int = 0
	if point.x <= BORDER_TOLERANCE:
		sides |= 1
	if point.x >= size.x - BORDER_TOLERANCE:
		sides |= 2
	if point.y <= BORDER_TOLERANCE:
		sides |= 4
	if point.y >= size.y - BORDER_TOLERANCE:
		sides |= 8
	return sides


static func _keep_if_line(points: PackedVector2Array, lines: Array[PackedVector2Array]) -> void:
	if points.size() >= 2:
		lines.append(points)
