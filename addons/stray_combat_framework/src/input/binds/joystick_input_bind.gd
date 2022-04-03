extends "input_bind.gd"

export var device: int
export var button: int

func _init(joystick_device: int = -1, joystick_button: int = -1) -> void:
	device = joystick_device
	button = joystick_button

func is_pressed() -> bool:
	return Input.is_joy_button_pressed(device, button)
