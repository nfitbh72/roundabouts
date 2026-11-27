extends Node2D
## Entry point: plays the welcome screens, then shows the title, from which a
## junction screenshot can be imported, or a junction fetched from
## OpenStreetMap, and redrawn as road and lane outlines.

const TITLE_FADE_SECONDS: float = 1.5
const SCREENSHOT_HINT: String = "Drop another screenshot to try again, or press Esc to go back."
const OSM_HINT: String = "Press Esc to go back and try somewhere else."
const FETCHING: String = "Asking OpenStreetMap…"

@onready var _welcome_screen: WelcomeScreen = $UI/WelcomeScreen
@onready var _title_screen: TitleScreen = $UI/TitleScreen
@onready var _map_view: MapOutlineView = $MapOutlineView
@onready var _map_hint: Label = $UI/MapHint
@onready var _import_dialog: FileDialog = $UI/ImportDialog
@onready var _osm_importer: OsmImporter = $OsmImporter
@onready var _osm_credit: LinkButton = $UI/OsmCredit


func _ready() -> void:
	_welcome_screen.finished.connect(_on_welcome_finished)
	_title_screen.import_requested.connect(_import_dialog.popup_centered_ratio)
	_import_dialog.file_selected.connect(_import)
	_title_screen.osm_requested.connect(_fetch_from_osm)
	_osm_importer.imported.connect(_on_osm_imported)
	_osm_importer.failed.connect(_on_osm_failed)
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
	_osm_importer.cancel()
	_title_screen.set_fetching(false)
	var image: Image = Image.load_from_file(path)
	if image == null or image.is_empty():
		_show_title()
		_title_screen.show_load_failed(true)
		return
	_map_view.show_outline(MapConverter.from_image(image))
	_show_map(false)


func _fetch_from_osm(centre: GeoPoint) -> void:
	_title_screen.set_fetching(true)
	_title_screen.show_osm_status(FETCHING)
	_osm_importer.fetch(centre)


func _on_osm_imported(outline: MapOutline) -> void:
	_title_screen.set_fetching(false)
	_map_view.show_outline(outline)
	_show_map(true)


func _on_osm_failed(reason: String) -> void:
	_title_screen.set_fetching(false)
	_title_screen.show_osm_status(reason)


## Shows the redrawn junction, with OpenStreetMap's credit whenever the roads
## come from its data.
func _show_map(from_osm: bool) -> void:
	_end_welcome()
	_title_screen.hide()
	_map_view.show()
	_map_hint.text = OSM_HINT if from_osm else SCREENSHOT_HINT
	_map_hint.show()
	_osm_credit.visible = from_osm


func _show_title() -> void:
	_end_welcome()
	_map_view.hide()
	_map_hint.hide()
	_osm_credit.hide()
	_title_screen.show_load_failed(false)
	_title_screen.show_osm_status("")
	_title_screen.show()


## Removes the welcome screen, whether it finished or a screenshot was dropped part way through.
func _end_welcome() -> void:
	if is_instance_valid(_welcome_screen):
		_welcome_screen.queue_free()


func _fade_in(item: CanvasItem) -> void:
	item.modulate.a = 0.0
	item.show()
	create_tween().tween_property(item, "modulate:a", 1.0, TITLE_FADE_SECONDS)
