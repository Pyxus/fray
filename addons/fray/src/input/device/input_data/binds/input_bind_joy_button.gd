@tool
class_name FrayInputBindJoyButton
extends "input_bind_simple.gd"
## Joystick input bind


## Button identifier. One of the JoyStickList button constants
@export var button: int

func _init(joystick_button: int = -1) -> void:
	button = joystick_button


func _is_pressed_impl(device: int = 0) -> bool:
	return Input.is_joy_button_pressed(device, button)

func _equals_impl(input_bind: Resource) -> bool:
	return (
		super(input_bind)
		and button == input_bind.button)
