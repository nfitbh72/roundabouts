extends GutTest


func test_a_wide_junction_fills_the_width_of_the_screen() -> void:
	var fit: Transform2D = MapOutlineView.fit_transform(Vector2(200, 50), Vector2(1000, 1000), 0.0)

	assert_eq(fit * Vector2(0, 0), Vector2(0, 375))
	assert_eq(fit * Vector2(200, 50), Vector2(1000, 625))


func test_a_tall_junction_fills_the_height_inside_the_margin() -> void:
	var fit: Transform2D = MapOutlineView.fit_transform(Vector2(50, 100), Vector2(1000, 500), 50.0)

	assert_eq(fit * Vector2(0, 0), Vector2(400, 50))
	assert_eq(fit * Vector2(50, 100), Vector2(600, 450))
