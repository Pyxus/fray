tool
extends "input_bind.gd"
## Joy axis input bind

## Joy axis identifier. See JoyStickList
export var axis: int

## Determines whether to check the positive or negative side of the axis
export var use_positive_axis: bool

## Joystick deadzone
export var deadzone: float setget set_deadzone


func _init(joys_axis: int = -1, joy_use_positive_axis: bool = true, joy_deadzone: float = .5) -> void:
	axis = joys_axis
	deadzone = joy_deadzone
	use_positive_axis = joy_use_positive_axis


func is_pressed(device: int = 0) -> bool:
	var joy_axis := Input.get_joy_axis(device, axis)
	var is_positive_dir := sign(joy_axis) == 1
	
	if use_positive_axis and not is_positive_dir:
		return false
		
	return abs(joy_axis) >= deadzone


func set_deadzone(value: float) -> void:
	deadzone = clamp(value, 0, 1)
