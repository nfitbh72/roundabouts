class_name RoadStrip
extends RefCounted
## The lines of one stretch of road, built by widening its centre line into
## lanes: its two edges and the lines between its lanes.

## The OpenStreetMap way's own line, which the other lines are offset from.
var line: PackedVector2Array
var left_edge: PackedVector2Array
var right_edge: PackedVector2Array
## Lines between neighbouring lanes, from the left of the road to the right.
var dividers: Array[PackedVector2Array] = []
## The OpenStreetMap nodes along the road, in order. Roads that share a node meet there.
var nodes: PackedInt64Array = PackedInt64Array()


## Returns the road along [param way_line], [param lane_count] lanes of
## [param lane_width] wide, with [param way_line] running [param way_position]
## lanes in from its left edge. Left is as seen looking along the line.
static func along(
	way_line: PackedVector2Array, lane_count: int, way_position: float, lane_width: float
) -> RoadStrip:
	var strip: RoadStrip = RoadStrip.new()
	strip.line = way_line
	strip.left_edge = Polyline.offset(way_line, way_position * lane_width)
	strip.right_edge = Polyline.offset(way_line, (way_position - lane_count) * lane_width)
	for lane: int in range(1, lane_count):
		strip.dividers.append(Polyline.offset(way_line, (way_position - lane) * lane_width))
	return strip


## Returns the same road with its lines running the other way, so left and right swap over.
func reversed() -> RoadStrip:
	var strip: RoadStrip = RoadStrip.new()
	strip.line = Polyline.reversed(line)
	strip.left_edge = Polyline.reversed(right_edge)
	strip.right_edge = Polyline.reversed(left_edge)
	for index: int in range(dividers.size() - 1, -1, -1):
		strip.dividers.append(Polyline.reversed(dividers[index]))
	strip.nodes = nodes.duplicate()
	strip.nodes.reverse()
	return strip


## Returns the tarmac the road covers, as a polygon running up one edge and back down the other.
func area() -> PackedVector2Array:
	return left_edge + Polyline.reversed(right_edge)
