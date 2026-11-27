extends GutTest

const WIDTH: float = 3.5


## A strip running east along y = 0 from [param from_x] to [param to_x], with
## its line down the middle.
func _east(from_x: float, to_x: float, lanes: int, nodes: Array[int]) -> RoadStrip:
	var line: PackedVector2Array = [
		Vector2(from_x, 0), Vector2((from_x + to_x) / 2.0, 0), Vector2(to_x, 0)
	]
	var strip: RoadStrip = RoadStrip.along(line, lanes, lanes / 2.0, WIDTH)
	strip.nodes = PackedInt64Array(nodes)
	return strip


func test_stretches_that_share_an_end_become_one() -> void:
	var strips: Array[RoadStrip] = [_east(0, 50, 2, [1, 9, 2]), _east(50, 100, 2, [2, 8, 3])]

	var chains: Array[RoadStrip] = RoadChains.chained(strips, WIDTH)

	assert_eq(chains.size(), 1)
	assert_eq(chains[0].left_edge[0], Vector2(0, -3.5))
	assert_eq(chains[0].left_edge[-1], Vector2(100, -3.5))
	assert_eq(chains[0].nodes, PackedInt64Array([1, 9, 2, 8, 3]))


func test_a_stretch_drawn_the_other_way_is_turned_round() -> void:
	var strips: Array[RoadStrip] = [_east(0, 50, 2, [1, 9, 2]), _east(50, 100, 2, [2, 8, 3])]
	strips[1] = strips[1].reversed()  # Now drawn westwards, from node 3 to node 2.

	var chains: Array[RoadStrip] = RoadChains.chained(strips, WIDTH)

	assert_eq(chains.size(), 1)
	assert_eq(chains[0].right_edge[-1], Vector2(100, 3.5))


func test_a_road_carrying_straight_on_past_a_branch_is_joined() -> void:
	var branch: RoadStrip = RoadStrip.along([Vector2(50, 0), Vector2(70, 20)], 1, 0.5, WIDTH)
	branch.nodes = PackedInt64Array([2, 4])
	var strips: Array[RoadStrip] = [_east(0, 50, 2, [1, 2]), _east(50, 100, 2, [2, 3]), branch]

	var chains: Array[RoadStrip] = RoadChains.chained(strips, WIDTH)

	assert_eq(chains.size(), 2)
	assert_eq(chains[0].nodes, PackedInt64Array([1, 2, 3]))


func test_roads_meeting_at_an_angle_are_a_junction_not_a_chain() -> void:
	var north: RoadStrip = RoadStrip.along([Vector2(50, 0), Vector2(50, -50)], 2, 1.0, WIDTH)
	north.nodes = PackedInt64Array([2, 4])
	var south: RoadStrip = RoadStrip.along([Vector2(50, 0), Vector2(50, 50)], 2, 1.0, WIDTH)
	south.nodes = PackedInt64Array([2, 5])
	var strips: Array[RoadStrip] = [_east(0, 50, 2, [1, 2]), north, south]

	var chains: Array[RoadStrip] = RoadChains.chained(strips, WIDTH)

	assert_eq(chains.size(), 2, "north and south carry straight on; east meets them")


func test_a_road_passing_through_the_joint_makes_it_a_junction() -> void:
	var strips: Array[RoadStrip] = [
		_east(0, 50, 2, [1, 2]), _east(50, 100, 2, [2, 3]), _east(0, 100, 2, [5, 2, 6])
	]

	assert_eq(RoadChains.chained(strips, WIDTH).size(), 3)


func test_an_added_lane_tapers_the_edges_and_starts_a_lane_line() -> void:
	# Two lanes, then four: the centre line carries on and two new lane lines begin.
	var strips: Array[RoadStrip] = [_east(0, 50, 2, [1, 2]), _east(50, 100, 4, [2, 3])]

	var chain: RoadStrip = RoadChains.chained(strips, WIDTH)[0]

	assert_eq(chain.left_edge[0], Vector2(0, -3.5))
	assert_eq(chain.left_edge[-1], Vector2(100, -7))
	assert_eq(chain.dividers.size(), 3)
	assert_eq(chain.dividers[0][0], Vector2(0, 0), "the centre line runs the whole way")
	assert_eq(chain.dividers[0][-1], Vector2(100, 0))
