tool
extends "input_bind.gd"
## Joystick input bind


## Button identifier. One of the JoyStickList button constants
export var button: int

func _init(joystick_button: int = -1) -> void:
	button = joystick_button


func is_pressed(device: int = 0) -> bool:
	return Input.is_joy_button_pressed(device, button)
