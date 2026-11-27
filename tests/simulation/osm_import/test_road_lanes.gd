extends GutTest


func _lanes(tags: Dictionary[String, String]) -> RoadLanes:
	return RoadLanes.from_tags(tags)


func test_an_untagged_residential_street_has_a_lane_each_way() -> void:
	var lanes: RoadLanes = _lanes({"highway": "residential"})

	assert_eq([lanes.forward, lanes.backward, lanes.total], [1, 1, 2])
	assert_eq(lanes.oneway, RoadLanes.BOTH_WAYS)


func test_lanes_each_way_are_read_from_their_tags() -> void:
	var lanes: RoadLanes = _lanes(
		{"highway": "primary", "lanes": "5", "lanes:forward": "2", "lanes:backward": "3"}
	)

	assert_eq([lanes.forward, lanes.backward, lanes.total], [2, 3, 5])


func test_a_missing_direction_is_the_rest_of_the_lanes() -> void:
	var lanes: RoadLanes = _lanes({"highway": "primary", "lanes": "4", "lanes:backward": "3"})

	assert_eq([lanes.forward, lanes.backward], [1, 3])


func test_lanes_without_directions_are_split_evenly() -> void:
	var lanes: RoadLanes = _lanes({"highway": "primary", "lanes": "4"})

	assert_eq([lanes.forward, lanes.backward], [2, 2])


func test_directions_without_a_total_add_up() -> void:
	var lanes: RoadLanes = _lanes(
		{"highway": "primary", "lanes:forward": "2", "lanes:backward": "1"}
	)

	assert_eq(lanes.total, 3)


func test_a_centre_turning_lane_counts_towards_the_total() -> void:
	var lanes: RoadLanes = _lanes({"highway": "primary", "lanes": "3", "lanes:both_ways": "1"})

	assert_eq([lanes.forward, lanes.backward, lanes.total], [1, 1, 3])


func test_a_one_way_road_has_every_lane_forward() -> void:
	var lanes: RoadLanes = _lanes({"highway": "primary", "oneway": "yes", "lanes": "3"})

	assert_eq([lanes.forward, lanes.backward, lanes.total], [3, 0, 3])
	assert_eq(lanes.oneway, RoadLanes.FORWARD_ONLY)


func test_a_reversed_one_way_road_has_every_lane_backward() -> void:
	var lanes: RoadLanes = _lanes({"highway": "primary", "oneway": "-1", "lanes": "2"})

	assert_eq([lanes.forward, lanes.backward], [0, 2])
	assert_eq(lanes.oneway, RoadLanes.BACKWARD_ONLY)


func test_an_untagged_motorway_is_one_way_with_two_lanes() -> void:
	var lanes: RoadLanes = _lanes({"highway": "motorway"})

	assert_eq(lanes.oneway, RoadLanes.FORWARD_ONLY)
	assert_eq(lanes.total, 2)


func test_turn_lanes_give_the_count_when_lanes_are_missing() -> void:
	var lanes: RoadLanes = _lanes(
		{"highway": "primary", "oneway": "yes", "turn:lanes": "left|left|through|right"}
	)

	assert_eq(lanes.total, 4)


func test_turn_lanes_are_read_lane_by_lane() -> void:
	var lanes: RoadLanes = _lanes(
		{"highway": "primary", "lanes": "4", "turn:lanes:backward": "left;through||right"}
	)

	assert_eq(lanes.turns_backward, PackedStringArray(["left;through", "none", "right"]))
	assert_eq(lanes.turns_forward, PackedStringArray())


func test_a_lane_count_that_is_not_a_number_is_ignored() -> void:
	var lanes: RoadLanes = _lanes({"highway": "tertiary", "lanes": "2;3"})

	assert_eq(lanes.total, 2)


func test_an_untagged_way_runs_down_the_middle() -> void:
	assert_eq(_lanes({"highway": "primary", "lanes": "4"}).way_position, 2.0)


func test_placement_moves_the_way_across_the_road() -> void:
	var tags: Dictionary[String, String] = {"highway": "primary", "oneway": "yes", "lanes": "3"}
	var positions: Array[float] = []
	for placement: String in ["left_of:1", "right_of:1", "middle_of:2", "transition"]:
		tags["placement"] = placement
		positions.append(_lanes(tags).way_position)

	assert_eq(positions, [0.0, 1.0, 1.5, 1.5])


func test_placement_backward_counts_from_the_other_side() -> void:
	# As on the B83 at Hornsby: three lanes towards the junction, one away, and
	# the way drawn along the line between them.
	var tags: Dictionary[String, String] = {
		"highway": "primary",
		"lanes": "4",
		"lanes:forward": "1",
		"lanes:backward": "3",
		"placement:backward": "right_of:3",
	}

	assert_eq(_lanes(tags).way_position, 1.0)


func test_placement_forward_counts_like_placement() -> void:
	var tags: Dictionary[String, String] = {
		"highway": "primary", "lanes": "4", "placement:forward": "left_of:1"
	}

	assert_eq(_lanes(tags).way_position, 0.0)
