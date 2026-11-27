class_name RoadStrip
extends RefCounted
## The lines of one stretch of road, built by widening its centre line into
## lanes: its two edges and the lines between its lanes.

var left_edge: PackedVector2Array
var right_edge: PackedVector2Array
## Lines between neighbouring lanes, from the left of the road to the right.
var dividers: Array[PackedVector2Array] = []


## Returns the road along [param line], [param lane_count] lanes of
## [param lane_width] wide, with [param line] running [param way_position]
## lanes in from its left edge. Left is as seen looking along the line.
static func along(
	line: PackedVector2Array, lane_count: int, way_position: float, lane_width: float
) -> RoadStrip:
	var strip: RoadStrip = RoadStrip.new()
	strip.left_edge = Polyline.offset(line, way_position * lane_width)
	strip.right_edge = Polyline.offset(line, (way_position - lane_count) * lane_width)
	for lane: int in range(1, lane_count):
		strip.dividers.append(Polyline.offset(line, (way_position - lane) * lane_width))
	return strip


## Returns the tarmac the road covers, as a polygon running up one edge and back down the other.
func area() -> PackedVector2Array:
	return left_edge + Polyline.reversed(right_edge)
