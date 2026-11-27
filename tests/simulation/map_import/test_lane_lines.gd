extends GutTest


func _pixels_in(rect: Rect2i) -> PackedVector2Array:
	var pixels: PackedVector2Array = PackedVector2Array()
	for y: int in range(rect.position.y, rect.end.y):
		for x: int in range(rect.position.x, rect.end.x):
			pixels.append(Vector2(x, y))
	return pixels


func _mask_with(rect: Rect2i) -> BitMap:
	var mask: BitMap = BitMap.new()
	mask.create(Vector2i(60, 60))
	mask.set_bit_rect(rect, true)
	return mask


func test_a_long_thin_mark_becomes_a_line_through_its_middle() -> void:
	var line: PackedVector2Array = LaneLines.line_through(_pixels_in(Rect2i(10, 20, 12, 2)))

	assert_eq(line.size(), 2)
	var ends: Array[float] = [minf(line[0].x, line[1].x), maxf(line[0].x, line[1].x)]
	assert_almost_eq(ends[0], 10.5, 0.01)
	assert_almost_eq(ends[1], 21.5, 0.01)
	assert_almost_eq(line[0].y, 21.0, 0.01)
	assert_almost_eq(line[1].y, 21.0, 0.01)


func test_a_vertical_mark_becomes_a_vertical_line() -> void:
	var line: PackedVector2Array = LaneLines.line_through(_pixels_in(Rect2i(5, 5, 2, 10)))

	assert_eq(line.size(), 2)
	assert_almost_eq(line[0].x, line[1].x, 0.01)


func test_a_square_blob_is_not_a_lane_line() -> void:
	assert_true(LaneLines.line_through(_pixels_in(Rect2i(0, 0, 8, 8))).is_empty())


func test_a_short_mark_is_not_a_lane_line() -> void:
	assert_true(LaneLines.line_through(_pixels_in(Rect2i(0, 0, 4, 1))).is_empty())


func test_no_pixels_is_no_line() -> void:
	assert_true(LaneLines.line_through(PackedVector2Array()).is_empty())


func test_find_keeps_paint_in_the_middle_of_the_road() -> void:
	var road: BitMap = _mask_with(Rect2i(0, 20, 60, 20))
	var marking: BitMap = _mask_with(Rect2i(10, 29, 15, 2))

	assert_eq(LaneLines.find(marking, road).size(), 1)


func test_find_ignores_paint_along_the_edge_of_the_road() -> void:
	var road: BitMap = _mask_with(Rect2i(0, 20, 60, 20))
	var marking: BitMap = _mask_with(Rect2i(10, 20, 15, 2))

	assert_eq(LaneLines.find(marking, road).size(), 0)


func test_find_ignores_white_things_off_the_road() -> void:
	var road: BitMap = _mask_with(Rect2i(0, 20, 60, 20))
	var marking: BitMap = _mask_with(Rect2i(10, 5, 15, 2))

	assert_eq(LaneLines.find(marking, road).size(), 0)
