extends "fray_input_event.gd"
## Fray input event type for composite inputs

## Returns true if this event was triggered by a virtual press.
var virtually_pressed: bool

## Returns true if input was not virtually pressed
func is_just_pressed_real() -> bool:
	return is_just_pressed() and not virtually_pressed
