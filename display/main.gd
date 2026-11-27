extends Node2D
## Entry point: plays the welcome screens, then shows the title, from which a
## junction screenshot can be imported and redrawn as road and lane outlines.

const TITLE_FADE_SECONDS: float = 1.5

@onready var _welcome_screen: WelcomeScreen = $UI/WelcomeScreen
@onready var _title_screen: TitleScreen = $UI/TitleScreen
@onready var _map_view: MapOutlineView = $MapOutlineView
@onready var _map_hint: Label = $UI/MapHint
@onready var _import_dialog: FileDialog = $UI/ImportDialog


func _ready() -> void:
	_welcome_screen.finished.connect(_on_welcome_finished)
	_title_screen.import_requested.connect(_import_dialog.popup_centered_ratio)
	_import_dialog.file_selected.connect(_import)
	get_window().files_dropped.connect(_on_files_dropped)


func _unhandled_input(event: InputEvent) -> void:
	if _map_view.visible and event.is_action_pressed("ui_cancel"):
		_show_title()
		get_viewport().set_input_as_handled()


func _on_welcome_finished() -> void:
	_end_welcome()
	_fade_in(_title_screen)


func _on_files_dropped(files: PackedStringArray) -> void:
	if not files.is_empty():
		_import(files[0])


## Reads the screenshot at [param path] and shows the junction redrawn from it.
## The image is only used for the conversion and is let go straight afterwards.
func _import(path: String) -> void:
	var image: Image = Image.load_from_file(path)
	if image == null or image.is_empty():
		_show_title()
		_title_screen.show_load_failed(true)
		return
	_map_view.show_outline(MapConverter.from_image(image))
	_show_map()


func _show_map() -> void:
	_end_welcome()
	_title_screen.hide()
	_map_view.show()
	_map_hint.show()


func _show_title() -> void:
	_end_welcome()
	_map_view.hide()
	_map_hint.hide()
	_title_screen.show_load_failed(false)
	_title_screen.show()


## Removes the welcome screen, whether it finished or a screenshot was dropped part way through.
func _end_welcome() -> void:
	if is_instance_valid(_welcome_screen):
		_welcome_screen.queue_free()


func _fade_in(item: CanvasItem) -> void:
	item.modulate.a = 0.0
	item.show()
	create_tween().tween_property(item, "modulate:a", 1.0, TITLE_FADE_SECONDS)
