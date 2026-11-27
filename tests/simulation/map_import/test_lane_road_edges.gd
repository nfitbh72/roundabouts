extends GutTest

const WIDTH: float = 20.0
const ROAD_TOP: int = 40
const ROAD_BOTTOM: int = 100


## A road mask with tarmac from [constant ROAD_TOP] to [constant ROAD_BOTTOM].
func _road() -> BitMap:
	var road: BitMap = BitMap.new()
	road.create(Vector2i(200, 140))
	road.set_bit_rect(Rect2i(0, ROAD_TOP, 200, ROAD_BOTTOM - ROAD_TOP), true)
	return road


func _across(y: float) -> PackedVector2Array:
	return PackedVector2Array([Vector2(20, y), Vector2(100, y), Vector2(180, y)])


## Checks the edges run along the given heights, give or take half a pixel.
func _assert_heights(edges: Array[PackedVector2Array], expected: Array[float]) -> void:
	var heights: Array[float] = []
	for edge: PackedVector2Array in edges:
		heights.append(Polyline.centre(edge).y)
	heights.sort()
	assert_eq(heights.size(), expected.size())
	for index: int in mini(heights.size(), expected.size()):
		assert_almost_eq(heights[index], expected[index], 0.5)


func test_distance_to_edge_finds_where_the_tarmac_ends() -> void:
	var distance: float = LaneRoadEdges.distance_to_edge(
		Vector2(50, 60), Vector2.UP, WIDTH, _road()
	)

	assert_almost_eq(distance, 20.0, 0.5)


func test_an_edge_too_close_to_the_lane_line_is_ignored() -> void:
	var distance: float = LaneRoadEdges.distance_to_edge(
		Vector2(50, 43), Vector2.UP, WIDTH, _road()
	)

	assert_eq(distance, -1.0)


func test_an_edge_too_far_from_the_lane_line_is_ignored() -> void:
	var distance: float = LaneRoadEdges.distance_to_edge(
		Vector2(50, 95), Vector2.UP, WIDTH, _road()
	)

	assert_eq(distance, -1.0)


func test_edges_sit_where_the_tarmac_ends_beside_the_outer_lines() -> void:
	var lines: Array[PackedVector2Array] = [_across(60), _across(80)]

	var edges: Array[PackedVector2Array] = LaneRoadEdges.edges_of(lines, WIDTH, _road())

	assert_eq(edges.size(), 2)
	_assert_heights(edges, [float(ROAD_TOP), float(ROAD_BOTTOM)])


func test_no_edge_is_drawn_where_the_tarmac_carries_on() -> void:
	var road: BitMap = _road()
	road.set_bit_rect(Rect2i(0, 0, 200, ROAD_TOP), true)

	var edges: Array[PackedVector2Array] = LaneRoadEdges.edges_of([_across(80)], WIDTH, road)

	_assert_heights(edges, [float(ROAD_BOTTOM)])


func test_lines_running_opposite_ways_still_give_one_edge_each_side() -> void:
	var lines: Array[PackedVector2Array] = [_across(60), Polyline.reversed(_across(80))]

	var edges: Array[PackedVector2Array] = LaneRoadEdges.edges_of(lines, WIDTH, _road())

	_assert_heights(edges, [float(ROAD_TOP), float(ROAD_BOTTOM)])
