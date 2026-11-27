extends GutTest


func _trial(name: String, lanes: int, edges: int) -> MapTrial:
	var trial: MapTrial = MapTrial.new()
	trial.name = name
	trial.size = Vector2i(800, 600)
	trial.lane_lines = lanes
	trial.road_edges = edges
	trial.picture = MapTrial.picture_name(name)
	return trial


func _unread(name: String) -> MapTrial:
	var trial: MapTrial = MapTrial.new()
	trial.name = name
	return trial


func test_an_unchanged_count_is_shown_alone() -> void:
	assert_eq(ContactSheet.count_cell(7, 7), "7")


func test_a_count_with_no_earlier_run_is_shown_alone() -> void:
	assert_eq(ContactSheet.count_cell(7, -1), "7")


func test_a_rise_is_marked_up() -> void:
	assert_eq(ContactSheet.count_cell(9, 7), '9 <span class="up">(+2)</span>')


func test_a_fall_is_marked_down() -> void:
	assert_eq(ContactSheet.count_cell(5, 7), '5 <span class="down">(-2)</span>')


func test_the_page_shows_each_trial_and_its_picture() -> void:
	var trials: Array[MapTrial] = [_trial("hornsby.webp", 17, 7), _unread("broken.png")]

	var page: String = ContactSheet.html(trials, {})

	assert_string_contains(page, "<h2>hornsby.webp</h2>")
	assert_string_contains(page, 'src="hornsby_webp.png"')
	assert_string_contains(page, "Could not read")
	assert_false(page.contains("broken_png.png"))


func test_the_page_compares_with_the_last_run() -> void:
	var previous: Dictionary = {"hornsby.webp": {"lane_lines": 15, "road_edges": 7}}

	var page: String = ContactSheet.html([_trial("hornsby.webp", 17, 7)], previous)

	assert_string_contains(page, '17 <span class="up">(+2)</span>')


func test_names_are_escaped_on_the_page() -> void:
	var page: String = ContactSheet.html([_trial("a<b>&c.png", 1, 1)], {})

	assert_string_contains(page, "a&lt;b&gt;&amp;c.png")
	assert_false(page.contains("<b>"))


func test_counts_of_leaves_out_trials_that_could_not_be_read() -> void:
	var trials: Array[MapTrial] = [_trial("hornsby.webp", 17, 7), _unread("broken.png")]

	assert_eq(ContactSheet.counts_of(trials), {"hornsby.webp": {"lane_lines": 17, "road_edges": 7}})
