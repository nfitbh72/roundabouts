extends GutTest

const SIZE: Vector2i = Vector2i(240, 140)
const ROAD_TOP: int = 40
const LANE_WIDTH: int = 20
const LANE_COUNT: int = 3


func _road_outline() -> MapOutline:
	return MapConverter.from_image(
		JunctionImage.horizontal_road(SIZE, ROAD_TOP, LANE_WIDTH, LANE_COUNT)
	)


func test_each_dashed_line_becomes_one_lane_line() -> void:
	var outline: MapOutline = _road_outline()

	assert_eq(outline.lane_lines.size(), LANE_COUNT - 1)
	for line: PackedVector2Array in outline.lane_lines:
		assert_gt(Polyline.length(line), SIZE.x * 0.8)


func test_the_road_has_an_edge_along_each_side() -> void:
	var outline: MapOutline = _road_outline()

	assert_eq(outline.road_edges.size(), 2)
	var heights: Array[float] = []
	for edge: PackedVector2Array in outline.road_edges:
		heights.append(Polyline.centre(edge).y)
	heights.sort()
	assert_almost_eq(heights[0], float(ROAD_TOP), 1.5)
	assert_almost_eq(heights[1], float(ROAD_TOP + LANE_WIDTH * LANE_COUNT), 1.5)


func test_a_field_has_no_roads() -> void:
	var outline: MapOutline = MapConverter.from_image(JunctionImage.grass(SIZE))

	assert_eq(outline.road_edges.size(), 0)
	assert_eq(outline.lane_lines.size(), 0)


func test_tarmac_without_lane_lines_is_not_a_road() -> void:
	var image: Image = JunctionImage.grass(SIZE)
	image.fill_rect(Rect2i(0, ROAD_TOP, SIZE.x, 60), JunctionImage.TARMAC)

	assert_eq(MapConverter.from_image(image).road_edges.size(), 0)


func test_the_outline_is_the_size_of_the_image() -> void:
	assert_eq(_road_outline().size, SIZE)


func test_the_same_image_always_gives_the_same_lines() -> void:
	var first: MapOutline = _road_outline()
	var second: MapOutline = _road_outline()

	assert_eq(first.road_edges, second.road_edges)
	assert_eq(first.lane_lines, second.lane_lines)


func test_large_images_are_scaled_down() -> void:
	var image: Image = JunctionImage.grass(Vector2i(MapConverter.MAX_SIDE * 2, 100))

	var copy: Image = MapConverter.working_copy(image)

	assert_eq(copy.get_size(), Vector2i(MapConverter.MAX_SIDE, 50))


func test_the_original_image_is_left_untouched() -> void:
	var image: Image = JunctionImage.grass(Vector2i(MapConverter.MAX_SIDE * 2, 100))

	MapConverter.working_copy(image)

	assert_eq(image.get_width(), MapConverter.MAX_SIDE * 2)
