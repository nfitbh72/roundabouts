extends GutTest


func test_every_way_with_a_highway_tag_is_a_road() -> void:
	var ids: Array[int] = []
	for road: OsmRoad in Crossroads.extract().roads:
		ids.append(road.id)

	assert_eq(ids, [100, 200, 300, 400])


func test_roads_keep_their_tags() -> void:
	var road: OsmRoad = Crossroads.extract().roads[0]

	assert_eq(road.tags["lanes:forward"], "2")
	assert_eq(road.tags["turn:lanes:forward"], "left|through;right")


func test_roads_follow_their_nodes_in_order() -> void:
	var road: OsmRoad = Crossroads.extract().roads[0]

	assert_eq(road.node_ids, PackedInt64Array([1, 2, 3]))
	assert_eq(road.points.size(), 3)
	assert_eq(road.points[0].longitude, -0.0009)
	assert_eq(road.points[2].longitude, 0.0009)


func test_traffic_signals_and_crossings_are_found() -> void:
	var extract: OsmExtract = Crossroads.extract()

	assert_eq(extract.signals.size(), 1)
	assert_eq(extract.crossings.size(), 1)
	assert_eq(extract.crossings[0].latitude, 0.0001)


func test_missing_nodes_are_left_out() -> void:
	var text: String = (
		'{"elements": [{"type": "node", "id": 1, "lat": 1.0, "lon": 2.0},'
		+ '{"type": "way", "id": 9, "nodes": [1, 2], "tags": {"highway": "primary"}}]}'
	)

	var road: OsmRoad = OverpassParser.parse(text).roads[0]

	assert_eq(road.node_ids, PackedInt64Array([1]))
	assert_eq(road.points.size(), 1)


func test_text_that_is_not_json_gives_nothing() -> void:
	assert_null(OverpassParser.parse("<html>Server busy</html>"))


func test_json_without_elements_gives_nothing() -> void:
	assert_null(OverpassParser.parse('{"remark": "runtime error"}'))


func test_no_elements_gives_no_roads() -> void:
	assert_eq(OverpassParser.parse('{"elements": []}').roads.size(), 0)
