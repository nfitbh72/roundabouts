class_name WelcomeScreen
extends Control
## Shows the welcome text one line at a time, each line filling the screen
## and fading in and out.
##
## Any key press or click moves straight on to the next line.

signal finished

const WELCOME_TEXT_PATH: String = "res://assets/welcome.txt"
const SECONDS_PER_LINE: float = 5.0
const FADE_SECONDS: float = 0.75

var _lines: PackedStringArray = PackedStringArray()
var _elapsed: float = 0.0
var _shown_index: int = -1

@onready var _line_label: Label = $Margin/Line


func _ready() -> void:
	_lines = WelcomeSequence.parse_lines(FileAccess.get_file_as_string(WELCOME_TEXT_PATH))


func _process(delta: float) -> void:
	_elapsed += delta
	_refresh()


func _unhandled_input(event: InputEvent) -> void:
	if not _is_skip(event):
		return
	_elapsed = WelcomeSequence.start_of_next_line(_elapsed, SECONDS_PER_LINE)
	_refresh()
	get_viewport().set_input_as_handled()


func _refresh() -> void:
	if WelcomeSequence.is_finished(_elapsed, _lines.size(), SECONDS_PER_LINE):
		_finish()
		return
	var index: int = WelcomeSequence.line_index_at(_elapsed, SECONDS_PER_LINE)
	if index != _shown_index:
		_shown_index = index
		_line_label.text = _lines[index]
	_line_label.modulate.a = WelcomeSequence.opacity_at(_elapsed, SECONDS_PER_LINE, FADE_SECONDS)


func _finish() -> void:
	set_process(false)
	set_process_unhandled_input(false)
	finished.emit()


func _is_skip(event: InputEvent) -> bool:
	var is_button: bool = (
		event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton
	)
	return is_button and event.is_pressed() and not event.is_echo()
