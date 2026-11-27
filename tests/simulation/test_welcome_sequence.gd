extends GutTest

const SECONDS_PER_LINE: float = 5.0


func test_parse_lines_splits_on_newlines() -> void:
	var lines: PackedStringArray = WelcomeSequence.parse_lines("one\ntwo\nthree")

	assert_eq(lines, PackedStringArray(["one", "two", "three"]))


func test_parse_lines_drops_blank_lines_and_whitespace() -> void:
	var lines: PackedStringArray = WelcomeSequence.parse_lines("  one  \r\n\n   \ntwo\n")

	assert_eq(lines, PackedStringArray(["one", "two"]))


func test_parse_lines_of_empty_text_is_empty() -> void:
	assert_eq(WelcomeSequence.parse_lines("").size(), 0)


func test_first_line_shows_at_the_start() -> void:
	assert_eq(WelcomeSequence.line_index_at(0.0, SECONDS_PER_LINE), 0)


func test_line_stays_until_its_time_is_up() -> void:
	assert_eq(WelcomeSequence.line_index_at(4.99, SECONDS_PER_LINE), 0)


func test_next_line_shows_when_time_is_up() -> void:
	assert_eq(WelcomeSequence.line_index_at(5.0, SECONDS_PER_LINE), 1)


func test_later_lines_follow_at_the_same_interval() -> void:
	assert_eq(WelcomeSequence.line_index_at(17.5, SECONDS_PER_LINE), 3)


func test_negative_time_shows_the_first_line() -> void:
	assert_eq(WelcomeSequence.line_index_at(-1.0, SECONDS_PER_LINE), 0)


func test_not_finished_during_the_last_line() -> void:
	assert_false(WelcomeSequence.is_finished(19.99, 4, SECONDS_PER_LINE))


func test_finished_after_the_last_line() -> void:
	assert_true(WelcomeSequence.is_finished(20.0, 4, SECONDS_PER_LINE))


func test_finished_immediately_with_no_lines() -> void:
	assert_true(WelcomeSequence.is_finished(0.0, 0, SECONDS_PER_LINE))


func test_start_of_next_line_from_mid_line() -> void:
	assert_eq(WelcomeSequence.start_of_next_line(7.2, SECONDS_PER_LINE), 10.0)


func test_start_of_next_line_from_a_line_boundary() -> void:
	assert_eq(WelcomeSequence.start_of_next_line(10.0, SECONDS_PER_LINE), 15.0)
