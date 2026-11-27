extends GutTest

const SIZE: Vector2 = Vector2(100, 60)


func _mask_with(rects: Array[Rect2i]) -> BitMap:
	var mask: BitMap = BitMap.new()
	mask.create(Vector2i(SIZE))
	for rect: Rect2i in rects:
		mask.set_bit_rect(rect, true)
	return mask


func _whole() -> Rect2i:
	return Rect2i(Vector2i.ZERO, Vector2i(SIZE))


func test_a_ring_away_from_the_border_stays_whole_and_closed() -> void:
	var ring: PackedVector2Array = PackedVector2Array(
		[Vector2(10, 10), Vector2(20, 10), Vector2(20, 20), Vector2(10, 20)]
	)

	var lines: Array[PackedVector2Array] = RoadEdges.split_at_border(ring, SIZE)

	assert_eq(lines.size(), 1)
	assert_eq(lines[0].size(), 5)
	assert_eq(lines[0][0], lines[0][4])


func test_a_road_crossing_the_picture_keeps_only_its_two_sides() -> void:
	var ring: PackedVector2Array = PackedVector2Array(
		[Vector2(0, 40), Vector2(100, 40), Vector2(100, 20), Vector2(0, 20)]
	)

	var lines: Array[PackedVector2Array] = RoadEdges.split_at_border(ring, SIZE)

	assert_eq(lines.size(), 2)
	assert_has(lines, PackedVector2Array([Vector2(0, 40), Vector2(100, 40)]))
	assert_has(lines, PackedVector2Array([Vector2(100, 20), Vector2(0, 20)]))


func test_a_road_turning_a_corner_of_the_picture_is_one_line() -> void:
	var ring: PackedVector2Array = PackedVector2Array(
		[Vector2(0, 0), Vector2(30, 0), Vector2(30, 30), Vector2(0, 30)]
	)

	var lines: Array[PackedVector2Array] = RoadEdges.split_at_border(ring, SIZE)

	assert_eq(lines.size(), 1)
	assert_eq(lines[0], PackedVector2Array([Vector2(30, 0), Vector2(30, 30), Vector2(0, 30)]))


func test_area_of_a_square() -> void:
	var square: PackedVector2Array = PackedVector2Array(
		[Vector2(0, 0), Vector2(10, 0), Vector2(10, 10), Vector2(0, 10)]
	)

	assert_eq(absf(RoadEdges.area_of(square)), 100.0)


func test_trace_finds_both_sides_of_a_straight_road() -> void:
	var road: BitMap = _mask_with([Rect2i(0, 20, 100, 20)])

	var edges: Array[PackedVector2Array] = RoadEdges.trace(road, _whole())

	assert_eq(edges.size(), 2)
	for edge: PackedVector2Array in edges:
		assert_true(edge[0].y == edge[-1].y, "Each side should run straight across.")


func test_trace_finds_a_traffic_island_inside_the_road() -> void:
	var road: BitMap = _mask_with([Rect2i(0, 10, 100, 40)])
	road.set_bit_rect(Rect2i(40, 25, 20, 10), false)

	var edges: Array[PackedVector2Array] = RoadEdges.trace(road, _whole())

	assert_eq(edges.size(), 3)


func test_trace_ignores_tiny_blobs() -> void:
	var road: BitMap = _mask_with([Rect2i(40, 25, 5, 5)])

	assert_eq(RoadEdges.trace(road, _whole()).size(), 0)


func test_trace_returns_points_in_the_mask_coordinates() -> void:
	var road: BitMap = _mask_with([Rect2i(0, 20, 100, 20)])
	var area: Rect2i = Rect2i(5, 5, 90, 50)

	var edges: Array[PackedVector2Array] = RoadEdges.trace(road, area)

	assert_eq(edges.size(), 2)
	for edge: PackedVector2Array in edges:
		for point: Vector2 in edge:
			assert_true(area.has_point(Vector2i(point)) or point.x == area.end.x)
