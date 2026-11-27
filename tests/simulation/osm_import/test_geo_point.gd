extends GutTest


func test_a_real_place_is_valid() -> void:
	assert_true(GeoPoint.new(-33.70849, 151.09851).is_valid())


func test_the_poles_and_the_date_line_are_valid() -> void:
	assert_true(GeoPoint.new(90.0, -180.0).is_valid())


func test_a_latitude_beyond_the_pole_is_not_valid() -> void:
	assert_false(GeoPoint.new(90.5, 0.0).is_valid())


func test_a_longitude_beyond_the_date_line_is_not_valid() -> void:
	assert_false(GeoPoint.new(0.0, 181.0).is_valid())


func test_not_a_number_is_not_valid() -> void:
	assert_false(GeoPoint.new(NAN, 0.0).is_valid())
