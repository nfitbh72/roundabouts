class_name JunctionLines
extends RefCounted
## Spots painted lines in and around a junction: stop lines, crossing edges and
## guide lines through the junction. They are real paint on real tarmac, but
## they cross the roads rather than run along them, so road edges built beside
## them end up in the middle of the junction.
##
## A line counts as one if another line meets or crosses it at a steep angle
## within one lane width. Lane lines that end at the mouth of a junction are
## caught too, which loses some edges but never places one wrongly.

## Smallest angle between two lines, in degrees, for them to meet steeply.
const MIN_ANGLE_DEGREES: float = 45.0


## Returns the lines in [param lines] that are well away from any junction,
## given lanes [param width] pixels wide.
static func away_from_junctions(
	lines: Array[PackedVector2Array], width: float
) -> Array[PackedVector2Array]:
	var kept: Array[PackedVector2Array] = []
	for line: PackedVector2Array in lines:
		if not is_near_junction(line, lines, width):
			kept.append(line)
	return kept


## Returns true if any of [param others] meets [param line] at a steep angle
## within [param reach] pixels.
static func is_near_junction(
	line: PackedVector2Array, others: Array[PackedVector2Array], reach: float
) -> bool:
	var steep: float = cos(deg_to_rad(MIN_ANGLE_DEGREES))
	for other: PackedVector2Array in others:
		if other == line:
			continue
		if absf(Polyline.direction(line).dot(Polyline.direction(other))) > steep:
			continue
		if Polyline.distance_between(line, other) <= reach:
			return true
	return false
