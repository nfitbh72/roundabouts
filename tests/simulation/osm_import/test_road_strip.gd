extends GutTest

const WIDTH: float = 3.5
const EAST: PackedVector2Array = [Vector2(0, 0), Vector2(50, 0), Vector2(100, 0)]


func _height(line: PackedVector2Array) -> float:
	return Polyline.centre(line).y


func test_edges_sit_half_the_road_either_side_of_a_centred_way() -> void:
	var strip: RoadStrip = RoadStrip.along(EAST, 4, 2.0, WIDTH)

	assert_almost_eq(_height(strip.left_edge), -7.0, 0.001)
	assert_almost_eq(_height(strip.right_edge), 7.0, 0.001)


func test_dividers_run_between_the_lanes_from_left_to_right() -> void:
	var strip: RoadStrip = RoadStrip.along(EAST, 4, 2.0, WIDTH)
	var heights: Array[float] = []
	for divider: PackedVector2Array in strip.dividers:
		heights.append(snappedf(_height(divider), 0.001))

	assert_eq(heights, [-3.5, 0.0, 3.5])


func test_a_single_lane_has_no_dividers() -> void:
	assert_eq(RoadStrip.along(EAST, 1, 0.5, WIDTH).dividers.size(), 0)


func test_a_way_along_the_left_edge_puts_the_road_to_its_right() -> void:
	var strip: RoadStrip = RoadStrip.along(EAST, 2, 0.0, WIDTH)

	assert_almost_eq(_height(strip.left_edge), 0.0, 0.001)
	assert_almost_eq(_height(strip.right_edge), 7.0, 0.001)


func test_the_area_runs_round_the_road() -> void:
	var area: PackedVector2Array = RoadStrip.along(EAST, 2, 1.0, WIDTH).area()

	assert_true(Geometry2D.is_point_in_polygon(Vector2(50, 3), area))
	assert_false(Geometry2D.is_point_in_polygon(Vector2(50, 4), area))
