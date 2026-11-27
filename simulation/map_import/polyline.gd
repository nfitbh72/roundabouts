class_name Polyline
extends RefCounted
## Geometry helpers for open polylines: lists of points joined by straight segments.

## How many points either side of a point its normal is worked out from.
const NORMAL_REACH: int = 2


## Returns the total length of [param line].
static func length(line: PackedVector2Array) -> float:
	var total: float = 0.0
	for index: int in range(1, line.size()):
		total += line[index - 1].distance_to(line[index])
	return total


## Returns the longest of [param lines].
static func longest(lines: Array[PackedVector2Array]) -> PackedVector2Array:
	var result: PackedVector2Array = lines[0]
	for line: PackedVector2Array in lines:
		if length(line) > length(result):
			result = line
	return result


## Returns the unit direction from the first point of [param line] to its last.
static func direction(line: PackedVector2Array) -> Vector2:
	return (line[-1] - line[0]).normalized()


## Returns the average of the points of [param line].
static func centre(line: PackedVector2Array) -> Vector2:
	var total: Vector2 = Vector2.ZERO
	for point: Vector2 in line:
		total += point
	return total / line.size()


## Returns [param line] running the other way.
static func reversed(line: PackedVector2Array) -> PackedVector2Array:
	var result: PackedVector2Array = line.duplicate()
	result.reverse()
	return result


## Returns [param line] turned, if needed, to run roughly along [param heading].
static func facing(line: PackedVector2Array, heading: Vector2) -> PackedVector2Array:
	if direction(line).dot(heading) < 0.0:
		return reversed(line)
	return line


## Returns the unit normal at each point of [param line], pointing to the left
## of the direction of travel in screen coordinates. Each one follows the line
## from two points before to two points after, so one wobbly point cannot
## swing it far.
static func normals(line: PackedVector2Array) -> PackedVector2Array:
	var result: PackedVector2Array = PackedVector2Array()
	for index: int in line.size():
		var before: Vector2 = line[maxi(index - NORMAL_REACH, 0)]
		var after: Vector2 = line[mini(index + NORMAL_REACH, line.size() - 1)]
		result.append((after - before).normalized().orthogonal())
	return result


## Returns a copy of [param line] moved sideways by [param distance] along its normals.
## Positive distances move it the way [method normals] point.
static func offset(line: PackedVector2Array, distance: float) -> PackedVector2Array:
	var sideways: PackedVector2Array = normals(line)
	var result: PackedVector2Array = PackedVector2Array()
	for index: int in line.size():
		result.append(line[index] + sideways[index] * distance)
	return result


## Returns points spaced [param spacing] apart along [param line], starting at its
## first point and always including its last.
static func resampled(line: PackedVector2Array, spacing: float) -> PackedVector2Array:
	var result: PackedVector2Array = PackedVector2Array([line[0]])
	var carried: float = 0.0
	for index: int in range(1, line.size()):
		var from: Vector2 = line[index - 1]
		var segment: float = from.distance_to(line[index])
		var travelled: float = spacing - carried
		while travelled <= segment:
			result.append(from.lerp(line[index], travelled / segment))
			travelled += spacing
		carried = segment - (travelled - spacing)
	if result[-1] != line[-1]:
		result.append(line[-1])
	return result


## Returns the shortest distance from [param point] to [param line].
static func distance_to(line: PackedVector2Array, point: Vector2) -> float:
	var nearest: float = INF
	for index: int in range(1, line.size()):
		var closest: Vector2 = Geometry2D.get_closest_point_to_segment(
			point, line[index - 1], line[index]
		)
		nearest = minf(nearest, point.distance_to(closest))
	return nearest


## Returns the shortest distance between lines [param a] and [param b]: zero
## if they cross.
static func distance_between(a: PackedVector2Array, b: PackedVector2Array) -> float:
	for i: int in range(1, a.size()):
		for j: int in range(1, b.size()):
			if Geometry2D.segment_intersects_segment(a[i - 1], a[i], b[j - 1], b[j]) != null:
				return 0.0
	var nearest: float = INF
	for point: Vector2 in a:
		nearest = minf(nearest, distance_to(b, point))
	for point: Vector2 in b:
		nearest = minf(nearest, distance_to(a, point))
	return nearest


## Returns the lowest and highest position of any point of [param line] when
## measured along [param axis] from [param origin].
static func extent_along(line: PackedVector2Array, origin: Vector2, axis: Vector2) -> Vector2:
	var lowest: float = INF
	var highest: float = -INF
	for point: Vector2 in line:
		var position: float = (point - origin).dot(axis)
		lowest = minf(lowest, position)
		highest = maxf(highest, position)
	return Vector2(lowest, highest)
