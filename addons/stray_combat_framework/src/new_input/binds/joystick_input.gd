extends "input_bind.gd"

export var device: int
export var button: int


func is_pressed() -> bool:
	return Input.is_joy_button_pressed(device, button)
