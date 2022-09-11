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

## Abstract method used to define a bind's 'is_pressed' method
func _is_pressed_impl(device: int = 0) -> bool:
	push_error("Method not implemented.")
	return false

## Virtual method used to define 'equals' method
func _equals_impl(input_bind: Resource) -> bool:
	return self is input_bind.get_script()
