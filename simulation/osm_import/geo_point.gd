class_name GeoPoint
extends RefCounted
## A place on the Earth, as latitude and longitude in degrees.
##
## Kept as two floats rather than a Vector2, because a Vector2 holds only
## single precision, which at these magnitudes rounds to about a metre.

var latitude: float
var longitude: float


func _init(lat: float, lon: float) -> void:
	latitude = lat
	longitude = lon


## Returns true if the point is somewhere on this planet: latitude within 90°
## of the equator and longitude within 180° of Greenwich.
func is_valid() -> bool:
	return absf(latitude) <= 90.0 and absf(longitude) <= 180.0
