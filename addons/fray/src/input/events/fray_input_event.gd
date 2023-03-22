class_name FrayInputEvent
extends RefCounted
## Base class for inputs detected by the FrayInput singleton.

## Time in miliseconds that the input was initially pressed
var time_pressed: int = 0

## Time in miliseconds that the input was detected. This is recorded when the signal is emitted
var time_detected: int = 0

## The physics frame when the input was first pressed
var physics_frame: int = 0

## The idle frame when the input was first pressed
var process_frame: int = 0

## The ID of the device that caused this event
var device: int = 0

## The input's name
var input: StringName = ""

var _is_echo: bool = false
var _is_pressed: bool = false
var _is_virtually_pressed: bool = false
var _is_distinct: bool = false


func _to_string() -> String:
	return "{input:%s, pressed:%s, device:%d}" % [input, is_pressed(), device]

## If [code]true[/code], the input is being pressed. If false, it is released
func is_pressed() -> bool:
	return _is_pressed

## If [code]true[/code], this event was triggered by a virtual press.
func is_virtually_pressed() -> bool:
	return _is_virtually_pressed

## If [code]true[/code], the input has already been detected
func is_echo() -> bool:
	return _is_echo

## If [code]true[/code], this input is considered to have occured before any other overlapping inputs.
## If multiple composite inputs which share binds are overlapping then try increasing 
## the more complex input's [member FrayCompositeInput.priority].
func is_distinct() -> bool:
	return _is_distinct

## Returns the time between two input events in miliseconds.
func get_time_between_msec(fray_input_event: RefCounted, use_time_pressed: bool = false) -> int:
	var t1: int = fray_input_event.time_pressed if use_time_pressed else fray_input_event.time_detected
	var t2: int = time_pressed if use_time_pressed else time_detected
	return int(abs(t1 - t2))

## Returns the time between two input events in seconds
func get_time_between_sec(fray_input_event: RefCounted, use_time_pressed: bool = false) -> float:
	return get_time_between_msec(fray_input_event, use_time_pressed) / 1000.0

## returns how long this input was held in miliseconds
func get_time_held_msec() -> int:
	return time_detected - time_pressed

## returns how long this input was held in seconds
func get_time_held_sec() -> float:
	return get_time_held_msec() / 1000.0

## Returns true if input was pressed with no echo
func is_just_pressed() -> bool:
	return is_pressed() and not is_echo()

## Returns true if input was not virtually pressed
func is_just_pressed_real() -> bool:
	return is_just_pressed() and not is_virtually_pressed()
