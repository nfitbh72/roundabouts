extends GutTest

const SIZE: Vector2i = Vector2i(40, 30)


func _outline() -> MapOutline:
	var edges: Array[PackedVector2Array] = [PackedVector2Array([Vector2(0, 5), Vector2(40, 5)])]
	var lanes: Array[PackedVector2Array] = [PackedVector2Array([Vector2(0, 15), Vector2(40, 15)])]
	return MapOutline.new(SIZE, edges, lanes)


## Images store each channel in 8 bits, so colours match to within one step of that.
func _assert_colour(actual: Color, expected: Color) -> void:
	var step: float = 1.0 / 255.0
	assert_almost_eq(actual.r, expected.r, step)
	assert_almost_eq(actual.g, expected.g, step)
	assert_almost_eq(actual.b, expected.b, step)


func test_the_picture_has_two_halves_and_a_gap() -> void:
	var picture: Image = TrialPicture.paint(JunctionImage.grass(SIZE), _outline())

	assert_eq(picture.get_size(), Vector2i(SIZE.x * 2 + TrialPicture.GAP, SIZE.y))


func test_lines_are_drawn_on_both_halves() -> void:
	var picture: Image = TrialPicture.paint(JunctionImage.grass(SIZE), _outline())
	var right_half: int = SIZE.x + TrialPicture.GAP

	_assert_colour(picture.get_pixel(20, 5), MapOutlineView.ROAD_EDGE_COLOR)
	_assert_colour(picture.get_pixel(right_half + 20, 5), MapOutlineView.ROAD_EDGE_COLOR)
	_assert_colour(picture.get_pixel(20, 15), MapOutlineView.LANE_LINE_COLOR)
	_assert_colour(picture.get_pixel(right_half + 20, 15), MapOutlineView.LANE_LINE_COLOR)


func test_the_photo_is_toned_down() -> void:
	var picture: Image = TrialPicture.paint(JunctionImage.grass(SIZE), _outline())

	assert_lt(picture.get_pixel(20, 25).v, JunctionImage.GRASS.v)


func test_draw_line_skips_the_parts_off_the_picture() -> void:
	var picture: Image = Image.create_empty(10, 10, false, Image.FORMAT_RGBA8)
	var line: PackedVector2Array = PackedVector2Array([Vector2(-20, 5), Vector2(30, 5)])

	TrialPicture.draw_line(picture, line, Color.RED, 2)

	assert_eq(picture.get_pixel(0, 5), Color.RED)
	assert_eq(picture.get_pixel(9, 5), Color.RED)
	assert_eq(picture.get_pixel(5, 0), Color(0, 0, 0, 0))
