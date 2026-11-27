extends GutTest


func _mask_with(rects: Array[Rect2i]) -> BitMap:
	var mask: BitMap = BitMap.new()
	mask.create(Vector2i(20, 20))
	for rect: Rect2i in rects:
		mask.set_bit_rect(rect, true)
	return mask


func test_an_empty_mask_has_no_shapes() -> void:
	assert_eq(PixelComponents.find(_mask_with([])).size(), 0)


func test_separate_blobs_are_separate_shapes() -> void:
	var mask: BitMap = _mask_with([Rect2i(1, 1, 3, 3), Rect2i(10, 10, 2, 4)])

	var shapes: Array[PackedVector2Array] = PixelComponents.find(mask)

	assert_eq(shapes.size(), 2)
	assert_eq(shapes[0].size(), 9)
	assert_eq(shapes[1].size(), 8)


func test_pixels_touching_at_a_corner_are_one_shape() -> void:
	var mask: BitMap = _mask_with([Rect2i(1, 1, 1, 1), Rect2i(2, 2, 1, 1)])

	assert_eq(PixelComponents.find(mask).size(), 1)


func test_shapes_reaching_the_edge_of_the_mask_are_found() -> void:
	var mask: BitMap = _mask_with([Rect2i(0, 19, 20, 1)])

	var shapes: Array[PackedVector2Array] = PixelComponents.find(mask)

	assert_eq(shapes.size(), 1)
	assert_eq(shapes[0].size(), 20)
