extends GutTest


func _image() -> Image:
	var image: Image = Image.create_empty(10, 10, false, Image.FORMAT_RGBA8)
	image.fill(Color8(100, 100, 100))
	return image


func test_at_reads_one_pixel() -> void:
	var image: Image = _image()
	image.set_pixel(3, 4, Color8(10, 20, 30))

	assert_eq(PixelColours.at(image, Vector2i(3, 4)), Vector3(10, 20, 30))


func test_smoothed_averages_a_pixel_and_its_neighbours() -> void:
	var image: Image = _image()
	image.set_pixel(5, 5, Color8(200, 200, 200))

	assert_eq(PixelColours.smoothed(image, Vector2i(5, 5)), Vector3(120, 120, 120))


func test_smoothed_leaves_out_neighbours_off_the_image() -> void:
	var image: Image = _image()
	image.set_pixel(0, 0, Color8(40, 40, 40))

	assert_eq(PixelColours.smoothed(image, Vector2i(0, 0)), Vector3(80, 80, 80))


func test_average_of_points_off_the_image_is_marked_missing() -> void:
	var points: PackedVector2Array = PackedVector2Array([Vector2(-5, -5), Vector2(50, 50)])

	assert_eq(PixelColours.average(_image(), points), -Vector3.ONE)


func test_average_covers_the_points_on_the_image() -> void:
	var points: PackedVector2Array = PackedVector2Array([Vector2(2.5, 2.5), Vector2(50, 50)])

	assert_eq(PixelColours.average(_image(), points), Vector3(100, 100, 100))
