class_name LaneLines
extends RefCounted
## Finds the painted lines that separate lanes and turns each into a straight line.

## Paint this close to the edge of the road is an edge line, not a lane line.
const EDGE_INSET: int = 4
## Shortest a painted mark can be, in pixels, to count as a lane line.
const MIN_LENGTH: float = 6.0
## How many times longer than wide a mark must be. Arrows and blobs are not lane lines.
const MIN_ELONGATION: float = 3.0


## Returns a two-point line for each lane marking in [param marking] that sits
## well inside [param road].
static func find(marking: BitMap, road: BitMap) -> Array[PackedVector2Array]:
	var inner_road: BitMap = RoadMask.shrunk(road, EDGE_INSET)
	var lines: Array[PackedVector2Array] = []
	for shape: PackedVector2Array in PixelComponents.find(marking):
		var line: PackedVector2Array = line_through(_inside(shape, inner_road))
		if not line.is_empty():
			lines.append(line)
	return lines


## Returns the line running along the middle of a shape made of [param pixels],
## from one end to the other. Returns an empty array if the shape is too short
## or too stubby to be a lane marking.
static func line_through(pixels: PackedVector2Array) -> PackedVector2Array:
	if pixels.is_empty():
		return PackedVector2Array()
	var centre: Vector2 = _mean(pixels)
	var along: Vector2 = _main_direction(pixels, centre)
	var across: Vector2 = along.orthogonal()
	var along_range: Vector2 = _extent(pixels, centre, along)
	var across_range: Vector2 = _extent(pixels, centre, across)
	var length: float = along_range.y - along_range.x + 1.0
	var width: float = across_range.y - across_range.x + 1.0
	if length < MIN_LENGTH or length < width * MIN_ELONGATION:
		return PackedVector2Array()
	# Pixel coordinates name a pixel's corner; the line should run through the middle.
	var middle: Vector2 = centre + Vector2(0.5, 0.5)
	return PackedVector2Array([middle + along * along_range.x, middle + along * along_range.y])


static func _inside(pixels: PackedVector2Array, mask: BitMap) -> PackedVector2Array:
	var kept: PackedVector2Array = PackedVector2Array()
	for pixel: Vector2 in pixels:
		if mask.get_bitv(Vector2i(pixel)):
			kept.append(pixel)
	return kept


static func _mean(pixels: PackedVector2Array) -> Vector2:
	var total: Vector2 = Vector2.ZERO
	for pixel: Vector2 in pixels:
		total += pixel
	return total / pixels.size()


## The direction the shape is longest in, from the spread of its pixels.
static func _main_direction(pixels: PackedVector2Array, centre: Vector2) -> Vector2:
	var xx: float = 0.0
	var yy: float = 0.0
	var xy: float = 0.0
	for pixel: Vector2 in pixels:
		var offset: Vector2 = pixel - centre
		xx += offset.x * offset.x
		yy += offset.y * offset.y
		xy += offset.x * offset.y
	return Vector2.from_angle(0.5 * atan2(2.0 * xy, xx - yy))


## The lowest and highest distance of any pixel from [param centre] along [param direction].
static func _extent(pixels: PackedVector2Array, centre: Vector2, direction: Vector2) -> Vector2:
	var lowest: float = INF
	var highest: float = -INF
	for pixel: Vector2 in pixels:
		var distance: float = (pixel - centre).dot(direction)
		lowest = minf(lowest, distance)
		highest = maxf(highest, distance)
	return Vector2(lowest, highest)
