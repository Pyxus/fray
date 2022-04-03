extends "input_bind.gd"

export var device: int
export var axis: int
export var deadzone: float setget set_deadzone

func _init(joystick_device: int = -1, joystick_axis: int = -1, joystick_deadzone: float = 0) -> void:
	device = joystick_device
	axis = joystick_axis
	deadzone = joystick_deadzone

func is_pressed() -> bool:
	return Input.get_joy_axis(device, axis) >= deadzone

func set_deadzone(value: float) -> void:
	deadzone = clamp(value, 0, 1)
