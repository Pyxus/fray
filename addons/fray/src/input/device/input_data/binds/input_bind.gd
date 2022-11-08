extends Resource
## Abstract base class for all input binds
##
## @desc:
##		An input bind is used to map physical device presses to inputs fray input names.

var InputBind: GDScript = load("res://addons/fray/src/input/device/input_data/binds/input_bind.gd")

## Returns true if the bind is pressed
func is_pressed(device: int = 0) -> bool:
	return _is_pressed_impl(device)

## Returns true if this bind is equal to the given bind
func equals(input_bind: Resource) -> bool:
	return _equals_impl(input_bind)

## Returns a value between 0 and 1 representing the intensity of an input.
func get_strength(device: int = 0) -> float:
	return _get_strength_impl()

## Abstract method used to define a bind's 'is_pressed' method
func _is_pressed_impl(device: int = 0) -> bool:
	push_error("Method not implemented.")
	return false

## Virtual method used to implement 'equals' method
func _equals_impl(input_bind: Resource) -> bool:
	return input_bind is InputBind

## Virtual method used to implement `get_strength` method
func _get_strength_impl(device: int = 0) -> float:
	return float(is_pressed(device))
