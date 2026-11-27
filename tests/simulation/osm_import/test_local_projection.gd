extends GutTest

const HORNSBY: Vector2 = Vector2(-33.70849, 151.09851)


func _hornsby() -> GeoPoint:
	return GeoPoint.new(HORNSBY.x, HORNSBY.y)


func test_the_centre_is_at_the_origin() -> void:
	assert_eq(LocalProjection.to_metres(_hornsby(), _hornsby()), Vector2.ZERO)


func test_north_is_up_the_screen() -> void:
	var north: GeoPoint = GeoPoint.new(0.001, 0.0)

	var metres: Vector2 = LocalProjection.to_metres(north, GeoPoint.new(0.0, 0.0))

	assert_almost_eq(metres.x, 0.0, 0.001)
	assert_almost_eq(metres.y, -111.19, 0.01)


func test_a_degree_east_shrinks_away_from_the_equator() -> void:
	var centre: GeoPoint = GeoPoint.new(60.0, 10.0)
	var east: GeoPoint = GeoPoint.new(60.0, 10.001)

	var metres: Vector2 = LocalProjection.to_metres(east, centre)

	assert_almost_eq(metres.x, 55.6, 0.01)
	assert_almost_eq(metres.y, 0.0, 0.001)


func test_small_steps_keep_their_precision_far_from_greenwich() -> void:
	var step: GeoPoint = GeoPoint.new(HORNSBY.x, 151.09852)

	var metres: Vector2 = LocalProjection.to_metres(step, GeoPoint.new(HORNSBY.x, 151.09851))

	assert_almost_eq(metres.x, 0.925, 0.001)


func test_line_to_metres_drops_repeated_points() -> void:
	var a: GeoPoint = GeoPoint.new(0.0, 0.0)
	var b: GeoPoint = GeoPoint.new(0.0, 0.001)
	var points: Array[GeoPoint] = [a, a, b]

	var line: PackedVector2Array = LocalProjection.line_to_metres(points, a)

	assert_eq(line.size(), 2)
