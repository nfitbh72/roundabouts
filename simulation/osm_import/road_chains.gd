class_name RoadChains
extends RefCounted
## Joins the stretches of a road that OpenStreetMap splits into several ways,
## as it does wherever the number of lanes changes, into one strip.
##
## Two strips join where they share an end node that no road passes through,
## if they are the only two there or if they carry straight on from each other
## while others branch off, as where a slip road joins. Where their widths
## differ, the edges taper from one to the other. Lane lines that line up are
## joined, and a lane line for a lane that appears starts at the joint.

## How far apart, in lane widths, two lane lines may be at a joint and still be
## taken for the same line.
const SAME_LINE_LANES: float = 0.6
## Where more than two roads end at a node, two of them carry straight on from
## each other if they turn by less than this, in degrees.
const MOST_STRAIGHT_ON_TURN: float = 35.0


## Returns [param strips] with every chain of stretches that continue one
## another joined into one strip, its lines running along the chain.
static func chained(strips: Array[RoadStrip], lane_width: float) -> Array[RoadStrip]:
	var partners: PackedInt32Array = EndLinks.linked(strips.size(), _joints(strips))
	var result: Array[RoadStrip] = []
	for run: PackedInt32Array in EndLinks.runs(strips.size(), partners):
		result.append(_joined_run(strips, run, lane_width * SAME_LINE_LANES))
	return result


## Returns pairs of strip ends that may join, straightest first.
static func _joints(strips: Array[RoadStrip]) -> Array[Vector2i]:
	var ends_at: Dictionary[int, PackedInt32Array] = {}
	var passed_through: Dictionary[int, bool] = {}
	for index: int in strips.size():
		var nodes: PackedInt64Array = strips[index].nodes
		if nodes.size() < 2:
			continue
		ends_at[nodes[0]] = (
			ends_at.get(nodes[0], PackedInt32Array()) + PackedInt32Array([index * 2])
		)
		ends_at[nodes[-1]] = (
			ends_at.get(nodes[-1], PackedInt32Array()) + PackedInt32Array([index * 2 + 1])
		)
		for node: int in nodes.slice(1, -1):
			passed_through[node] = true
	var candidates: Array[Vector3] = []
	for node: int in ends_at:
		if not passed_through.has(node):
			candidates.append_array(_straight_pairs(strips, ends_at[node]))
	candidates.sort_custom(func(a: Vector3, b: Vector3) -> bool: return a.z < b.z)
	var joints: Array[Vector2i] = []
	for candidate: Vector3 in candidates:
		joints.append(Vector2i(int(candidate.x), int(candidate.y)))
	return joints


## Returns the pairs among strip [param ends] at one node that may join, as
## Vector3(end, end, turn), where turn is the cosine of the angle between the
## two strips' directions away from the node: -1 for dead straight. Two ends
## alone always may.
static func _straight_pairs(strips: Array[RoadStrip], ends: PackedInt32Array) -> Array[Vector3]:
	var pairs: Array[Vector3] = []
	var straightest: float = -cos(deg_to_rad(MOST_STRAIGHT_ON_TURN))
	for a: int in ends.size():
		for b: int in range(a + 1, ends.size()):
			var turn: float = _away(strips, ends[a]).dot(_away(strips, ends[b]))
			if ends.size() == 2 or turn < straightest:
				pairs.append(Vector3(ends[a], ends[b], turn))
	return pairs


## Returns the direction strip [param end] leaves its node in.
static func _away(strips: Array[RoadStrip], end: int) -> Vector2:
	var line: PackedVector2Array = strips[EndLinks.item(end)].line
	if EndLinks.is_end(end):
		return (line[-2] - line[-1]).normalized()
	return (line[1] - line[0]).normalized()


## Joins the strips entered by each end in [param run] into one, end to end.
static func _joined_run(
	strips: Array[RoadStrip], run: PackedInt32Array, same_line: float
) -> RoadStrip:
	var chain: RoadStrip = null
	var open: PackedInt32Array = PackedInt32Array()
	for entry: int in run:
		if entry < 0:
			break
		var strip: RoadStrip = strips[EndLinks.item(entry)]
		if EndLinks.is_end(entry):
			strip = strip.reversed()
		if chain == null:
			chain = strip
			open = PackedInt32Array(range(strip.dividers.size()))
			continue
		var joined: RoadStrip = RoadStrip.new()
		joined.left_edge = LineJoins.tapered(chain.left_edge, strip.left_edge)
		joined.right_edge = LineJoins.tapered(chain.right_edge, strip.right_edge)
		joined.dividers = chain.dividers.duplicate()
		open = _join_dividers(joined.dividers, open, strip.dividers, same_line)
		joined.line = chain.line + strip.line.slice(1)
		joined.nodes = chain.nodes + strip.nodes.slice(1)
		chain = joined
	return chain


## Continues the lane lines [param dividers] listed in [param open], which end
## at the joint, with the matching lines of [param more], which start there,
## and adds any of [param more] left over. Changes [param dividers] in place,
## and returns which of them now end at the far end of [param more].
static func _join_dividers(
	dividers: Array[PackedVector2Array],
	open: PackedInt32Array,
	more: Array[PackedVector2Array],
	same_line: float,
) -> PackedInt32Array:
	var still_open: PackedInt32Array = PackedInt32Array()
	for divider: PackedVector2Array in more:
		var best: int = -1
		var nearest: float = same_line
		for index: int in open:
			var gap: float = dividers[index][-1].distance_to(divider[0])
			if gap < nearest and not still_open.has(index):
				best = index
				nearest = gap
		if best < 0:
			dividers.append(divider)
			best = dividers.size() - 1
		else:
			dividers[best] = LineJoins.tapered(dividers[best], divider)
		still_open.append(best)
	return still_open
