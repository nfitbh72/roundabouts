extends GutTest


func test_grey_tarmac_is_surface() -> void:
	assert_true(PixelClassifier.is_surface(90, 90, 95))


func test_green_grass_is_not_surface() -> void:
	assert_false(PixelClassifier.is_surface(70, 120, 50))


func test_black_shadow_is_not_surface() -> void:
	assert_false(PixelClassifier.is_surface(10, 10, 12))


func test_white_paint_is_not_surface() -> void:
	assert_false(PixelClassifier.is_surface(240, 240, 240))


func test_white_paint_on_tarmac_is_marking() -> void:
	assert_true(PixelClassifier.is_marking(240, 240, 240, 100))


func test_worn_paint_still_stands_out_from_dark_tarmac() -> void:
	assert_true(PixelClassifier.is_marking(150, 150, 150, 90))


func test_white_on_a_white_roof_is_not_marking() -> void:
	assert_false(PixelClassifier.is_marking(240, 240, 240, 230))


func test_pale_grey_in_deep_shadow_is_not_marking() -> void:
	assert_false(PixelClassifier.is_marking(80, 80, 80, 20))


func test_yellow_paint_is_marking() -> void:
	assert_true(PixelClassifier.is_marking(230, 200, 40, 200))


func test_tarmac_is_not_marking() -> void:
	assert_false(PixelClassifier.is_marking(90, 90, 95, 90))


func test_red_roof_is_not_marking() -> void:
	assert_false(PixelClassifier.is_marking(200, 80, 60, 100))


func test_background_brightness_has_one_value_per_pixel() -> void:
	var image: Image = JunctionImage.grass(Vector2i(32, 16))

	assert_eq(PixelClassifier.background_brightness(image).size(), 32 * 16)


func test_background_brightness_of_a_plain_image_is_its_brightness() -> void:
	var image: Image = Image.create_empty(32, 32, false, Image.FORMAT_RGBA8)
	image.fill(Color8(100, 100, 100))

	assert_almost_eq(PixelClassifier.background_brightness(image)[200], 100, 1)


func test_surface_mask_picks_out_the_road() -> void:
	var image: Image = JunctionImage.grass(Vector2i(10, 10))
	image.fill_rect(Rect2i(0, 4, 10, 2), JunctionImage.TARMAC)

	var mask: BitMap = PixelClassifier.mask(image, PixelClassifier.Kind.SURFACE)

	assert_eq(mask.get_true_bit_count(), 20)
	assert_true(mask.get_bit(3, 4))
	assert_false(mask.get_bit(3, 3))


func test_marking_mask_picks_out_paint_on_tarmac() -> void:
	var image: Image = Image.create_empty(32, 32, false, Image.FORMAT_RGB8)
	image.fill(JunctionImage.TARMAC)
	image.fill_rect(Rect2i(4, 15, 24, 2), JunctionImage.PAINT)

	var mask: BitMap = PixelClassifier.mask(image, PixelClassifier.Kind.MARKING)

	assert_eq(mask.get_true_bit_count(), 48)
