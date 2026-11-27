extends GutTest


func test_grey_tarmac_is_surface() -> void:
	assert_true(PixelClassifier.is_surface(90, 90, 95))


func test_green_grass_is_not_surface() -> void:
	assert_false(PixelClassifier.is_surface(70, 120, 50))


func test_black_shadow_is_not_surface() -> void:
	assert_false(PixelClassifier.is_surface(10, 10, 12))


func test_white_paint_is_not_surface() -> void:
	assert_false(PixelClassifier.is_surface(240, 240, 240))


func test_white_paint_is_marking() -> void:
	assert_true(PixelClassifier.is_marking(240, 240, 240))


func test_yellow_paint_is_marking() -> void:
	assert_true(PixelClassifier.is_marking(230, 200, 40))


func test_tarmac_is_not_marking() -> void:
	assert_false(PixelClassifier.is_marking(90, 90, 95))


func test_red_roof_is_not_marking() -> void:
	assert_false(PixelClassifier.is_marking(200, 80, 60))


func test_surface_mask_picks_out_the_road() -> void:
	var image: Image = JunctionImage.grass(Vector2i(10, 10))
	image.fill_rect(Rect2i(0, 4, 10, 2), JunctionImage.TARMAC)

	var mask: BitMap = PixelClassifier.mask(image, PixelClassifier.Kind.SURFACE)

	assert_eq(mask.get_true_bit_count(), 20)
	assert_true(mask.get_bit(3, 4))
	assert_false(mask.get_bit(3, 3))


func test_mask_accepts_images_in_other_formats() -> void:
	var image: Image = Image.create_empty(4, 4, false, Image.FORMAT_RGB8)
	image.fill(JunctionImage.PAINT)

	var mask: BitMap = PixelClassifier.mask(image, PixelClassifier.Kind.MARKING)

	assert_eq(mask.get_true_bit_count(), 16)
