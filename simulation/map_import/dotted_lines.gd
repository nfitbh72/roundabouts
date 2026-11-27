class_name DottedLines
extends RefCounted
## Finds straight rows of evenly spread points, such as the specks left by
## faint dashed lane lines, using a Hough transform.
##
## Every point votes for each straight line that could pass through it. Lines
## through many points collect many votes, so they stand out even when each
## point on its own is too faint to trust.

## How many directions lines are tried in, across half a turn.
const ANGLE_STEPS: int = 90
## How finely lines are told apart by their distance from the corner, in pixels.
const DISTANCE_STEP: float = 2.0
## How far a point may be from a line and still be on it, in pixels.
const ON_LINE_DISTANCE: float = 1.5
## Largest gap between neighbouring points in the same row, in pixels.
const MAX_GAP: float = 22.0
## A row needs at least this many points, spanning at least this far.
const MIN_POINTS: int = 5
const MIN_SPAN: float = 50.0
## Most lines to try before giving up, to keep the search quick.
const MAX_TRIES: int = 60


## Returns a two-point line for each row of [param points] found, in an image of [param size].
static func find(points: PackedVector2Array, size: Vector2i) -> Array[PackedVector2Array]:
	var reach: float = Vector2(size).length()
	var distance_steps: int = ceili(reach * 2.0 / DISTANCE_STEP) + 1
	var votes: PackedInt32Array = PackedInt32Array()
	votes.resize(ANGLE_STEPS * distance_steps)
	for point: Vector2 in points:
		_vote(votes, point, reach, distance_steps, 1)
	var used: PackedByteArray = PackedByteArray()
	used.resize(points.size())
	var lines: Array[PackedVector2Array] = []
	for attempt: int in MAX_TRIES:
		var best: int = _most_voted(votes)
		if votes[best] < MIN_POINTS:
			break
		var angle: int = floori(float(best) / distance_steps)
		var normal: Vector2 = Vector2.from_angle(PI * angle / ANGLE_STEPS)
		var distance: float = (best % distance_steps + 0.5) * DISTANCE_STEP - reach
		for row: PackedInt32Array in rows_on(points, used, normal, distance):
			lines.append(PackedVector2Array([points[row[0]], points[row[-1]]]))
			for index: int in row:
				used[index] = 1
				_vote(votes, points[index], reach, distance_steps, -1)
		# Whatever is left on this line is not a row, so stop it winning again.
		votes[best] = 0
	return lines


## Returns the rows of unused [param points] lying on the line whose unit
## [param normal] and [param distance] from the corner are given. Each row is a
## list of point indices in order along the line.
static func rows_on(
	points: PackedVector2Array, used: PackedByteArray, normal: Vector2, distance: float
) -> Array[PackedInt32Array]:
	var along: Vector2 = normal.orthogonal()
	var on_line: Array[int] = []
	for index: int in points.size():
		var away: float = absf(points[index].dot(normal) - distance)
		if used[index] == 0 and away <= ON_LINE_DISTANCE + DISTANCE_STEP / 2.0:
			on_line.append(index)
	on_line.sort_custom(
		func(a: int, b: int) -> bool: return points[a].dot(along) < points[b].dot(along)
	)
	var rows: Array[PackedInt32Array] = []
	var row: PackedInt32Array = PackedInt32Array()
	for index: int in on_line:
		if not row.is_empty() and points[index].dot(along) - points[row[-1]].dot(along) > MAX_GAP:
			_keep_if_row(row, points, along, rows)
			row = PackedInt32Array()
		row.append(index)
	_keep_if_row(row, points, along, rows)
	return rows


## Returns the lines in [param found] that do not duplicate any of [param existing]:
## parallel and within [param close] pixels of one of them.
static func new_lines(
	found: Array[PackedVector2Array], existing: Array[PackedVector2Array], close: float
) -> Array[PackedVector2Array]:
	var fresh: Array[PackedVector2Array] = []
	for line: PackedVector2Array in found:
		var is_copy: bool = existing.any(
			func(other: PackedVector2Array) -> bool: return LaneGroups.spacing(line, other) <= close
		)
		if not is_copy:
			fresh.append(line)
	return fresh


static func _vote(
	votes: PackedInt32Array, point: Vector2, reach: float, distance_steps: int, amount: int
) -> void:
	for angle: int in ANGLE_STEPS:
		var normal: Vector2 = Vector2.from_angle(PI * angle / ANGLE_STEPS)
		var slot: int = floori((point.dot(normal) + reach) / DISTANCE_STEP)
		votes[angle * distance_steps + slot] += amount


static func _most_voted(votes: PackedInt32Array) -> int:
	var best: int = 0
	for index: int in votes.size():
		if votes[index] > votes[best]:
			best = index
	return best


static func _keep_if_row(
	row: PackedInt32Array, points: PackedVector2Array, along: Vector2, rows: Array[PackedInt32Array]
) -> void:
	if row.size() < MIN_POINTS:
		return
	if points[row[-1]].dot(along) - points[row[0]].dot(along) >= MIN_SPAN:
		rows.append(row)
