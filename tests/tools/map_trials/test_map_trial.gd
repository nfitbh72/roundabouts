extends GutTest


func test_picture_names_keep_the_original_extension() -> void:
	assert_eq(MapTrial.picture_name("junction.jpg"), "junction_jpg.png")
	assert_ne(MapTrial.picture_name("junction.jpg"), MapTrial.picture_name("junction.png"))


func test_a_new_trial_has_not_been_read() -> void:
	assert_false(MapTrial.new().was_read())


func test_counts_holds_the_lane_lines_and_road_edges() -> void:
	var trial: MapTrial = MapTrial.new()
	trial.lane_lines = 3
	trial.road_edges = 4

	assert_eq(trial.counts(), {"lane_lines": 3, "road_edges": 4})
