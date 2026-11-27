extends GutTest


func _tarmac() -> BitMap:
	var surface: BitMap = BitMap.new()
	surface.create(Vector2i(40, 40))
	surface.set_bit_rect(Rect2i(0, 10, 40, 20), true)
	return surface


func _square(corner: Vector2i, side: int) -> PackedVector2Array:
	var pixels: PackedVector2Array = PackedVector2Array()
	for y: int in side:
		for x: int in side:
			pixels.append(Vector2(corner + Vector2i(x, y)))
	return pixels


func test_a_small_speck_on_tarmac_is_found_at_its_centre() -> void:
	var specks: PackedVector2Array = PaintSpecks.find([_square(Vector2i(19, 19), 2)], _tarmac())

	assert_eq(specks, PackedVector2Array([Vector2(20, 20)]))


func test_a_speck_off_the_tarmac_is_ignored() -> void:
	assert_eq(PaintSpecks.find([_square(Vector2i(19, 2), 2)], _tarmac()).size(), 0)


func test_a_speck_at_the_edge_of_the_tarmac_is_ignored() -> void:
	assert_eq(PaintSpecks.find([_square(Vector2i(19, 10), 2)], _tarmac()).size(), 0)


func test_a_shape_too_big_to_be_a_speck_is_ignored() -> void:
	assert_eq(PaintSpecks.find([_square(Vector2i(16, 16), 4)], _tarmac()).size(), 0)


func test_is_on_tarmac_needs_tarmac_most_of_the_way_round() -> void:
	assert_true(PaintSpecks.is_on_tarmac(Vector2(20, 20), _tarmac()))
	assert_false(PaintSpecks.is_on_tarmac(Vector2(20, 11), _tarmac()))
