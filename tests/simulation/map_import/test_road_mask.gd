extends GutTest

const SIZE: Vector2i = Vector2i(60, 60)


func _band() -> BitMap:
	var mask: BitMap = BitMap.new()
	mask.create(SIZE)
	mask.set_bit_rect(Rect2i(0, 20, SIZE.x, 20), true)
	return mask


func test_small_gaps_in_the_road_are_filled() -> void:
	var surface: BitMap = _band()
	surface.set_bit_rect(Rect2i(30, 29, 6, 2), false)

	var road: BitMap = RoadMask.from_surface(surface)

	assert_true(road.get_bit(32, 30))


func test_specks_away_from_the_road_are_removed() -> void:
	var surface: BitMap = _band()
	surface.set_bit_rect(Rect2i(10, 5, 2, 2), true)

	var road: BitMap = RoadMask.from_surface(surface)

	assert_false(road.get_bit(10, 5))


func test_the_original_mask_is_left_untouched() -> void:
	var surface: BitMap = _band()
	surface.set_bit_rect(Rect2i(10, 5, 2, 2), true)

	RoadMask.from_surface(surface)

	assert_true(surface.get_bit(10, 5))
