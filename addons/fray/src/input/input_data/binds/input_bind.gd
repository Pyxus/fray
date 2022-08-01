extends Resource
## Abstract base class for all input binds
##
## @desc:
##		An input bind is used to map physical device presses to inputs fray input names.

## Abstract method used to check if input is pressed
func is_pressed(device: int = 0) -> bool:
	push_error("Method not implemented.")
	return false