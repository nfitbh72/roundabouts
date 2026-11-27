extends GutTest


func _across(y: float, from: float = 0.0, to: float = 200.0) -> PackedVector2Array:
	return PackedVector2Array([Vector2(from, y), Vector2(to, y)])


func test_spacing_of_parallel_lines_is_the_distance_between_them() -> void:
	assert_almost_eq(LaneGroups.spacing(_across(10), _across(40)), 30.0, 0.01)


func test_spacing_works_when_the_lines_run_opposite_ways() -> void:
	assert_almost_eq(LaneGroups.spacing(_across(10), Polyline.reversed(_across(40))), 30.0, 0.01)


func test_lines_at_an_angle_have_no_spacing() -> void:
	var slanted: PackedVector2Array = PackedVector2Array([Vector2(0, 0), Vector2(100, 100)])

	assert_eq(LaneGroups.spacing(_across(10), slanted), INF)


func test_lines_that_do_not_overlap_have_no_spacing() -> void:
	assert_eq(LaneGroups.spacing(_across(10, 0, 50), _across(40, 100, 200)), INF)


func test_lane_width_is_the_usual_gap_between_neighbours() -> void:
	var lines: Array[PackedVector2Array] = [_across(10), _across(40), _across(70), _across(100)]

	assert_almost_eq(LaneGroups.lane_width(lines), 30.0, 0.01)


func test_lane_width_ignores_double_lines() -> void:
	var lines: Array[PackedVector2Array] = [_across(10), _across(12), _across(42), _across(72)]

	assert_almost_eq(LaneGroups.lane_width(lines), 30.0, 0.01)


func test_lane_width_falls_back_when_there_is_only_one_line() -> void:
	assert_eq(LaneGroups.lane_width([_across(10)]), LaneGroups.DEFAULT_LANE_WIDTH)


func test_neighbouring_lines_are_one_road() -> void:
	var lines: Array[PackedVector2Array] = [_across(10), _across(40), _across(70)]

	assert_eq(LaneGroups.group(lines, 30.0).size(), 1)


func test_distant_lines_are_separate_roads() -> void:
	var lines: Array[PackedVector2Array] = [_across(10), _across(40), _across(200)]

	var roads: Array = LaneGroups.group(lines, 30.0)

	assert_eq(roads.size(), 2)
	assert_eq(roads[0].size(), 2)
	assert_eq(roads[1].size(), 1)
