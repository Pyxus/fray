class_name FrayInputBind
extends Resource
## Abstract base class for all input binds
##
## @desc:
##		An input bind is used to map physical device presses to inputs fray input names.


## Returns true if the bind is pressed
func is_pressed(device: int = 0) -> bool:
	return _is_pressed_impl(device)

## Returns true if this bind is equal to the given bind
func equals(input_bind: Resource) -> bool:
	return _equals_impl(input_bind)

## Returns a value between 0 and 1 representing the intensity of an input.
func get_strength(device: int = 0) -> float:
	return _get_strength_impl()

## [code]Abstract method[/code] used to implement a bind's [method is_pressed] method.
func _is_pressed_impl(device: int = 0) -> bool:
	assert(false, "Method not implemented")
	return false

## [code]Virtual method[/code] used to implement [method equals] method
func _equals_impl(input_bind: Resource) -> bool:
	return input_bind is FrayInputBind

## [code]Virtual method[/code] used to implement [method get_strength] method
func _get_strength_impl(device: int = 0) -> float:
	return float(is_pressed(device))
