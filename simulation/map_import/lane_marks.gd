class_name LaneMarks
extends RefCounted
## Finds the painted marks that could be part of a lane line: long, thin, and
## with tarmac on both sides. Roof edges, building outlines and the white lines
## along the kerb fail the last test.

## Shortest a painted mark can be, in pixels, to count.
const MIN_LENGTH: float = 6.0
## How many times longer than wide a mark must be. Arrows and blobs are not lane lines.
const MIN_ELONGATION: float = 3.0
## How far either side of a mark to look for tarmac, in pixels.
const SIDE_DISTANCES: Array[float] = [4.0, 6.0, 8.0]
## How many places along a mark to look from.
const SIDE_SAMPLES: int = 9
## Share of the places looked at that must be tarmac, on each side.
const MIN_TARMAC_SHARE: float = 0.6


## Returns a two-point line for each lane-like mark among the paint
## [param shapes], using [param surface] to check for tarmac on both sides.
static func find(shapes: Array[PackedVector2Array], surface: BitMap) -> Array[PackedVector2Array]:
	var marks: Array[PackedVector2Array] = []
	for shape: PackedVector2Array in shapes:
		var line: PackedVector2Array = line_through(shape)
		if not line.is_empty() and has_tarmac_both_sides(line, surface):
			marks.append(line)
	return marks


## Returns the line running along the middle of a shape made of [param pixels],
## from one end to the other. Returns an empty array if the shape is too short
## or too stubby to be a lane marking.
static func line_through(pixels: PackedVector2Array) -> PackedVector2Array:
	if pixels.is_empty():
		return PackedVector2Array()
	var centre: Vector2 = Polyline.centre(pixels)
	var along: Vector2 = _main_direction(pixels, centre)
	var along_range: Vector2 = Polyline.extent_along(pixels, centre, along)
	var across_range: Vector2 = Polyline.extent_along(pixels, centre, along.orthogonal())
	var length: float = along_range.y - along_range.x + 1.0
	var width: float = across_range.y - across_range.x + 1.0
	if length < MIN_LENGTH or length < width * MIN_ELONGATION:
		return PackedVector2Array()
	# Pixel coordinates name a pixel's corner; the line should run through the middle.
	var middle: Vector2 = centre + Vector2(0.5, 0.5)
	return PackedVector2Array([middle + along * along_range.x, middle + along * along_range.y])


## Returns true if there is tarmac in [param surface] on both sides of [param line].
static func has_tarmac_both_sides(line: PackedVector2Array, surface: BitMap) -> bool:
	return (
		tarmac_share(line, surface, 1.0) >= MIN_TARMAC_SHARE
		and tarmac_share(line, surface, -1.0) >= MIN_TARMAC_SHARE
	)


## Returns the share of places beside [param line] that are tarmac, looking to
## the side given by the sign of [param side]. Places off the image do not count.
static func tarmac_share(line: PackedVector2Array, surface: BitMap, side: float) -> float:
	var across: Vector2 = Polyline.direction(line).orthogonal() * signf(side)
	var bounds: Rect2i = Rect2i(Vector2i.ZERO, surface.get_size())
	var looked: int = 0
	var found: int = 0
	for step: int in SIDE_SAMPLES:
		var along: Vector2 = line[0].lerp(line[-1], float(step) / (SIDE_SAMPLES - 1))
		for distance: float in SIDE_DISTANCES:
			var pixel: Vector2i = Vector2i((along + across * distance).floor())
			if not bounds.has_point(pixel):
				continue
			looked += 1
			if surface.get_bitv(pixel):
				found += 1
	if looked == 0:
		return 0.0
	return float(found) / looked


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
