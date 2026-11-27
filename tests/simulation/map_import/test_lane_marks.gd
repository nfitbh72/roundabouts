extends GutTest

const SIZE: Vector2i = Vector2i(60, 60)


func _pixels_in(rect: Rect2i) -> PackedVector2Array:
	var pixels: PackedVector2Array = PackedVector2Array()
	for y: int in range(rect.position.y, rect.end.y):
		for x: int in range(rect.position.x, rect.end.x):
			pixels.append(Vector2(x, y))
	return pixels


func _mask_with(rect: Rect2i) -> BitMap:
	var mask: BitMap = BitMap.new()
	mask.create(SIZE)
	mask.set_bit_rect(rect, true)
	return mask


func test_a_long_thin_mark_becomes_a_line_through_its_middle() -> void:
	var line: PackedVector2Array = LaneMarks.line_through(_pixels_in(Rect2i(10, 20, 12, 2)))

	assert_eq(line.size(), 2)
	assert_almost_eq(minf(line[0].x, line[1].x), 10.5, 0.01)
	assert_almost_eq(maxf(line[0].x, line[1].x), 21.5, 0.01)
	assert_almost_eq(line[0].y, 21.0, 0.01)
	assert_almost_eq(line[1].y, 21.0, 0.01)


func test_a_vertical_mark_becomes_a_vertical_line() -> void:
	var line: PackedVector2Array = LaneMarks.line_through(_pixels_in(Rect2i(5, 5, 2, 10)))

	assert_eq(line.size(), 2)
	assert_almost_eq(line[0].x, line[1].x, 0.01)


func test_a_square_blob_is_not_a_lane_mark() -> void:
	assert_true(LaneMarks.line_through(_pixels_in(Rect2i(0, 0, 8, 8))).is_empty())


func test_a_short_mark_is_not_a_lane_mark() -> void:
	assert_true(LaneMarks.line_through(_pixels_in(Rect2i(0, 0, 4, 1))).is_empty())


func test_no_pixels_is_no_line() -> void:
	assert_true(LaneMarks.line_through(PackedVector2Array()).is_empty())


func test_paint_in_the_middle_of_tarmac_has_tarmac_both_sides() -> void:
	var line: PackedVector2Array = PackedVector2Array([Vector2(10, 30), Vector2(30, 30)])

	assert_true(LaneMarks.has_tarmac_both_sides(line, _mask_with(Rect2i(0, 15, 60, 30))))


func test_paint_along_the_edge_of_tarmac_does_not() -> void:
	var line: PackedVector2Array = PackedVector2Array([Vector2(10, 16), Vector2(30, 16)])

	assert_false(LaneMarks.has_tarmac_both_sides(line, _mask_with(Rect2i(0, 15, 60, 30))))


func test_tarmac_share_counts_only_the_side_asked_about() -> void:
	var line: PackedVector2Array = PackedVector2Array([Vector2(10, 30), Vector2(30, 30)])
	var below_only: BitMap = _mask_with(Rect2i(0, 31, 60, 29))

	assert_eq(LaneMarks.tarmac_share(line, below_only, 1.0), 0.0)
	assert_eq(LaneMarks.tarmac_share(line, below_only, -1.0), 1.0)


func test_find_keeps_marks_on_tarmac_and_drops_the_rest() -> void:
	var marking: BitMap = _mask_with(Rect2i(10, 29, 15, 2))
	marking.set_bit_rect(Rect2i(10, 5, 15, 2), true)

	var marks: Array[PackedVector2Array] = LaneMarks.find(
		PixelComponents.find(marking), _mask_with(Rect2i(0, 15, 60, 30))
	)

	assert_eq(marks.size(), 1)
	assert_almost_eq(marks[0][0].y, 30.0, 0.01)
