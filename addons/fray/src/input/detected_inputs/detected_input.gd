extends Reference
## Base class for inputs detected by InputDetector.
##
## @desc:
## 		Conceptually similiar to a godot's built-in InputEvent.
##		This class is emitted in the InputDetector's input_detected signal.

## Time in miliseconds that the input was detected
var time_stamp: int

## Returns the time in miliseconds between two detected inputs.
func get_time_between(detected_input: Reference) -> float:
	return abs(time_stamp - detected_input.time_stamp)
