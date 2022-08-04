extends Resource
## Abstract base class for all input binds
##
## @desc:
##		An input bind is used to map physical device presses to inputs fray input names.

## Returns true if the bind is pressed
func is_pressed(device: int = 0) -> bool:
	return _is_pressed_impl(device)

## Virtual method used to define a bind's press check
func _is_pressed_impl(device: int = 0) -> bool:
	push_error("Method not implemented.")
	return false