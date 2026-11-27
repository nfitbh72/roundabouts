class_name MapOutline
extends RefCounted
## The lines found in a junction screenshot, ready to be redrawn in the game's own style.
##
## Holds only line geometry, in the pixel coordinates of the converted image.
## Nothing of the image itself is kept.

## Width and height of the area the lines were found in.
var size: Vector2i
## Open polylines running along the edges of the roads.
var road_edges: Array[PackedVector2Array]
## Two-point lines along the painted markings that separate lanes.
var lane_lines: Array[PackedVector2Array]


func _init(
	area_size: Vector2i,
	edges: Array[PackedVector2Array],
	lanes: Array[PackedVector2Array],
) -> void:
	size = area_size
	road_edges = edges
	lane_lines = lanes
