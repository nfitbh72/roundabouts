class_name TitleScreen
extends Control
## The title, with a button for importing a junction screenshot.

signal import_requested

@onready var _import_button: Button = $Center/Rows/ImportButton
@onready var _load_failed: Label = $Center/Rows/LoadFailed


func _ready() -> void:
	_import_button.pressed.connect(import_requested.emit)


## Shows or hides the message saying the last file could not be read as an image.
func show_load_failed(failed: bool) -> void:
	_load_failed.visible = failed
