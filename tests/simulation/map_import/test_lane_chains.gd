extends GutTest


func _mark(from: Vector2, to: Vector2) -> PackedVector2Array:
	return PackedVector2Array([from, to])


## Dashes along y = [param y], [param count] of them, 12 long with gaps of [param gap].
func _dashes(y: float, count: int, gap: float) -> Array[PackedVector2Array]:
	var marks: Array[PackedVector2Array] = []
	for index: int in count:
		var x: float = index * (12.0 + gap)
		marks.append(_mark(Vector2(x, y), Vector2(x + 12.0, y)))
	return marks


func test_dashes_in_a_row_can_join() -> void:
	assert_true(
		LaneChains.can_join(
			_mark(Vector2(0, 0), Vector2(12, 0)), _mark(Vector2(20, 0), Vector2(32, 0))
		)
	)


func test_dashes_running_opposite_ways_can_still_join() -> void:
	assert_true(
		LaneChains.can_join(
			_mark(Vector2(0, 0), Vector2(12, 0)), _mark(Vector2(32, 0), Vector2(20, 0))
		)
	)


func test_dashes_side_by_side_cannot_join() -> void:
	assert_false(
		LaneChains.can_join(
			_mark(Vector2(0, 0), Vector2(12, 0)), _mark(Vector2(0, 10), Vector2(12, 10))
		)
	)


func test_dashes_at_right_angles_cannot_join() -> void:
	assert_false(
		LaneChains.can_join(
			_mark(Vector2(0, 0), Vector2(12, 0)), _mark(Vector2(20, -6), Vector2(20, 6))
		)
	)


func test_dashes_too_far_apart_cannot_join() -> void:
	var gap: float = LaneChains.MAX_GAP + 5.0

	assert_false(
		LaneChains.can_join(
			_mark(Vector2(0, 0), Vector2(12, 0)), _mark(Vector2(12 + gap, 0), Vector2(24 + gap, 0))
		)
	)


func test_a_row_of_dashes_becomes_one_lane_line() -> void:
	var lines: Array[PackedVector2Array] = LaneChains.join(_dashes(50.0, 8, 8.0))

	assert_eq(lines.size(), 1)
	assert_almost_eq(lines[0][0].x, 0.0, 0.01)
	assert_almost_eq(lines[0][-1].x, 152.0, 0.01)


func test_two_rows_of_dashes_become_two_lane_lines() -> void:
	var marks: Array[PackedVector2Array] = _dashes(20.0, 8, 8.0)
	marks.append_array(_dashes(50.0, 8, 8.0))

	assert_eq(LaneChains.join(marks).size(), 2)


func test_too_few_dashes_are_not_a_lane_line() -> void:
	assert_eq(LaneChains.join(_dashes(50.0, LaneChains.MIN_MARKS - 1, 8.0)).size(), 0)


func test_a_lone_solid_line_is_not_a_lane_line() -> void:
	var marks: Array[PackedVector2Array] = [_mark(Vector2(0, 0), Vector2(200, 0))]

	assert_eq(LaneChains.join(marks).size(), 0)


func test_centre_line_moves_steadily_forwards() -> void:
	var line: PackedVector2Array = LaneChains.centre_line(_dashes(50.0, 6, 8.0))

	for index: int in range(1, line.size()):
		assert_gt(line[index].x, line[index - 1].x)


func test_centre_line_smooths_marks_that_sit_askew() -> void:
	var marks: Array[PackedVector2Array] = _dashes(50.0, 6, 8.0)
	marks.append(_mark(Vector2(40, 48), Vector2(46, 52)))

	for point: Vector2 in LaneChains.centre_line(marks):
		assert_almost_eq(point.y, 50.0, 1.0)
