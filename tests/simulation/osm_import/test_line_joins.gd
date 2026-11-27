extends GutTest

const EAST: PackedVector2Array = [Vector2(0, 0), Vector2(10, 0), Vector2(20, 0)]


func test_trimmed_start_cuts_part_way_along_a_segment() -> void:
	assert_eq(
		LineJoins.trimmed_start(EAST, 15.0), PackedVector2Array([Vector2(15, 0), Vector2(20, 0)])
	)


func test_trimmed_end_cuts_from_the_other_end() -> void:
	assert_eq(
		LineJoins.trimmed_end(EAST, 5.0),
		PackedVector2Array([Vector2(0, 0), Vector2(10, 0), Vector2(15, 0)])
	)


func test_trimming_nothing_keeps_the_line() -> void:
	assert_eq(LineJoins.trimmed_start(EAST, 0.0), EAST)


func test_lines_that_touch_are_simply_joined() -> void:
	var more: PackedVector2Array = [Vector2(20, 0), Vector2(30, 0)]

	assert_eq(LineJoins.tapered(EAST, more).size(), 4)


func test_a_step_sideways_becomes_a_smooth_taper() -> void:
	var a: PackedVector2Array = [Vector2(0, 0), Vector2(50, 0)]
	var b: PackedVector2Array = [Vector2(50, 3), Vector2(100, 3)]

	var joined: PackedVector2Array = LineJoins.tapered(a, b)

	assert_eq(joined[0], a[0])
	assert_eq(joined[-1], b[-1])
	for index: int in range(1, joined.size()):
		assert_true(joined[index].x > joined[index - 1].x, "the taper runs forwards")
		assert_true(joined[index].y >= joined[index - 1].y - 0.001, "and only steps one way")
	assert_almost_eq(Polyline.distance_to(joined, Vector2(41, 0)), 0.0, 0.001)


func test_a_rounded_corner_keeps_the_far_ends_but_not_the_corner() -> void:
	var a: PackedVector2Array = [Vector2(0, 0), Vector2(20, 0)]
	var b: PackedVector2Array = [Vector2(20, 0), Vector2(20, 20)]

	var joined: PackedVector2Array = LineJoins.rounded(a, b, 6.0)

	assert_eq(joined[0], Vector2(0, 0))
	assert_eq(joined[-1], Vector2(20, 20))
	assert_almost_eq(Polyline.distance_to(joined, Vector2(14, 0)), 0.0, 0.001)
	assert_gt(Polyline.distance_to(joined, Vector2(20, 0)), 1.5)


func test_a_short_line_limits_how_much_is_rounded() -> void:
	var a: PackedVector2Array = [Vector2(0, 0), Vector2(20, 0)]
	var b: PackedVector2Array = [Vector2(20, 0), Vector2(20, 2)]

	var joined: PackedVector2Array = LineJoins.rounded(a, b, 6.0)

	assert_almost_eq(Polyline.distance_to(joined, Vector2(19, 0)), 0.0, 0.001)


func test_a_rounded_loop_still_closes() -> void:
	var square: PackedVector2Array = [
		Vector2(0, 0), Vector2(10, 0), Vector2(10, 10), Vector2(0, 10), Vector2(0, 0)
	]

	var loop: PackedVector2Array = LineJoins.rounded_loop(square, 2.0)

	assert_eq(loop[0], loop[-1])
	assert_gt(Polyline.distance_to(loop, Vector2(0, 0)), 0.3)
