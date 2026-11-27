class_name LocalProjection
extends RefCounted
## Flattens latitude and longitude into metres around a centre point, with x
## running east and y running south to match screen coordinates.
##
## The Earth is treated as flat near the centre. Over a few hundred metres the
## error is a few centimetres, far less than a lane width. Points across the
## 180° meridian from the centre are not handled.

## Mean radius of the Earth, in metres.
const EARTH_RADIUS: float = 6_371_000.0
const METRES_PER_DEGREE: float = EARTH_RADIUS * PI / 180.0


## Returns where [param point] lies, in metres from [param centre].
static func to_metres(point: GeoPoint, centre: GeoPoint) -> Vector2:
	var east: float = (
		(point.longitude - centre.longitude) * METRES_PER_DEGREE * cos(deg_to_rad(centre.latitude))
	)
	var south: float = (centre.latitude - point.latitude) * METRES_PER_DEGREE
	return Vector2(east, south)


## Returns [param points] in metres from [param centre], leaving out any point
## that repeats the one before it.
static func line_to_metres(points: Array[GeoPoint], centre: GeoPoint) -> PackedVector2Array:
	var line: PackedVector2Array = PackedVector2Array()
	for point: GeoPoint in points:
		var metres: Vector2 = to_metres(point, centre)
		if line.is_empty() or line[-1] != metres:
			line.append(metres)
	return line
