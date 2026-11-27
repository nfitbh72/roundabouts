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


func test_each_corner_of_the_junction_is_one_kerb() -> void:
	assert_eq(_outline().road_edges.size(), 4)


func test_lane_lines_stop_at_the_junction() -> void:
	# Three dividers on the main road and one on the side street, each cut in two.
	assert_eq(_outline().lane_lines.size(), 8)


func test_kerbs_run_along_both_sides_of_both_roads() -> void:
	# The main road is four lanes wide and the side street two.
	var kerbs: Array[PackedVector2Array] = _outline().road_edges
	for point: Vector2 in [
		Vector2(20, 43),
		Vector2(80, 43),
		Vector2(20, 57),
		Vector2(80, 57),
		Vector2(46.5, 20),
		Vector2(53.5, 20),
		Vector2(46.5, 80),
		Vector2(53.5, 80),
	]:
		assert_almost_eq(_distance_to_nearest(kerbs, point), 0.0, 0.01, "kerb at %s" % point)


func test_the_corners_are_rounded_off() -> void:
	var kerbs: Array[PackedVector2Array] = _outline().road_edges
	for corner: Vector2 in [
		Vector2(46.5, 43), Vector2(53.5, 43), Vector2(46.5, 57), Vector2(53.5, 57)
	]:
		assert_gt(_distance_to_nearest(kerbs, corner), 1.0, "%s is rounded off" % corner)


func test_a_road_split_where_it_widens_is_drawn_as_one() -> void:
	var text: String = (
		'{"elements": ['
		+ '{"type": "node", "id": 1, "lat": 0, "lon": -0.0009},'
		+ '{"type": "node", "id": 2, "lat": 0, "lon": 0},'
		+ '{"type": "node", "id": 3, "lat": 0, "lon": 0.0009},'
		+ '{"type": "way", "id": 7, "nodes": [1, 2], "tags": {"highway": "primary"}},'
		+ '{"type": "way", "id": 8, "nodes": [2, 3], "tags": {"highway": "primary", "lanes": "4"}}'
		+ "]}"
	)

	var outline: MapOutline = OsmOutline.build(
		OverpassParser.parse(text), Crossroads.centre(), RADIUS
	)

	assert_eq(outline.road_edges.size(), 2, "one edge each side, tapering")
	assert_eq(outline.lane_lines.size(), 3, "the centre line, and one for each new lane")


func _distance_to_nearest(lines: Array[PackedVector2Array], point: Vector2) -> float:
	var nearest: float = INF
	for line: PackedVector2Array in lines:
		nearest = minf(nearest, Polyline.distance_to(line, point))
	return nearest


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
