extends GutTest

const RADIUS: float = 4.0


func test_edges_meeting_at_a_corner_become_one_rounded_kerb() -> void:
	var edges: Array[PackedVector2Array] = [
		PackedVector2Array([Vector2(0, 0), Vector2(20, 0)]),
		PackedVector2Array([Vector2(20, 20), Vector2(20, 0)]),
	]

	var kerbs: Array[PackedVector2Array] = KerbCorners.joined(edges, RADIUS)

	assert_eq(kerbs.size(), 1)
	assert_eq(kerbs[0][0], Vector2(0, 0))
	assert_eq(kerbs[0][-1], Vector2(20, 20))
	assert_gt(Polyline.distance_to(kerbs[0], Vector2(20, 0)), 1.0)


func test_edges_that_do_not_meet_are_left_alone() -> void:
	var edges: Array[PackedVector2Array] = [
		PackedVector2Array([Vector2(0, 0), Vector2(20, 0)]),
		PackedVector2Array([Vector2(20, 1), Vector2(20, 20)]),
	]

	assert_eq(KerbCorners.joined(edges, RADIUS), edges)


func test_edges_round_an_island_become_a_closed_kerb() -> void:
	var edges: Array[PackedVector2Array] = [
		PackedVector2Array([Vector2(0, 0), Vector2(20, 0)]),
		PackedVector2Array([Vector2(20, 0), Vector2(10, 15)]),
		PackedVector2Array([Vector2(0, 0), Vector2(10, 15)]),
	]

	var kerbs: Array[PackedVector2Array] = KerbCorners.joined(edges, RADIUS)

	assert_eq(kerbs.size(), 1)
	assert_eq(kerbs[0][0], kerbs[0][-1])
