extends "input_bind.gd"
## Joystick axis input bind

## Joystick axis identifier. See JoyStickList
export var axis: int

## Determines whether to check the positive or negative side of the axis
export var check_positive: bool

## Joystick deadzone
export var deadzone: float setget set_deadzone


func _init(joystick_axis: int = -1, chk_positive: bool = true, joystick_deadzone: float = .5) -> void:
	axis = joystick_axis
	deadzone = joystick_deadzone
	check_positive = chk_positive


func is_pressed(device: int = 0) -> bool:
	var joy_axis := Input.get_joy_axis(device, axis)
	var is_positive_dir := sign(joy_axis) == 1
	
	if check_positive and not is_positive_dir:
		return false
		
	return abs(joy_axis) >= deadzone


func set_deadzone(value: float) -> void:
	deadzone = clamp(value, 0, 1)
