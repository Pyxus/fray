extends Resource
## Abstract base class for all input binds
##
## @desc:
##		An input bind is used by the InputDetector to map physical device presses to inputs ids.

var _previously_pressed: bool

## Used by InputDetector to update whether or not the button has been released
func poll() -> void:
	if is_pressed():
		if not _previously_pressed:
			_previously_pressed = true
	else:
		_previously_pressed = false

## Abstract method used to check if input is pressed
func is_pressed() -> bool:
	push_error("Method not implemented.")
	return false

## Returns true when a user starts pressing the input, meaning it's true only on the frame the user pressed down the input.
func is_just_pressed() -> bool:
	return is_pressed() and not _previously_pressed

## Returns true when the user stops pressing the input, meaning it's true only on the frame that the user released the button.
func is_just_released() -> bool:
	return not is_pressed() and _previously_pressed
