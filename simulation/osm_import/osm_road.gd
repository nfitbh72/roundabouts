class_name OsmRoad
extends RefCounted
## One OpenStreetMap way with a highway tag: its tags and the points along its
## centre line, in the order it was drawn.

var id: int
var tags: Dictionary[String, String]
var points: Array[GeoPoint]


func _init(way_id: int, way_tags: Dictionary[String, String], way_points: Array[GeoPoint]) -> void:
	id = way_id
	tags = way_tags
	points = way_points
