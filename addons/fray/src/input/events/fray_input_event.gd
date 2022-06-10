extends Reference
## Base class for inputs detected by InputDetector.
##
## @desc:
## 		Conceptually similiar to a godot's built-in InputEvent.
##		This class is emitted in the InputDetector's input_detected signal.

## Time in miliseconds that the input was initially detected
var time_pressed: int

## Time in miliseconds when this event was emitted
var time_emitted: int

## Returns true if the input has already been detected
var echo: bool

## Returns true if the input is being pressed false if it is released
var pressed: bool

## Returns true if the input was pressed with its components ignored
var filtered: bool

## The devices' ID
var device: int

## The input's ID
var id: int

## Returns the time in miliseconds between two input events.
func get_time_between(fray_input_event: Reference) -> float:
	return abs(fray_input_event.time_pressed - time_pressed)

## Returns the time the input was held in seconds
func get_time_held() -> float:
	return (time_emitted - time_pressed) / 1000.0
