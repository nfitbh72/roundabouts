extends GutTest

const ACROSS: PackedVector2Array = [Vector2(-10, 5), Vector2(20, 5)]
const SQUARE: PackedVector2Array = [Vector2(0, 0), Vector2(10, 0), Vector2(10, 10), Vector2(0, 10)]


func _xs(lines: Array[PackedVector2Array]) -> Array[Vector2]:
	var spans: Array[Vector2] = []
	for line: PackedVector2Array in lines:
		var ends: Vector2 = Vector2(line[0].x, line[-1].x)
		spans.append(Vector2(minf(ends.x, ends.y), maxf(ends.x, ends.y)).round())
	spans.sort()
	return spans


func test_inside_keeps_the_part_within_the_polygon() -> void:
	assert_eq(_xs(LineClip.inside([ACROSS], SQUARE)), [Vector2(0, 10)])


func test_outside_keeps_the_parts_beyond_the_polygon() -> void:
	assert_eq(_xs(LineClip.outside([ACROSS], SQUARE)), [Vector2(-10, 0), Vector2(10, 20)])


func test_at_least_drops_short_lines() -> void:
	var short: PackedVector2Array = [Vector2(0, 0), Vector2(0.5, 0)]

	assert_eq(LineClip.at_least([short, ACROSS], 1.0).size(), 1)


func test_box_has_a_corner_at_the_origin() -> void:
	assert_eq(LineClip.box(Vector2(4, 3))[2], Vector2(4, 3))
