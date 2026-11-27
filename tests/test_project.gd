extends GutTest
## Checks that the project itself is wired up correctly.

const MAIN_SCENE_SETTING: String = "application/run/main_scene"


func test_main_scene_is_configured() -> void:
	var path: String = ProjectSettings.get_setting(MAIN_SCENE_SETTING, "")

	assert_ne(path, "", "The project should have a main scene set.")


func test_main_scene_loads() -> void:
	var path: String = ProjectSettings.get_setting(MAIN_SCENE_SETTING, "")

	var scene: PackedScene = load(path) as PackedScene

	assert_not_null(scene, "The main scene should load as a PackedScene.")
