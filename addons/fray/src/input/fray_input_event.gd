extends Reference
## Base class for inputs detected by the FrayInput singleton.
##
## @desc:
## 		Conceptually similiar to a godot's built-in InputEvent.

## Time in miliseconds that the input was initially detected
var time_pressed: int

## Time in miliseconds that the input was held
var time_held: int

## The physics frame when the input was first pressed
var physics_frame: int

## The idle frame when the input was first pressed
var idle_frame: int

## Returns true if this event was triggered by a virtual press.
var virtually_pressed: bool

## Returns true if this input was filtered when inputs were polled.
## Used to ignore component presses when checking for complex inputs.
var filtered: bool

## Returns true if the input has already been detected
var echo: bool

## Returns true if the input is being pressed false if it is released
var pressed: bool

## The devices' ID
var device: int

## The input's name
var input: String


## Returns the time in miliseconds between two input events.
func get_time_between(fray_input_event: Reference) -> int:
	return int(abs(fray_input_event.time_pressed - time_pressed))

## Returns true if input was pressed with no echo
func is_just_pressed() -> bool:
	return pressed and not echo

## Returns true if input was not virtually pressed
func is_just_pressed_real() -> bool:
	return is_just_pressed() and not virtually_pressed
