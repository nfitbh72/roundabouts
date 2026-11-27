extends GutTest

const REACH: float = 20.0


func _line(from: Vector2, to: Vector2) -> PackedVector2Array:
	return PackedVector2Array([from, to])


func test_parallel_lane_lines_are_not_near_a_junction() -> void:
	var lines: Array[PackedVector2Array] = [
		_line(Vector2(0, 50), Vector2(200, 50)), _line(Vector2(0, 70), Vector2(200, 70))
	]

	assert_eq(JunctionLines.away_from_junctions(lines, REACH).size(), 2)


func test_lines_crossing_at_right_angles_are_both_left_out() -> void:
	var lines: Array[PackedVector2Array] = [
		_line(Vector2(0, 50), Vector2(200, 50)), _line(Vector2(100, 0), Vector2(100, 100))
	]

	assert_eq(JunctionLines.away_from_junctions(lines, REACH).size(), 0)


func test_a_line_ending_beside_a_stop_line_is_near_a_junction() -> void:
	var stop_line: PackedVector2Array = _line(Vector2(100, 0), Vector2(100, 100))
	var lane_line: PackedVector2Array = _line(Vector2(110, 50), Vector2(300, 50))

	assert_true(JunctionLines.is_near_junction(lane_line, [stop_line, lane_line], REACH))


func test_a_steep_line_far_away_does_not_count() -> void:
	var lane_line: PackedVector2Array = _line(Vector2(0, 50), Vector2(200, 50))
	var far_away: PackedVector2Array = _line(Vector2(400, 0), Vector2(400, 100))

	assert_false(JunctionLines.is_near_junction(lane_line, [lane_line, far_away], REACH))


func test_a_gentle_angle_does_not_count() -> void:
	var lane_line: PackedVector2Array = _line(Vector2(0, 50), Vector2(200, 50))
	var curving: PackedVector2Array = _line(Vector2(200, 55), Vector2(400, 100))

	assert_false(JunctionLines.is_near_junction(lane_line, [lane_line, curving], REACH))
