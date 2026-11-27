class_name OsmRoad
extends RefCounted
## One OpenStreetMap way with a highway tag: its tags, and the nodes along its
## line in the order it was drawn.

var id: int
var tags: Dictionary[String, String]
## The id of each node along the way. Roads that share a node meet there.
var node_ids: PackedInt64Array
## Where each node is, in the same order as [member node_ids].
var points: Array[GeoPoint]


func _init(
	way_id: int,
	way_tags: Dictionary[String, String],
	way_node_ids: PackedInt64Array,
	way_points: Array[GeoPoint],
) -> void:
	id = way_id
	tags = way_tags
	node_ids = way_node_ids
	points = way_points
