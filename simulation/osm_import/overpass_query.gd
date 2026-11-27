class_name OverpassQuery
extends RefCounted
## Writes queries for the Overpass API, which searches OpenStreetMap data.

## How long the server may spend on a query before giving up, in seconds.
const TIMEOUT_SECONDS: int = 25


## Returns a query for every road for cars that passes through the square of
## half-width [param radius] metres around [param centre], with all their
## nodes. The search circle reaches the corners of the square.
static func roads_around(centre: GeoPoint, radius: float) -> String:
	var types: String = "|".join(PackedStringArray(RoadTypes.DEFAULT_LANES.keys()))
	return (
		'[out:json][timeout:%d];way(around:%d,%.7f,%.7f)[highway~"^(%s)$"];(._;>;);out body;'
		% [TIMEOUT_SECONDS, ceili(radius * sqrt(2.0)), centre.latitude, centre.longitude, types]
	)
