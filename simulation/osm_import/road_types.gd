class_name RoadTypes
extends RefCounted
## Which OpenStreetMap highway types are roads for cars, and how many lanes
## each has when its tags do not say.

## Lanes in both directions together, for each highway type that carries cars.
const DEFAULT_LANES: Dictionary[String, int] = {
	"motorway": 4,
	"trunk": 4,
	"primary": 2,
	"secondary": 2,
	"tertiary": 2,
	"unclassified": 2,
	"residential": 2,
	"living_street": 2,
	"service": 1,
	"motorway_link": 2,
	"trunk_link": 2,
	"primary_link": 2,
	"secondary_link": 2,
	"tertiary_link": 2,
}

## Highway types that are one-way unless tagged otherwise.
const ONEWAY_TYPES: PackedStringArray = ["motorway", "motorway_link"]

## Junction types that are one-way unless tagged otherwise.
const ONEWAY_JUNCTIONS: PackedStringArray = ["roundabout", "circular"]

## Kinds of service road that are too small to be worth drawing: car park
## aisles and the like.
const MINOR_SERVICES: PackedStringArray = [
	"parking_aisle", "driveway", "drive-through", "emergency_access"
]


## Returns true if a way with [param tags] is a road for cars worth drawing.
static func is_drivable(tags: Dictionary[String, String]) -> bool:
	if not DEFAULT_LANES.has(tags.get("highway", "")):
		return false
	if tags.get("area", "") == "yes":
		return false
	return not MINOR_SERVICES.has(tags.get("service", ""))


## Returns the usual number of lanes, both directions together, for a road
## with [param tags]. One-way roads get half, but always at least one.
static func default_lanes(tags: Dictionary[String, String], oneway: bool) -> int:
	var lanes: int = DEFAULT_LANES.get(tags.get("highway", ""), 1)
	return maxi(1, floori(lanes / 2.0)) if oneway else lanes


## Returns true if a road with [param tags] is one-way without saying so.
static func is_implied_oneway(tags: Dictionary[String, String]) -> bool:
	return (
		ONEWAY_TYPES.has(tags.get("highway", "")) or ONEWAY_JUNCTIONS.has(tags.get("junction", ""))
	)
