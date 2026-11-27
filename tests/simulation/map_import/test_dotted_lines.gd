extends GutTest

const SIZE: Vector2i = Vector2i(200, 120)


## Points along y = [param y] from x = [param from], [param count] of them, [param spacing] apart.
func _row(y: float, from: float, count: int, spacing: float) -> PackedVector2Array:
	var points: PackedVector2Array = PackedVector2Array()
	for index: int in count:
		points.append(Vector2(from + index * spacing, y))
	return points


func test_an_even_row_of_points_becomes_a_line() -> void:
	var lines: Array[PackedVector2Array] = DottedLines.find(_row(60.5, 20.0, 12, 10.0), SIZE)

	assert_eq(lines.size(), 1)
	assert_almost_eq(Polyline.length(lines[0]), 110.0, 0.01)
	assert_almost_eq(lines[0][0].y, 60.5, 0.01)


func test_a_slanted_row_is_found_too() -> void:
	var points: PackedVector2Array = PackedVector2Array()
	for index: int in 10:
		points.append(Vector2(20.0 + index * 9.0, 20.0 + index * 6.0))

	var lines: Array[PackedVector2Array] = DottedLines.find(points, SIZE)

	assert_eq(lines.size(), 1)
	assert_almost_eq(absf(Polyline.direction(lines[0]).dot(Vector2(9, 6).normalized())), 1.0, 0.001)


func test_two_rows_become_two_lines() -> void:
	var points: PackedVector2Array = _row(30.5, 20.0, 10, 10.0)
	points.append_array(_row(70.5, 20.0, 10, 10.0))

	assert_eq(DottedLines.find(points, SIZE).size(), 2)


func test_a_row_with_a_big_gap_splits_in_two() -> void:
	var points: PackedVector2Array = _row(60.5, 0.0, 6, 10.0)
	points.append_array(_row(60.5, 120.0, 6, 10.0))

	assert_eq(DottedLines.find(points, SIZE).size(), 2)


func test_too_few_points_are_not_a_line() -> void:
	assert_eq(DottedLines.find(_row(60.5, 20.0, DottedLines.MIN_POINTS - 1, 10.0), SIZE).size(), 0)


func test_scattered_points_are_not_a_line() -> void:
	var points: PackedVector2Array = PackedVector2Array(
		[Vector2(10, 90), Vector2(40, 15), Vector2(75, 60), Vector2(120, 30), Vector2(160, 100)]
	)

	assert_eq(DottedLines.find(points, SIZE).size(), 0)


func test_new_lines_drops_lines_already_found() -> void:
	var found: Array[PackedVector2Array] = [
		PackedVector2Array([Vector2(0, 50), Vector2(100, 50)]),
		PackedVector2Array([Vector2(0, 80), Vector2(100, 80)]),
	]
	var existing: Array[PackedVector2Array] = [
		PackedVector2Array([Vector2(0, 52), Vector2(100, 52)])
	]

	var fresh: Array[PackedVector2Array] = DottedLines.new_lines(found, existing, 4.0)

	assert_eq(fresh.size(), 1)
	assert_eq(fresh[0][0].y, 80.0)
