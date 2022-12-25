extends Reference
## Base class for inputs detected by the FrayInput singleton.
##
## @desc:
## 		Conceptually similiar to a godot's built-in InputEvent.

## Time in miliseconds that the input was initially pressed
var time_pressed: int

## Time in miliseconds that the input was detected. This is recorded when the signal is emitted
var time_detected: int

## The physics frame when the input was first pressed
var physics_frame: int

## The idle frame when the input was first pressed
var idle_frame: int

## Returns true if the input has already been detected
var echo: bool

## Returns true if the input is being pressed false if it is released
var pressed: bool

## The devices' ID
var device: int

## The input's name
var input: String

func _to_string() -> String:
	return "{input:%s, pressed:%s, device:%d}" % [input, pressed, device]


## Returns the time between two input events in miliseconds.
func get_time_between_ms(fray_input_event: Reference, use_time_pressed: bool = false) -> int:
	var t1: int = fray_input_event.time_pressed if use_time_pressed else fray_input_event.time_detected
	var t2: int = time_pressed if use_time_pressed else time_detected
	return int(abs(t1 - t2))

## Returns the time between two input events in seconds
func get_time_between_sec(fray_input_event: Reference, use_time_pressed: bool = false) -> float:
	return get_time_between_ms(fray_input_event, use_time_pressed) / 1000.0

## returns how long this input was held in miliseconds
func get_time_held_ms() -> int:
	return time_detected - time_pressed

## returns how long this input was held in seconds
func get_time_held_sec() -> float:
	return get_time_held_ms() / 1000.0

## Returns true if input was pressed with no echo
func is_just_pressed() -> bool:
	return pressed and not echo