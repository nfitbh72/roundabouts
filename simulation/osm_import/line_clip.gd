class_name LineClip
extends RefCounted
## Cuts lines against polygons.


## Returns the parts of [param lines] inside [param polygon].
static func inside(
	lines: Array[PackedVector2Array], polygon: PackedVector2Array
) -> Array[PackedVector2Array]:
	var pieces: Array[PackedVector2Array] = []
	for line: PackedVector2Array in lines:
		pieces.append_array(Geometry2D.intersect_polyline_with_polygon(line, polygon))
	return pieces


## Returns the parts of [param lines] outside [param polygon].
static func outside(
	lines: Array[PackedVector2Array], polygon: PackedVector2Array
) -> Array[PackedVector2Array]:
	var pieces: Array[PackedVector2Array] = []
	for line: PackedVector2Array in lines:
		pieces.append_array(Geometry2D.clip_polyline_with_polygon(line, polygon))
	return pieces


## Returns the lines of [param lines] at least [param shortest] long.
static func at_least(
	lines: Array[PackedVector2Array], shortest: float
) -> Array[PackedVector2Array]:
	var kept: Array[PackedVector2Array] = []
	for line: PackedVector2Array in lines:
		if Polyline.length(line) >= shortest:
			kept.append(line)
	return kept


## Returns the corners of a rectangle of [param size] with one corner at the origin.
static func box(size: Vector2) -> PackedVector2Array:
	return PackedVector2Array([Vector2.ZERO, Vector2(size.x, 0.0), size, Vector2(0.0, size.y)])
