extends "virtual_input.gd"

export var button: int

func is_pressed() -> bool:
	return Input.is_mouse_button_pressed(button)
