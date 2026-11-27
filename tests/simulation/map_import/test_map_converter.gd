extends GutTest

const SIZE: Vector2i = Vector2i(200, 120)
const ROAD_TOP: int = 40
const ROAD_BOTTOM: int = 80


func _road_outline() -> MapOutline:
	return MapConverter.from_image(JunctionImage.horizontal_road(SIZE, ROAD_TOP, ROAD_BOTTOM))


func test_a_straight_road_has_an_edge_on_each_side() -> void:
	var outline: MapOutline = _road_outline()

	assert_eq(outline.road_edges.size(), 2)
	var top_edge: PackedVector2Array = outline.road_edges[0]
	var bottom_edge: PackedVector2Array = outline.road_edges[1]
	if top_edge[0].y > bottom_edge[0].y:
		top_edge = outline.road_edges[1]
		bottom_edge = outline.road_edges[0]
	_assert_runs_along(top_edge, ROAD_TOP)
	_assert_runs_along(bottom_edge, ROAD_BOTTOM)


func test_the_dashed_centre_line_becomes_lane_lines() -> void:
	var outline: MapOutline = _road_outline()

	assert_gt(outline.lane_lines.size(), 5)
	for line: PackedVector2Array in outline.lane_lines:
		assert_almost_eq(line[0].y, (ROAD_TOP + ROAD_BOTTOM) / 2.0, 1.0)


func test_a_field_has_no_roads() -> void:
	var outline: MapOutline = MapConverter.from_image(JunctionImage.grass(SIZE))

	assert_eq(outline.road_edges.size(), 0)
	assert_eq(outline.lane_lines.size(), 0)


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


func _assert_runs_along(line: PackedVector2Array, y: int) -> void:
	for point: Vector2 in line:
		assert_almost_eq(point.y, float(y), 1.0)
