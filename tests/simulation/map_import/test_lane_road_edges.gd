extends GutTest

const WIDTH: float = 20.0
const ROAD_TOP: int = 40
const ROAD_BOTTOM: int = 100
const SIZE: Vector2i = Vector2i(200, 140)
## Grey enough to pass for tarmac on its own, but not the same grey as the road.
const PAVEMENT: Color = Color8(150, 140, 135)


## Grass with a road of tarmac from [constant ROAD_TOP] to [constant ROAD_BOTTOM].
func _road() -> Image:
	var image: Image = JunctionImage.grass(SIZE)
	image.fill_rect(Rect2i(0, ROAD_TOP, SIZE.x, ROAD_BOTTOM - ROAD_TOP), JunctionImage.TARMAC)
	return image


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


func test_tarmac_beside_is_the_colour_next_to_the_line() -> void:
	var colour: Vector3 = LaneRoadEdges.tarmac_beside(Vector2(50, 60), Vector2.UP, _road())

	assert_eq(colour, Vector3(90, 90, 95))


func test_distance_to_edge_finds_where_the_tarmac_ends() -> void:
	var distance: float = LaneRoadEdges.distance_to_edge(
		Vector2(50, 60), Vector2.UP, WIDTH, _road()
	)

	assert_almost_eq(distance, 20.0, 0.5)


func test_a_grey_pavement_still_counts_as_the_edge() -> void:
	var image: Image = _road()
	image.fill_rect(Rect2i(0, ROAD_BOTTOM, SIZE.x, 20), PAVEMENT)

	var distance: float = LaneRoadEdges.distance_to_edge(
		Vector2(50, 80), Vector2.DOWN, WIDTH, image
	)

	assert_almost_eq(distance, 20.0, 0.5)


func test_an_edge_too_close_to_the_lane_line_is_ignored() -> void:
	var distance: float = LaneRoadEdges.distance_to_edge(
		Vector2(50, 46), Vector2.UP, WIDTH, _road()
	)

	assert_eq(distance, -1.0)


func test_an_edge_too_far_from_the_lane_line_is_ignored() -> void:
	var distance: float = LaneRoadEdges.distance_to_edge(
		Vector2(50, 95), Vector2.UP, WIDTH, _road()
	)

	assert_eq(distance, -1.0)


func test_edges_sit_where_the_tarmac_ends_beside_the_outer_lines() -> void:
	var lines: Array[PackedVector2Array] = [_across(60), _across(80)]

	_assert_heights(
		LaneRoadEdges.edges_of(lines, WIDTH, _road()), [float(ROAD_TOP), float(ROAD_BOTTOM)]
	)


func test_lines_running_opposite_ways_still_give_one_edge_each_side() -> void:
	var lines: Array[PackedVector2Array] = [_across(60), Polyline.reversed(_across(80))]

	_assert_heights(
		LaneRoadEdges.edges_of(lines, WIDTH, _road()), [float(ROAD_TOP), float(ROAD_BOTTOM)]
	)


func test_no_edge_is_drawn_where_the_tarmac_carries_on() -> void:
	var image: Image = _road()
	image.fill_rect(Rect2i(0, 0, SIZE.x, ROAD_TOP), JunctionImage.TARMAC)

	_assert_heights(LaneRoadEdges.edges_of([_across(80)], WIDTH, image), [float(ROAD_BOTTOM)])


func test_an_inner_line_gives_the_edge_when_the_outer_one_cannot() -> void:
	var image: Image = _road()
	# A thin red line just beside the outer lane line spoils its view of the tarmac.
	image.fill_rect(Rect2i(0, 82, SIZE.x, 2), Color8(200, 30, 30))

	var edges: Array[PackedVector2Array] = LaneRoadEdges.edges_of(
		[_across(60), _across(80)], WIDTH, image
	)

	_assert_heights(edges, [float(ROAD_TOP), float(ROAD_BOTTOM)])


func test_an_edge_that_would_sit_inside_the_outermost_line_is_not_used() -> void:
	# The outer line runs along the kerb, as rows of kerb specks sometimes do.
	var lines: Array[PackedVector2Array] = [_across(60), _across(96)]

	_assert_heights(LaneRoadEdges.edges_of(lines, WIDTH, _road()), [float(ROAD_TOP)])
