extends "input_bind.gd"
## Mouse input bind

## The mouse button identifier, one of the ButtonList buttons or button wheel constants.
export var button: int

func _init(mouse_button: int = -1) -> void:
	button = mouse_button

func is_pressed(device: int = 0) -> bool:
	return Input.is_mouse_button_pressed(button)
