#TODO: Rename to Joypad
extends "input_bind.gd"
## Joystick input bind

## The Joystick device id
export var device: int

## Button identifier. One of the JoyStickList button constants
export var button: int

func _init(joystick_device: int = -1, joystick_button: int = -1) -> void:
	device = joystick_device
	button = joystick_button

func is_pressed() -> bool:
	return Input.is_joy_button_pressed(device, button)
