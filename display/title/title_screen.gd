class_name TitleScreen
extends Control
## The title, with a button for importing a junction screenshot and fields for
## fetching a junction from OpenStreetMap instead.

signal import_requested
signal osm_requested(centre: GeoPoint)

const NOT_ON_THIS_PLANET: String = "Those coordinates aren't anywhere on this planet."

@onready var _import_button: Button = $Center/Rows/ImportButton
@onready var _load_failed: Label = $Center/Rows/LoadFailed
@onready var _latitude: LineEdit = $Center/Rows/OsmRow/Latitude
@onready var _longitude: LineEdit = $Center/Rows/OsmRow/Longitude
@onready var _fetch_button: Button = $Center/Rows/OsmRow/FetchButton
@onready var _osm_status: Label = $Center/Rows/OsmStatus


func _ready() -> void:
	_import_button.pressed.connect(import_requested.emit)
	_fetch_button.pressed.connect(_request_osm)
	_latitude.text_submitted.connect(_request_osm.unbind(1))
	_longitude.text_submitted.connect(_request_osm.unbind(1))


## Shows or hides the message saying the last file could not be read as an image.
func show_load_failed(failed: bool) -> void:
	_load_failed.visible = failed


## Shows [param message] under the OpenStreetMap fields, or hides it if empty.
func show_osm_status(message: String) -> void:
	_osm_status.text = message
	_osm_status.visible = not message.is_empty()


## Greys out the fetch button while a fetch is under way, so only one runs at a time.
func set_fetching(fetching: bool) -> void:
	_fetch_button.disabled = fetching


func _request_osm() -> void:
	if _fetch_button.disabled:
		return
	var latitude: String = _latitude.text.strip_edges()
	var longitude: String = _longitude.text.strip_edges()
	var centre: GeoPoint = GeoPoint.new(latitude.to_float(), longitude.to_float())
	if not (latitude.is_valid_float() and longitude.is_valid_float() and centre.is_valid()):
		show_osm_status(NOT_ON_THIS_PLANET)
		return
	osm_requested.emit(centre)
