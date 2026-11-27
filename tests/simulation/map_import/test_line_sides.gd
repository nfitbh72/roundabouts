extends GutTest

const LINE: PackedVector2Array = [Vector2(10, 20), Vector2(50, 20)]


func _image(above: Color, below: Color) -> Image:
	var image: Image = Image.create_empty(60, 40, false, Image.FORMAT_RGBA8)
	image.fill_rect(Rect2i(0, 0, 60, 20), above)
	image.fill_rect(Rect2i(0, 20, 60, 20), below)
	return image


func test_a_line_with_tarmac_both_sides_has_alike_sides() -> void:
	var image: Image = _image(JunctionImage.TARMAC, JunctionImage.TARMAC)

	assert_true(LineSides.are_alike(LINE, image))
	assert_eq(LineSides.difference(LINE, image), 0.0)


func test_a_kerb_between_tarmac_and_pavement_does_not() -> void:
	assert_false(LineSides.are_alike(LINE, _image(JunctionImage.TARMAC, Color8(150, 140, 135))))


func test_average_beside_looks_on_the_side_asked_about() -> void:
	var image: Image = _image(Color8(10, 20, 30), Color8(200, 200, 200))

	assert_eq(LineSides.average_beside(LINE, image, 1.0), Vector3(10, 20, 30))
	assert_eq(LineSides.average_beside(LINE, image, -1.0), Vector3(200, 200, 200))
