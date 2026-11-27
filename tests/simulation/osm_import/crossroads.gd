class_name Crossroads
extends RefCounted
## The hand-written Overpass JSON used by the OpenStreetMap import tests: a
## four-lane main road running east and west across a two-lane side street at
## latitude 0, longitude 0, with a footpath, a driveway and a building nearby.

const PATH: String = "res://tests/simulation/osm_import/fixtures/crossroads.json"


static func text() -> String:
	return FileAccess.get_file_as_string(PATH)


static func extract() -> OsmExtract:
	return OverpassParser.parse(text())


static func centre() -> GeoPoint:
	return GeoPoint.new(0.0, 0.0)
