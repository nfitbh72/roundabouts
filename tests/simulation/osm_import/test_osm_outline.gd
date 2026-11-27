extends GutTest

## Half the width of the square drawn, in metres.
const RADIUS: float = 50.0


func _outline() -> MapOutline:
	return OsmOutline.build(Crossroads.extract(), Crossroads.centre(), RADIUS)


func _all_points(lines: Array[PackedVector2Array]) -> PackedVector2Array:
	var points: PackedVector2Array = PackedVector2Array()
	for line: PackedVector2Array in lines:
		points.append_array(line)
	return points


func test_the_outline_covers_the_square_in_metres() -> void:
	assert_eq(_outline().size, Vector2i(100, 100))


func test_only_roads_for_cars_become_strips() -> void:
	var strips: Array[RoadStrip] = OsmOutline.strips_of(
		Crossroads.extract().roads, Crossroads.centre(), Vector2.ZERO
	)

	assert_eq(strips.size(), 2)


func test_each_edge_stops_where_it_meets_the_other_road() -> void:
	# Two edges per road, each cut in two by the road crossing it.
	assert_eq(_outline().road_edges.size(), 8)


func test_lane_lines_stop_at_the_junction_too() -> void:
	# Three dividers on the main road and one on the side street, each cut in two.
	assert_eq(_outline().lane_lines.size(), 8)


func test_the_main_road_is_four_lanes_wide() -> void:
	var heights: Array[float] = []
	for edge: PackedVector2Array in _outline().road_edges:
		if absf(edge[0].y - edge[-1].y) < 0.01:
			heights.append(snappedf(edge[0].y, 0.01))
	heights.sort()

	assert_eq(heights, [43.0, 43.0, 57.0, 57.0])


func test_the_junction_is_clear_of_lines() -> void:
	var middle: Rect2 = Rect2(Vector2(47, 44), Vector2(6, 12))
	var outline: MapOutline = _outline()
	for point: Vector2 in _all_points(outline.road_edges + outline.lane_lines):
		assert_false(middle.has_point(point), "%s is inside the junction" % point)


func test_every_line_stays_inside_the_square() -> void:
	var square: Rect2 = Rect2(Vector2.ZERO, Vector2(100, 100)).grow(0.01)
	var outline: MapOutline = _outline()
	for point: Vector2 in _all_points(outline.road_edges + outline.lane_lines):
		assert_true(square.has_point(point), "%s is outside the square" % point)
