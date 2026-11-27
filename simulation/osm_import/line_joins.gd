class_name LineJoins
extends RefCounted
## Joins two lines end to start with a smooth curve: a rounded corner where
## they meet at an angle, or a taper where one is offset sideways from the other.

## Ends closer than this, in metres, already touch and need no curve.
const TOUCHING: float = 0.01
## Length of a taper on each side of a sideways step, per metre of step.
const TAPER_PER_STEP: float = 3.0
## The most of either line a curve may replace, as a share of its length.
const MOST_REPLACED: float = 0.45
## Points along each curve, not counting its ends.
const CURVE_POINTS: int = 8


## Returns [param a] then [param b], with the step between the end of [param a]
## and the start of [param b] smoothed into a gentle S-shaped taper.
static func tapered(a: PackedVector2Array, b: PackedVector2Array) -> PackedVector2Array:
	var step: float = a[-1].distance_to(b[0])
	if step <= TOUCHING:
		return a + b.slice(1)
	var reach: float = step * TAPER_PER_STEP
	var a_cut: PackedVector2Array = trimmed_end(a, minf(reach, Polyline.length(a) * MOST_REPLACED))
	var b_cut: PackedVector2Array = trimmed_start(
		b, minf(reach, Polyline.length(b) * MOST_REPLACED)
	)
	var handle: float = a_cut[-1].distance_to(b_cut[0]) / 3.0
	var curve: PackedVector2Array = _curve(
		a_cut[-1],
		a_cut[-1] + _end_direction(a_cut) * handle,
		b_cut[0] - _start_direction(b_cut) * handle,
		b_cut[0],
	)
	return a_cut + curve + b_cut


## Returns [param a] then [param b], which meet at a corner, with the corner
## rounded off by cutting up to [param radius] metres back along each.
static func rounded(
	a: PackedVector2Array, b: PackedVector2Array, radius: float
) -> PackedVector2Array:
	var corner: Vector2 = (a[-1] + b[0]) / 2.0
	var cut: float = minf(radius, minf(Polyline.length(a), Polyline.length(b)) * MOST_REPLACED)
	var a_cut: PackedVector2Array = trimmed_end(a, cut)
	var b_cut: PackedVector2Array = trimmed_start(b, cut)
	return a_cut + _corner_curve(a_cut[-1], corner, b_cut[0]) + b_cut


## Returns [param loop], whose ends meet, with the corner where they meet
## rounded off as in [method rounded]. The result still starts and ends at the same point.
static func rounded_loop(loop: PackedVector2Array, radius: float) -> PackedVector2Array:
	var corner: Vector2 = (loop[-1] + loop[0]) / 2.0
	var cut: float = minf(radius, Polyline.length(loop) * MOST_REPLACED / 2.0)
	var middle: PackedVector2Array = trimmed_end(trimmed_start(loop, cut), cut)
	return middle + _corner_curve(middle[-1], corner, middle[0]) + middle.slice(0, 1)


## Returns [param line] with its first [param distance] metres cut off.
static func trimmed_start(line: PackedVector2Array, distance: float) -> PackedVector2Array:
	var remaining: float = distance
	for index: int in range(1, line.size()):
		var segment: float = line[index - 1].distance_to(line[index])
		if segment > remaining:
			var start: Vector2 = line[index - 1].lerp(line[index], remaining / segment)
			return PackedVector2Array([start]) + line.slice(index)
		remaining -= segment
	return line.slice(-1)


## Returns [param line] with its last [param distance] metres cut off.
static func trimmed_end(line: PackedVector2Array, distance: float) -> PackedVector2Array:
	return Polyline.reversed(trimmed_start(Polyline.reversed(line), distance))


## The curve that rounds the corner at [param corner] between [param from] and
## [param to]: a quadratic Bézier, written as a cubic.
static func _corner_curve(from: Vector2, corner: Vector2, to: Vector2) -> PackedVector2Array:
	return _curve(from, from.lerp(corner, 2.0 / 3.0), to.lerp(corner, 2.0 / 3.0), to)


## Returns the points strictly between the ends of a cubic Bézier curve.
static func _curve(
	from: Vector2, from_handle: Vector2, to_handle: Vector2, to: Vector2
) -> PackedVector2Array:
	var points: PackedVector2Array = PackedVector2Array()
	for step: int in range(1, CURVE_POINTS + 1):
		var t: float = step / (CURVE_POINTS + 1.0)
		points.append(from.bezier_interpolate(from_handle, to_handle, to, t))
	return points


static func _start_direction(line: PackedVector2Array) -> Vector2:
	return (line[mini(1, line.size() - 1)] - line[0]).normalized()


static func _end_direction(line: PackedVector2Array) -> Vector2:
	return (line[-1] - line[maxi(line.size() - 2, 0)]).normalized()
