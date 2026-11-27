class_name KerbCorners
extends RefCounted
## Joins road edges that meet at a corner into one kerb, with the corner
## rounded off, as a real kerb is.
##
## Where roads meet, each road's edges are cut where they run onto another
## road, and the cut ends of two edges land on the same point: the corner.

## Edge ends closer than this, in metres, meet.
const MEETING_DISTANCE: float = 0.1


## Returns [param edges] with every pair that meets end to end joined into one
## kerb, each corner rounded off by up to [param radius] metres.
static func joined(edges: Array[PackedVector2Array], radius: float) -> Array[PackedVector2Array]:
	var partners: PackedInt32Array = EndLinks.linked(edges.size(), _meetings(edges))
	var kerbs: Array[PackedVector2Array] = []
	for run: PackedInt32Array in EndLinks.runs(edges.size(), partners):
		kerbs.append(_kerb(edges, run, radius))
	return kerbs


## Returns every pair of ends of different edges that meet, nearest first.
static func _meetings(edges: Array[PackedVector2Array]) -> Array[Vector2i]:
	var close: Array[Vector3] = []
	for a: int in edges.size() * 2:
		for b: int in range(a + 1, edges.size() * 2):
			var gap: float = _point(edges, a).distance_to(_point(edges, b))
			if gap < MEETING_DISTANCE and EndLinks.item(a) != EndLinks.item(b):
				close.append(Vector3(a, b, gap))
	close.sort_custom(func(first: Vector3, second: Vector3) -> bool: return first.z < second.z)
	var pairs: Array[Vector2i] = []
	for pair: Vector3 in close:
		pairs.append(Vector2i(int(pair.x), int(pair.y)))
	return pairs


static func _point(edges: Array[PackedVector2Array], end: int) -> Vector2:
	var edge: PackedVector2Array = edges[EndLinks.item(end)]
	return edge[-1] if EndLinks.is_end(end) else edge[0]


## Joins the edges entered by each end in [param run] into one kerb.
static func _kerb(
	edges: Array[PackedVector2Array], run: PackedInt32Array, radius: float
) -> PackedVector2Array:
	var kerb: PackedVector2Array = PackedVector2Array()
	for entry: int in run:
		if entry < 0:
			return LineJoins.rounded_loop(kerb, radius)
		var edge: PackedVector2Array = edges[EndLinks.item(entry)]
		if EndLinks.is_end(entry):
			edge = Polyline.reversed(edge)
		kerb = edge if kerb.is_empty() else LineJoins.rounded(kerb, edge, radius)
	return kerb
