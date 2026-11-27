extends GutTest


func test_a_primary_road_is_drivable() -> void:
	assert_true(RoadTypes.is_drivable({"highway": "primary"}))


func test_a_footpath_is_not_drivable() -> void:
	assert_false(RoadTypes.is_drivable({"highway": "footway"}))


func test_a_car_park_aisle_is_not_worth_drawing() -> void:
	assert_false(RoadTypes.is_drivable({"highway": "service", "service": "parking_aisle"}))


func test_a_plain_service_road_is_drivable() -> void:
	assert_true(RoadTypes.is_drivable({"highway": "service"}))


func test_a_pedestrian_area_is_not_drivable() -> void:
	assert_false(RoadTypes.is_drivable({"highway": "residential", "area": "yes"}))


func test_a_one_way_road_gets_half_the_usual_lanes() -> void:
	assert_eq(RoadTypes.default_lanes({"highway": "trunk"}, true), 2)


func test_a_one_way_road_always_gets_a_lane() -> void:
	assert_eq(RoadTypes.default_lanes({"highway": "service"}, true), 1)


func test_motorways_and_roundabouts_are_one_way_by_default() -> void:
	assert_true(RoadTypes.is_implied_oneway({"highway": "motorway"}))
	assert_true(RoadTypes.is_implied_oneway({"highway": "tertiary", "junction": "roundabout"}))
	assert_false(RoadTypes.is_implied_oneway({"highway": "tertiary"}))
