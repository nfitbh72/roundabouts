extends GutTest
## Tests for how welcome lines fade in and out.

const SECONDS_PER_LINE: float = 5.0


func test_line_starts_hidden() -> void:
	assert_eq(WelcomeSequence.opacity_at(0.0, SECONDS_PER_LINE, 1.0), 0.0)


func test_line_is_half_visible_halfway_through_fading_in() -> void:
	assert_almost_eq(WelcomeSequence.opacity_at(0.5, SECONDS_PER_LINE, 1.0), 0.5, 0.001)


func test_line_is_fully_visible_between_fades() -> void:
	assert_eq(WelcomeSequence.opacity_at(2.5, SECONDS_PER_LINE, 1.0), 1.0)


func test_line_is_half_visible_halfway_through_fading_out() -> void:
	assert_almost_eq(WelcomeSequence.opacity_at(4.5, SECONDS_PER_LINE, 1.0), 0.5, 0.001)


func test_next_line_fades_in_from_hidden() -> void:
	assert_eq(WelcomeSequence.opacity_at(5.0, SECONDS_PER_LINE, 1.0), 0.0)


func test_fade_repeats_for_later_lines() -> void:
	assert_almost_eq(WelcomeSequence.opacity_at(10.25, SECONDS_PER_LINE, 1.0), 0.25, 0.001)


func test_nothing_shows_before_the_start() -> void:
	assert_eq(WelcomeSequence.opacity_at(-1.0, SECONDS_PER_LINE, 1.0), 0.0)


func test_no_fade_time_means_always_fully_visible() -> void:
	assert_eq(WelcomeSequence.opacity_at(0.0, SECONDS_PER_LINE, 0.0), 1.0)
