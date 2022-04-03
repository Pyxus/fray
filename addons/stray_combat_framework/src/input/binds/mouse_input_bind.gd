extends "input_bind.gd"

export var button: int

func _init(mouse_button: int = -1) -> void:
	button = mouse_button

func is_pressed() -> bool:
	return Input.is_mouse_button_pressed(button)
