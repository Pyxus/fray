@tool
class_name FrayInputBindJoyAxis
extends "input_bind_simple.gd"
## Joy axis input bind

## Joy axis identifier. See JoyStickList
@export var axis: int

## Determines whether to check the positive or negative side of the axis
@export var use_positive_axis: bool

## Joystick deadzone
@export var deadzone: float:
	set(value):
		deadzone = clamp(value, 0, 1)

func _init(joys_axis: int = -1, joy_use_positive_axis: bool = true, joy_deadzone: float = .5) -> void:
	axis = joys_axis
	deadzone = joy_deadzone
	use_positive_axis = joy_use_positive_axis


func _is_pressed_impl(device: int = 0) -> bool:
	var joy_axis := Input.get_joy_axis(device, axis)
	var is_positive_dir: bool = sign(joy_axis) == 1
	
	if use_positive_axis != is_positive_dir:
		return false
		
	return abs(joy_axis) >= deadzone


func _equals_impl(input_bind: Resource) -> bool:
	return (
		super(input_bind)
		and axis == input_bind.axis
		and use_positive_axis == input_bind.use_positive_axis)


func _get_strength_impl(device: int = 0) -> float:
	return Input.get_joy_axis(device, axis)
