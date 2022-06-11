extends Reference
## Base class for inputs detected by the FrayInput singleton.
##
## @desc:
## 		Conceptually similiar to a godot's built-in InputEvent.

## Time in miliseconds that the input was initially detected
var time_pressed: int

## Time in miliseconds when this event was emitted
var time_emitted: int

## Returns true if the input has already been detected
var echo: bool

## Returns true if the input is being pressed false if it is released
var pressed: bool

## Returns true if this event was triggered by a direct press.
## For example, will be false if this event was a component release press.
var explicit_press: bool

## Returns true if the input was pressed with its components ignored
var filtered: bool

## The devices' ID
var device: int

## The input's ID
var id: int

## The input's true ID. Will equal the id if not a conditional input
var true_id: int

## The input's components. Will be empty if input was not a combination
var components: PoolIntArray

## Returns the time in seconds between two input events.
func get_time_between(fray_input_event: Reference) -> float:
	return abs(fray_input_event.time_pressed - time_pressed) / 1000.0

## Returns the time the input was held in seconds
func get_time_held() -> float:
	return (time_emitted - time_pressed) / 1000.0

## Returns true if input was pressed with no echo
func is_just_pressed(check_filtered: bool = false) -> bool:
	return pressed\
		and not echo\
		and check_filtered == filtered

## Returns true if input was explicitly pressed
func is_just_pressed_explicit(check_filtered: bool = false) -> bool:
	return is_just_pressed(check_filtered) and explicit_press
