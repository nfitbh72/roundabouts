extends Node2D
## Entry point: plays the welcome screens, then fades in the title.

const TITLE_FADE_SECONDS: float = 1.5

@onready var _welcome_screen: WelcomeScreen = $UI/WelcomeScreen
@onready var _title: Label = $UI/Title


func _ready() -> void:
	_welcome_screen.finished.connect(_on_welcome_finished)


func _on_welcome_finished() -> void:
	_welcome_screen.queue_free()
	_fade_in(_title)


func _fade_in(item: CanvasItem) -> void:
	item.modulate.a = 0.0
	item.show()
	create_tween().tween_property(item, "modulate:a", 1.0, TITLE_FADE_SECONDS)
