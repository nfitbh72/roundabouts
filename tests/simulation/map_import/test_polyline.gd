extends GutTest

const RIGHTWARDS: PackedVector2Array = [Vector2(0, 0), Vector2(10, 0), Vector2(30, 0)]


func test_length_adds_up_the_segments() -> void:
	assert_eq(Polyline.length(RIGHTWARDS), 30.0)


func test_longest_picks_the_longest_line() -> void:
	var short: PackedVector2Array = PackedVector2Array([Vector2.ZERO, Vector2(5, 0)])

	assert_eq(Polyline.longest([short, RIGHTWARDS]), RIGHTWARDS)


func test_direction_runs_from_first_to_last_point() -> void:
	assert_eq(Polyline.direction(RIGHTWARDS), Vector2.RIGHT)


func test_centre_is_the_average_point() -> void:
	assert_almost_eq(Polyline.centre(RIGHTWARDS), Vector2(40.0 / 3.0, 0), Vector2(0.01, 0.01))


func test_facing_turns_a_line_that_runs_the_wrong_way() -> void:
	var turned: PackedVector2Array = Polyline.facing(RIGHTWARDS, Vector2.LEFT)

	assert_eq(turned[0], Vector2(30, 0))
	assert_eq(turned[-1], Vector2(0, 0))


func test_facing_leaves_a_line_already_running_that_way() -> void:
	assert_eq(Polyline.facing(RIGHTWARDS, Vector2(1, 0.5)), RIGHTWARDS)


func test_normals_point_to_the_left_of_travel_on_screen() -> void:
	for normal: Vector2 in Polyline.normals(RIGHTWARDS):
		assert_eq(normal, Vector2(0, -1))


func test_offset_moves_the_line_sideways() -> void:
	var moved: PackedVector2Array = Polyline.offset(RIGHTWARDS, 5.0)

	assert_eq(moved, PackedVector2Array([Vector2(0, -5), Vector2(10, -5), Vector2(30, -5)]))


func test_resampled_spaces_points_evenly_and_keeps_the_end() -> void:
	var points: PackedVector2Array = Polyline.resampled(RIGHTWARDS, 8.0)

	assert_eq(
		points,
		PackedVector2Array(
			[Vector2(0, 0), Vector2(8, 0), Vector2(16, 0), Vector2(24, 0), Vector2(30, 0)]
		)
	)


func test_distance_to_measures_to_the_nearest_segment() -> void:
	assert_eq(Polyline.distance_to(RIGHTWARDS, Vector2(20, 7)), 7.0)


func test_distance_to_beyond_the_end_measures_to_the_end() -> void:
	assert_eq(Polyline.distance_to(RIGHTWARDS, Vector2(34, 3)), 5.0)


func test_distance_between_crossing_lines_is_zero() -> void:
	var upwards: PackedVector2Array = PackedVector2Array([Vector2(15, -10), Vector2(15, 10)])

	assert_eq(Polyline.distance_between(RIGHTWARDS, upwards), 0.0)


func test_distance_between_separate_lines_is_the_closest_gap() -> void:
	var beyond: PackedVector2Array = PackedVector2Array([Vector2(36, 8), Vector2(60, 40)])

	assert_eq(Polyline.distance_between(RIGHTWARDS, beyond), 10.0)


func test_extent_along_gives_lowest_and_highest_positions() -> void:
	assert_eq(Polyline.extent_along(RIGHTWARDS, Vector2(10, 0), Vector2.RIGHT), Vector2(-10, 20))
