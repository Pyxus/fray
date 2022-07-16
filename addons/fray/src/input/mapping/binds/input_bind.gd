extends Resource
## Abstract base class for all input binds
##
## @desc:
##		An input bind is used by the InputDetector to map physical device presses to inputs ids.

var _previously_pressed: bool

## Abstract method used to check if input is pressed
func is_pressed(device: int = 0) -> bool:
	push_error("Method 'is_pressed' not implemented.")
	return false

## Returns true when a user starts pressing the input, meaning it's true only on the frame the user pressed down the input.
func is_just_pressed(device: int = 0) -> bool:
	return is_pressed() and not _previously_pressed

## Returns true when the user stops pressing the input, meaning it's true only on the frame that the user released the button.
func is_just_released(device: int = 0) -> bool:
	return not is_pressed() and _previously_pressed
