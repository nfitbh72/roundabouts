extends GutTest


func test_median_of_an_odd_count_is_the_middle_value() -> void:
	assert_eq(Median.of([5.0, 1.0, 3.0]), 3.0)


func test_median_of_an_even_count_averages_the_middle_two() -> void:
	assert_eq(Median.of([4.0, 1.0, 3.0, 2.0]), 2.5)


func test_median_ignores_one_wild_value() -> void:
	assert_eq(Median.of([10.0, 11.0, 12.0, 500.0, 9.0]), 11.0)


func test_median_of_nothing_is_the_fallback() -> void:
	assert_eq(Median.of([], 24.0), 24.0)


func test_median_leaves_the_values_in_their_order() -> void:
	var values: Array[float] = [3.0, 1.0, 2.0]

	Median.of(values)

	assert_eq(values, [3.0, 1.0, 2.0])
