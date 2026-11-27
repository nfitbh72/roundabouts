extends Node2D
## Entry point: plays the welcome screens, then shows the title.

@onready var _welcome_screen: WelcomeScreen = $UI/WelcomeScreen
@onready var _title: Label = $UI/Title


func _ready() -> void:
	_welcome_screen.finished.connect(_on_welcome_finished)


func _on_welcome_finished() -> void:
	_welcome_screen.queue_free()
	_title.show()
