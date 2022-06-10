extends "input_bind.gd"
## Joystick axis input bind

## Joystick axis identifier. See JoyStickList
export var axis: int

## Joystick deadzone
export var deadzone: float setget set_deadzone


func _init(joystick_axis: int = -1, joystick_deadzone: float = 0) -> void:
	axis = joystick_axis
	deadzone = joystick_deadzone


func is_pressed(device: int = 0) -> bool:
	return Input.get_joy_axis(device, axis) >= deadzone


func set_deadzone(value: float) -> void:
	deadzone = clamp(value, 0, 1)
