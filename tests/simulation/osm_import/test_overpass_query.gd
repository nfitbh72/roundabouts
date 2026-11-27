extends GutTest


func _query() -> String:
	return OverpassQuery.roads_around(GeoPoint.new(-33.70849, 151.09851), 100.0)


func test_the_query_asks_for_json() -> void:
	assert_string_starts_with(_query(), "[out:json]")


func test_the_search_circle_reaches_the_corners_of_the_square() -> void:
	assert_string_contains(_query(), "way(around:142,-33.7084900,151.0985100)")


func test_the_query_asks_only_for_roads_for_cars() -> void:
	assert_string_contains(_query(), '[highway~"^(motorway|trunk|primary|')
	assert_false(_query().contains("footway"))


func test_the_query_includes_the_nodes_of_each_road() -> void:
	assert_string_ends_with(_query(), "(._;>;);out body;")
