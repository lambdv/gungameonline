extends Control
@onready var console = $console

func write(message: String) -> void:
	console.text += message + "\n"

func _ready() -> void:
	write("Hello, World!")

